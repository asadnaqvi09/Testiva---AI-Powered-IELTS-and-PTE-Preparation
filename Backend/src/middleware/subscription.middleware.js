export const requireSubscription = (...allowed) => {
  return (req, res, next) => {
    const { user } = req;
    if (!user) {
      return res.status(401).json({ message: "Unauthorized" });
    }
    if (user.role === "admin") return next();
    if (!allowed.includes(user.subscription)) {
      return res.status(403).json({
        message: "Subscription Required To Access This Content"
      });
    }

    next();
  };
};