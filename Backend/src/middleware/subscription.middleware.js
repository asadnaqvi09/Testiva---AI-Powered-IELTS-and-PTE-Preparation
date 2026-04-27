export const requireSubscription = (...allowedPlans) => {
  return (req, res, next) => {
    const { user } = req;
    // 1. Double check authentication
    if (!user) {
      return res.status(401).json({ success: false, message: "Unauthorized. Please login first." });
    }
    // 2. Admin has "God Mode" - bypass all subscription checks
    if (user.role === "admin") return next();
    // 3. Define Plan Hierarchy (Higher plans include lower ones)
    const planHierarchy = {
      'free': 1,
      'basic': 2,
      'premium': 3
    };
    // Find the highest required plan from the allowed list
    const requiredLevel = Math.min(...allowedPlans.map(plan => planHierarchy[plan] || 1));
    const userLevel = planHierarchy[user.subscription] || 1;
    // 4. Check if user level is sufficient
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