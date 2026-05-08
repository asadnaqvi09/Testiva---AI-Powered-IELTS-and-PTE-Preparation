// src/modules/M9_Notification/routes/notification.routes.js

import express from "express";
import { authenticate } from "../../../middleware/auth.middleware.js";
import * as rateLimiter from "../../../middleware/rateLimiter.middleware.js";
import * as notificationController from "../controller/notification.controller.js";

const Router = express.Router();

Router.get(
  "/",
  authenticate,
  rateLimiter.authLimiter,
  notificationController.fetchNotifications
);

Router.get(
  "/unread-count",
  authenticate,
  rateLimiter.authLimiter,
  notificationController.fetchUnreadCount
);

Router.patch(
  "/read-all",
  authenticate,
  rateLimiter.authLimiter,
  notificationController.readAllNotifications
);

Router.patch(
  "/:id/read",
  authenticate,
  rateLimiter.authLimiter,
  notificationController.readNotification
);

Router.delete(
  "/:id",
  authenticate,
  rateLimiter.authLimiter,
  notificationController.removeNotification
);

export default Router;