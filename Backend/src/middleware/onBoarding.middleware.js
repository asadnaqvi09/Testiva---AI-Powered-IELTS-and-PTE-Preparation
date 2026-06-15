export const onboardingMiddleware = (req, res, next) => {
  try {
    const user = req.user;
    if (!user) {
      return res.status(401).json({ success: false, message: "Unauthorized asset access" });
    }
    if (user.subscription === "premium") {
      return next();
    }
    if (!user.preference) {
      return res.status(403).json({
        success: false,
        message: "Please select your learning preference to continue"
      });
    }
    next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Access check failed"
    });
  }
};