export const requireSubscription = (...allowedSubscriptions) => {
    return (req,res,next) => {
        try {
            const user = req.user;
            if (!user) {
                return res.status(400).json({
                    success: false,
                    message: "Unauthorized Access"
                })
            };
            if (user.role === "admin") {
                return next();
            };
            if (!allowedSubscriptions.includes(user.subscription)) {
                return res.status(400).json({
                    success: false,
                    message: "Upgrade to premium plan to access this feature"
                });
            };
            next();
        } catch (error) {
            console.log("Error in subscription middleware", error);
            return res.status(500).json({
                success: false,
                message: "Access Control Error"
            })
        }
    }
};

export const requireFeatureAccess = ({
  allowGuest = false,
  allowFree = false,
  allowPremium = false
}) => {
  return (req, res, next) => {
    const user = req.user;
    if (!user) {
      return res.status(401).json({
        success:false,
        message:"Unauthorized"
      });
    }
    if (user.role === "admin") {
      return next();
    }
    if (user.role === "guest" && allowGuest) {
      return next();
    }
    if (user.subscription === "free" && allowFree) {
      return next();
    }
    if (user.subscription === "premium" && allowPremium) {
      return next();
    }
    return res.status(403).json({
      success:false,
      message:"Feature not available for your plan"
    });
  };
};