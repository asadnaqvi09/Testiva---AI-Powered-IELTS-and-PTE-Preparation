import path from "path";
import { fileURLToPath } from "url";
import dotenv from "dotenv";

// Always load Backend/.env (this file lives in Backend/src/config),
// regardless of process.cwd(). cwd-based dotenv misses EMAIL_* when the
// server is started from the repo root.
const envPath = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../.env");
dotenv.config({ path: envPath, quiet: true });
