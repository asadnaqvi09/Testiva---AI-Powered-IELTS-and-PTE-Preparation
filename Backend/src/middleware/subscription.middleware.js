// This is a comment: UNUSED — access is enforced ad hoc via canAccessExamType helpers.
// Kept for future route wiring; do not delete.
/*
export const requireSubscription = (...allowedPlans) => {
  return (req, res, next) => {
    const { user } = req;
    if (!user) {
      return res.status(401).json({ success: false, message: "Unauthorized. Please login first." });
    }
    if (user.role === "admin") return next();
    const planHierarchy = {
      'free': 1,
      'basic': 2,
      'premium': 3
    };
    const requiredLevel = Math.min(...allowedPlans.map(plan => planHierarchy[plan] || 1));
    const userLevel = planHierarchy[user.subscription] || 1;
    if (userLevel < requiredLevel) {
      return res.status(403).json({
        success: false,
        message: `This feature requires a ${allowedPlans.join(" or ")} subscription.`,
        currentPlan: user.subscription
      });
    }
    next();
  };
};
*/

// This is a comment: stub so accidental imports do not crash
export const requireSubscription = (..._allowedPlans) => {
  return (_req, _res, next) => next();
};
