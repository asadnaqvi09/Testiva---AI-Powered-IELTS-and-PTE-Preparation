import pool from '../../../../config/db.js'
import bcrypt from 'bcrypt'
import {
  fetchAllUsers,
  findUserById,
  findUserByEmail,
  createUser,
  getAdminStats,
  getAdminDeepAnalytics,
  adminGlobalSearch,
  updateUserSubscriptionStatus,
  updateUserPreference,
} from '../../user.model.js'
import { validate as validateUUID } from "uuid";
import { syncQueue } from '../../../M5_Offline/sync.queue.js';
import { listPaymentEventsPaginated } from '../../../M8_Payment/models/payment.model.js';

export const getDashboardStats = async (req, res) => {
    try {
        const stats = await getAdminStats()
        return res.status(200).json({
            success: true,
            message: "Admin Stats Fetched Success",
            data: stats
        })
    } catch (error) {
        console.error("Error in getStats Controller : ", error),
            res.status(500).json({
                success: false,
                message: "Internal Server Error"
            })
    }
};

// Deep platform metrics for Analytics page
export const getAnalytics = async (req, res) => {
  try {
    const data = await getAdminDeepAnalytics();
    return res.status(200).json({
      success: true,
      message: "Analytics fetched",
      data,
    });
  } catch (error) {
    console.error("getAnalytics:", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

// TopBar global search
export const searchAdmin = async (req, res) => {
  try {
    const q = String(req.query.q || "").trim();
    if (q.length < 2) {
      return res.status(200).json({
        success: true,
        data: { users: [], mocks: [], prep: [], posts: [] },
      });
    }
    const data = await adminGlobalSearch(q, 5);
    return res.status(200).json({ success: true, data });
  } catch (error) {
    console.error("searchAdmin:", error);
    return res.status(500).json({ success: false, message: "Search failed" });
  }
};

export const getAllUsers = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1
        const limit = parseInt(req.query.limit) || 10
        const offset = (page - 1) * limit
        const search = req.query.search || ""
        const subscription = req.query.subscription || ""
        const preference = req.query.preference || ""
        if (page < 1 || limit > 10 || limit < 1) {
            return res.status(400).json({
                success: false,
                message: "Invalid page or limit"
            })
        }
        const users = await fetchAllUsers(limit, offset, search, subscription,preference)
        let countQuery = "SELECT COUNT(*) FROM users WHERE 1=1";
        const countParams = [];
        let pIndex = 1;
        if (search) {
            countQuery += ` AND (full_name ILIKE $${pIndex} OR email ILIKE $${pIndex})`;
            countParams.push(`%${search}%`);
            pIndex++;
        }
        if (subscription && subscription.toLowerCase() !== "all" && subscription.trim() !== "") {
            countQuery += ` AND subscription = $${pIndex}`;
            countParams.push(subscription.toLowerCase());
            pIndex++;
        }
        if (preference && preference.toLowerCase() !== "all" && preference.trim() !== "") {
            countQuery += ` AND preference = $${pIndex}`;
            countParams.push(preference.toUpperCase());
            pIndex++;
        }
        const totalCountRes = await pool.query(countQuery, countParams);
        const totalUsers = parseInt(totalCountRes.rows[0].count);
        const totalPages = Math.ceil(totalUsers / limit);
        return res.status(200).json({
            success: true,
            message: "All Users Fetched Successfully",
            count: users.length,
            totalUsers,
            page,
            totalPages,
            data: users
        })
    } catch (error) {
        console.error("Error in getAllUsers Controller", error)
        res.status(500).json({
            success: false,
            message: "Internal Server Error"
        })
    }
};

export const updateUserSubscription = async (req, res) => {
    try {
        const { targetID, newSubscription, unlocked_exam } = req.body
        if (!targetID || !newSubscription) {
            return res.status(400).json({
                success: false,
                message: "Please Provide targetID and new Subscription"
            })
        }
        if (!validateUUID(targetID)) {
            return res.status(400).json({
                success: false,
                message: "Invalid targetID format"
            });
        }
        const allowedSubscriptions = ['free', 'basic', 'premium']
        if (!allowedSubscriptions.includes(newSubscription)) {
            return res.status(400).json({
                success: false,
                message: "Please Provide Valid Subscription.Select one of these free,basic,premium"
            })
        }
        let unlockedExam = unlocked_exam;
        if (unlockedExam === '') unlockedExam = null;
        if (newSubscription === 'free') unlockedExam = null;
        else if (newSubscription === 'premium') unlockedExam = 'BOTH';
        else if (newSubscription === 'basic' && unlockedExam === undefined) {
            unlockedExam = undefined;
        }
        if (unlockedExam !== undefined && unlockedExam !== null) {
            const allowedUnlock = ['IELTS', 'PTE', 'BOTH'];
            if (!allowedUnlock.includes(unlockedExam)) {
                return res.status(400).json({
                    success: false,
                    message: "unlocked_exam must be IELTS, PTE, or BOTH"
                });
            }
        }
        const targetUser = await findUserById(targetID)
        if (!targetUser) return res.status(404).json({ success: false, message: "User not found" })
        if (targetUser.role === "admin") return res.status(403).json({ success: false, message: "You cannot update this user subscription" })
        const updatedUserRole = unlockedExam === undefined
            ? await updateUserSubscriptionStatus(targetID, newSubscription)
            : await updateUserSubscriptionStatus(targetID, newSubscription, unlockedExam);
        const logDetails = JSON.stringify({
            message: `Changed subscription to ${newSubscription}`,
            unlocked_exam: unlockedExam ?? targetUser.unlocked_exam ?? null,
        });
        await pool.query(`INSERT INTO admin_logs (admin_id,action,target_user_id,details,created_at)
        VALUES ($1,$2,$3,$4,NOW())`,
            [req.user.id, "Subscription Change", targetID, logDetails]
        )
        return res.status(200).json({
            success: true,
            message: `User Subscription Changed SuccessFully to ${newSubscription}`,
            data: updatedUserRole
        })
    } catch (error) {
        console.error("Error in updateUserSubscription Controller", error)
        return res.status(500).json({
            success: false,
            message: "Internal Server Error"
        })
    }
};

// This is a comment: admin creates a student account (skips OTP for FYP ops)
export const createAdminUser = async (req, res) => {
  try {
    const { full_name, email, password, preference, subscription } = req.body || {};
    if (!full_name || !String(full_name).trim()) {
      return res.status(400).json({ success: false, message: "full_name is required" });
    }
    if (!email || !String(email).trim()) {
      return res.status(400).json({ success: false, message: "email is required" });
    }
    if (!password || String(password).length < 6) {
      return res.status(400).json({ success: false, message: "password must be at least 6 characters" });
    }
    const pref = preference ? String(preference).toUpperCase() : null;
    if (pref && !["IELTS", "PTE"].includes(pref)) {
      return res.status(400).json({ success: false, message: "preference must be IELTS or PTE" });
    }
    const sub = (subscription || "free").toLowerCase();
    if (!["free", "basic", "premium"].includes(sub)) {
      return res.status(400).json({ success: false, message: "Invalid subscription" });
    }
    const existing = await findUserByEmail(email);
    if (existing) {
      return res.status(409).json({
        success: false,
        message: "Email already registered",
        error: { code: "EMAIL_EXISTS" },
      });
    }
    const password_hash = await bcrypt.hash(String(password), 10);
    const user = await createUser({
      full_name: String(full_name).trim(),
      email: String(email).trim().toLowerCase(),
      password_hash,
      auth_provider: "email",
      is_email_verified: true,
      subscription: sub,
      preference: pref,
    });
    await pool.query(
      `INSERT INTO admin_logs (admin_id, action, target_user_id, details, created_at)
       VALUES ($1, $2, $3, $4, NOW())`,
      [req.user.id, "Create User", user.id, JSON.stringify({ email: user.email })],
    );
    return res.status(201).json({
      success: true,
      message: "Student created successfully",
      data: user,
    });
  } catch (error) {
    console.error("createAdminUser:", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

// This is a comment: hard-delete student (not admin); cascades via FKs
export const deleteAdminUser = async (req, res) => {
  try {
    const targetID = req.params.id;
    if (!validateUUID(targetID)) {
      return res.status(400).json({ success: false, message: "Invalid user id" });
    }
    const target = await findUserById(targetID);
    if (!target) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    if (target.role === "admin") {
      return res.status(403).json({ success: false, message: "Cannot delete admin accounts" });
    }
    if (targetID === req.user.id) {
      return res.status(403).json({ success: false, message: "Cannot delete your own account" });
    }
    await pool.query(
      `INSERT INTO admin_logs (admin_id, action, target_user_id, details, created_at)
       VALUES ($1, $2, $3, $4, NOW())`,
      [req.user.id, "Delete User", targetID, JSON.stringify({ email: target.email })],
    );
    await pool.query(`DELETE FROM users WHERE id = $1::uuid`, [targetID]);
    return res.status(200).json({
      success: true,
      message: "User deleted successfully",
      data: { id: targetID },
    });
  } catch (error) {
    console.error("deleteAdminUser:", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

// This is a comment: pending preference-change requests from notifications queue
export const getPreferenceChangeRequests = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT n.id AS request_id,
              n.message,
              n.is_read,
              n.created_at,
              n.actor_id AS user_id,
              u.full_name,
              u.email,
              u.preference AS current_preference
       FROM notifications n
       LEFT JOIN users u ON u.id = n.actor_id
       WHERE n.user_id = $1::uuid
         AND n.type = 'preference_change_request'
         AND n.is_read = false
       ORDER BY n.created_at DESC
       LIMIT 50`,
      [req.user.id],
    );
    const items = result.rows.map((row) => {
      const match = String(row.message || "").match(/→\s*(IELTS|PTE)/i);
      return {
        ...row,
        target_preference: match ? match[1].toUpperCase() : null,
      };
    });
    return res.status(200).json({ success: true, data: { items } });
  } catch (error) {
    console.error("getPreferenceChangeRequests:", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

// This is a comment: admin manually applies preference + marks request read
export const approvePreferenceChangeRequest = async (req, res) => {
  try {
    const { request_id, user_id, target_preference } = req.body || {};
    if (!request_id || !user_id || !target_preference) {
      return res.status(400).json({
        success: false,
        message: "request_id, user_id and target_preference are required",
      });
    }
    if (!["IELTS", "PTE"].includes(String(target_preference).toUpperCase())) {
      return res.status(400).json({ success: false, message: "target_preference must be IELTS or PTE" });
    }
    const target = await findUserById(user_id);
    if (!target || target.role === "admin") {
      return res.status(404).json({ success: false, message: "Target student not found" });
    }
    const updated = await updateUserPreference(user_id, String(target_preference).toUpperCase());
    await pool.query(
      `UPDATE notifications SET is_read = true
       WHERE id = $1::uuid AND user_id = $2::uuid`,
      [request_id, req.user.id],
    );
    await pool.query(
      `INSERT INTO admin_logs (admin_id, action, target_user_id, details, created_at)
       VALUES ($1, $2, $3, $4, NOW())`,
      [
        req.user.id,
        "Approve Preference Change",
        user_id,
        JSON.stringify({ target_preference, request_id }),
      ],
    );
    return res.status(200).json({
      success: true,
      message: `Preference updated to ${target_preference}`,
      data: updated,
    });
  } catch (error) {
    console.error("approvePreferenceChangeRequest:", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

// L4 — Bull sync-tests depth + recent failed jobs
export const getSyncQueueStats = async (req, res) => {
  try {
    const counts = await syncQueue.getJobCounts();
    const failedJobs = await syncQueue.getFailed(0, 19);
    const failed = failedJobs.map((job) => ({
      id: job.id,
      attemptsMade: job.attemptsMade,
      failedReason: job.failedReason,
      timestamp: job.timestamp,
      data: {
        attempt_id: job.data?.attempt_id || job.data?.attemptId || null,
        user_id: job.data?.user_id || job.data?.userId || null,
      },
    }));
    return res.status(200).json({
      success: true,
      data: {
        queue: "sync-tests",
        counts,
        failed,
      },
    });
  } catch (error) {
    console.error("getSyncQueueStats:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to read queue stats (is Redis up?)",
    });
  }
};

// L6 — Admin payment event ledger
export const getPaymentEvents = async (req, res) => {
  try {
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const limit = Math.min(50, Math.max(1, parseInt(req.query.limit, 10) || 20));
    const offset = (page - 1) * limit;
    const userId = req.query.user_id || null;
    const plan = req.query.plan || null;
    const { items, total } = await listPaymentEventsPaginated({
      limit,
      offset,
      userId,
      plan,
    });
    return res.status(200).json({
      success: true,
      data: {
        items,
        meta: {
          page,
          limit,
          total,
          total_pages: Math.ceil(total / limit) || 1,
        },
      },
    });
  } catch (error) {
    console.error("getPaymentEvents:", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};