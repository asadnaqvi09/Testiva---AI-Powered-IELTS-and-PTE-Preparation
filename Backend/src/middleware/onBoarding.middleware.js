export const onboardingMiddleware = (req, res, next) => {
  try {
    const user = req.user;
    if (user.subscription === "premium") {
      return next();
    }
    if (!user.preferences) {
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