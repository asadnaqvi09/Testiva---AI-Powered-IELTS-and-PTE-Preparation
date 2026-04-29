import express from "express";
import cors from "cors";
import helmet from "helmet";
import dotenv from "dotenv";
import morgan from "morgan";
import authRoutes from './src/modules/M1_Identity/auth/auth.routes.js';
import userRoutes from './src/modules/M1_Identity/user/user.routes.js';
import adminRoutes from './src/modules/M1_Identity/admin/admin.routes.js';
import testRoutes from './src/modules/M2_Test/test/test.routes.js';
import prepRoutes from './src/modules/M3_Preparation/preparation/preparation.routes.js';
import progressRoutes from './src/modules/M4_Progress/progress/progress.routes.js';
import aiRoutes from './src/modules/M6_AI/ai/ai.routes.js';
import './src/modules/M5_Offline/offline/sync.worker.js';
import {errorHandler} from './src/middleware/error.middleware.js';
dotenv.config();

const app = express();

const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(helmet());
app.use(morgan("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/uploads", express.static("uploads"));

// Health check route
app.get("/", (req, res) => {
  res.status(200).json({
    message: "Testiva Backend Running",
  });
});

// Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/user', userRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/content/test', testRoutes);
app.use('/api/v1/content/preparations', prepRoutes);
app.use('/api/v1/progress', progressRoutes);
app.use('/api/v1/ai', aiRoutes);

app.use(errorHandler);

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});