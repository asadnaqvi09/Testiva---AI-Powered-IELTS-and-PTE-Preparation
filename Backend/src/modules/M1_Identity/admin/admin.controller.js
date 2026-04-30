import { fetchAllUsers, findUserById, getAdminStats, updateUserSubscriptionStatus } from '../user.model.js'
import { v4 as uuidv4 } from "uuid";

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
        if (page < 1 || limit > 10 || limit < 1) {
            return res.status(400).json({
                success: false,
                message: "Invalid page or limit"
            })
        }
        const users = await fetchAllUsers(limit, offset, search, subscription)
        return res.status(200).json({
            success: true,
            message: "All Users Fetched Successfully",
            count: users.length,
            page,
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
        const { targetID, newSubscription } = req.body
        if (!targetID || !newSubscription) {
            return res.status(400).json({
                success: false,
                message: "Please Provide targetID and new Subscription"
            })
        }
        if (!uuidv4.validate(targetID)) {
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
        const targetUser = await findUserById(targetID)
        if(!targetUser) return res.status(404).json({ success: false, message: "User not found"})
        if(targetUser.role === "admin") return res.status(403).json( { success: false, message: "You cannot update this user subscription" } ) 
        const updatedUserRole = await updateUserSubscriptionStatus(targetID, newSubscription);
        await pool.query(`INSERT INTO admin_logs (admin_id,action,target_user_id,details,created_at)
        VALUES ($1,$2,$3,$4,NOW())`,
        [req.user.id,"Subscription Change",targetID,`Changed subscription to ${newSubscription}`]
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