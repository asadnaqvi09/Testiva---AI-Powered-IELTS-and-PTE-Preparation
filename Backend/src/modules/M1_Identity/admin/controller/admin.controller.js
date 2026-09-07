import pool from '../../../../config/db.js'
import { fetchAllUsers, findUserById, getAdminStats, updateUserSubscriptionStatus } from '../../user.model.js'
import { v4 as uuidv4, validate as validateUUID } from "uuid";

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