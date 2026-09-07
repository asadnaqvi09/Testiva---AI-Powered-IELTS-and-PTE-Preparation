import "./src/config/env.js";
import http from "http";
import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import { Server } from "socket.io";
import authRoutes from './src/modules/M1_Identity/auth/routes/auth.routes.js';
import userRoutes from './src/modules/M1_Identity/user/routes/user.routes.js';
import feedbackRoutes from './src/modules/M1_Identity/user/routes/feedback.routes.js';
import adminRoutes from './src/modules/M1_Identity/admin/routes/admin.routes.js';
import testRoutes from './src/modules/M2_Test/routes/test.routes.js';
import prepRoutes from './src/modules/M3_Preparation/preparation/routes/preparation.routes.js';
import progressRoutes from './src/modules/M4_Progress/routes/progress.routes.js';
import communityRoutes from './src/modules/M7_Community/routes/community.routes.js';
import notificationRoutes from './src/modules/M9_Notification/routes/notification.routes.js';
import paymentRoutes from './src/modules/M8_Payment/routes/payment.routes.js';
import { stripeWebhook } from './src/modules/M8_Payment/controller/payment.controller.js';
import aiRoutes from './src/modules/M6_AI/routes/ai.routes.js';
import { initSocketIO } from './src/modules/M9_Notification/socketIO/index.js';
import { setSocketServer } from './src/config/socket.js';
import './src/modules/M5_Offline/sync.worker.js';
import { errorHandler } from './src/middleware/error.middleware.js';

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CLIENT_URL || "http://localhost:5173",
    credentials: true,
    methods: ["GET", "POST"]
  },
  pingTimeout: 60000,
});

app.use(helmet());
app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:5173' || "ws://127.0.0.1:55729/IxZyxYHFzDM=/ws",
  credentials: true
}));
app.use(morgan("dev"));

// Stripe webhook needs raw body (must be before express.json)
app.post(
  "/api/v1/payments/webhook",
  express.raw({ type: "application/json" }),
  stripeWebhook
);

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));
app.use("/uploads", express.static("uploads"));
app.use((req, _res, next) => {
  req.io = io;
  next();
});
initSocketIO(io);
setSocketServer(io);

app.get("/", (req, res) => {
  res.status(200).json({ message: "Testiva Backend Running" });
});
const API_V1 = "/api/v1";
app.use(`${API_V1}/auth`, authRoutes);
app.use(`${API_V1}/user`, userRoutes);
app.use(`${API_V1}/feedback`, feedbackRoutes);
app.use(`${API_V1}/admin`, adminRoutes);
app.use(`${API_V1}/content/test`, testRoutes);
app.use(`${API_V1}/content/preparations`, prepRoutes);
app.use(`${API_V1}/progress`, progressRoutes);
app.use(`${API_V1}/ai`, aiRoutes);
app.use(`${API_V1}/community`, communityRoutes);
app.use(`${API_V1}/notifications`, notificationRoutes);
app.use(`${API_V1}/payments`, paymentRoutes);

app.use(errorHandler);
const PORT = process.env.PORT || 5000;
server.listen(PORT, "0.0.0.0", () => {
  console.log(`
  🚀 Testiva Engine Online
  📡 Port: ${PORT}
  🔗 Mode: ${process.env.NODE_ENV || 'development'}
  `);
});