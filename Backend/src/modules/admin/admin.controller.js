import { fetchAllUsers, getAdminStats, updateUserSubscriptionStatus } from '../../models/user.model.js'

export const getDashboardStats = async (req,res) => {
    try {
        const stats = await getAdminStats()
        return res.status(200).json({
            success : true,
            message : "Admin Stats Fetched Success",
            data : stats
        })
    } catch (error) {
        console.error("Error in getStats Controller : ", error),
        res.status(500).json({
            success : false,
            message : "Internal Server Error"
        })
    }
};

export const getAllUsers = async (req,res) => {
    try {
        const page = parseInt(req.query.page) || 1
        const limit = parseInt(req.query.limit) || 10
        const offset = (page - 1) * limit
        const users = await fetchAllUsers(limit,offset)
        return res.status(200).json({
            success : true,
            message : "All Users Fetched Successfully",
            count : users.length,
            page,
            data : users
        })
    } catch (error) {
        console.error("Error in getAllUsers Controller", error)
        res.status(500).json({
            success : false,
            message : "Internal Server Error"
        })   
    }
};

export const updateUserSubscription = async (req,res) => {
    try {
        const { targetID , newSubscription , role } = req.body
        if (!targetID || !newSubscription ) {
            return res.status(400).json({
                success : false,
                message : "Please Provide targetID and new Subscription"
            })
        }
        const allowedRoles = ['free','basic','premium']
        if (!allowedRoles.includes(newSubscription)) {
            return res.status(400).json({
                success : false,
                message : "Please Provide Valid Role.Select one of these free,basic,premium"
            })
        }
        const updatedUserRole = await updateUserSubscriptionStatus(targetID , newSubscription);
        if (!updatedUserRole) {
            return res.status(404).json({
                success : false,
                message : "User not found"
            })
        }
        return res.status(200).json({
            success : true,
            message : `User Subscription Changed SuccessFully to ${newSubscription}`,
            data : updatedUserRole
        })
    } catch (error) {
        console.error("Error in updateUserSubscription Controller", error)
        return res.status(500).json({
            success : false,
            message : "Internal Server Error"
        })    
    }
};

export const readingController = (req,res) => {};

export const listeningController = (req,res) => {};

export const analyticsController = (req,res) => {};