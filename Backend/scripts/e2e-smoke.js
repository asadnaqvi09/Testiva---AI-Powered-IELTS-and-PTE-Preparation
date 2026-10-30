/**
 * L8 — E2E smoke: register → preference → list mocks → (optional) submit probe
 *
 * Usage (from Backend/):
 *   node scripts/e2e-smoke.js
 *
 * Env:
 *   API_BASE=http://localhost:5000/api/v1
 *   SMOKE_EMAIL=smoke_<timestamp>@testiva.local  (auto if unset)
 *   SMOKE_PASSWORD=SmokeTest1!
 *   SMOKE_PREFERENCE=IELTS|PTE
 *
 * Note: register may require OTP via email — if verify is blocked in your env,
 * set SMOKE_ACCESS_TOKEN + SMOKE_SKIP_REGISTER=1 to start from an existing student.
 */
import "./../src/config/env.js";

const API_BASE = (process.env.API_BASE || "http://localhost:5000/api/v1").replace(/\/$/, "");
const SKIP_REGISTER = process.env.SMOKE_SKIP_REGISTER === "1";
const PREFERENCE = (process.env.SMOKE_PREFERENCE || "IELTS").toUpperCase();
const PASSWORD = process.env.SMOKE_PASSWORD || "SmokeTest1!";
const email =
  process.env.SMOKE_EMAIL ||
  `smoke_${Date.now()}@testiva.local`;

let accessToken = process.env.SMOKE_ACCESS_TOKEN || "";

const log = (step, ok, detail = "") => {
  const mark = ok ? "OK" : "FAIL";
  console.log(`[${mark}] ${step}${detail ? ` — ${detail}` : ""}`);
};

async function req(method, path, { body, token } = {}) {
  const res = await fetch(`${API_BASE}${path}`, {
    method,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  let json = null;
  try {
    json = await res.json();
  } catch {
    json = null;
  }
  return { status: res.status, json };
}

async function main() {
  console.log(`\nTestiva E2E smoke → ${API_BASE}\n`);

  const health = await req("GET", "/health");
  log("health", health.status === 200 && health.json?.success === true, `status=${health.status}`);

  if (!SKIP_REGISTER) {
    const reg = await req("POST", "/auth/register", {
      body: {
        full_name: "Smoke Tester",
        email,
        password: PASSWORD,
      },
    });
    log(
      "register",
      reg.status < 500,
      `status=${reg.status} msg=${reg.json?.message || ""}`,
    );

    // Dev/local flows sometimes auto-verify; otherwise login may still work if user exists
    const login = await req("POST", "/auth/login", {
      body: { email, password: PASSWORD },
    });
    const data = login.json?.data || login.json;
    accessToken =
      data?.accessToken ||
      login.json?.accessToken ||
      accessToken;
    log(
      "login",
      login.status === 200 && !!accessToken,
      `status=${login.status}`,
    );
  } else {
    log("skip register", !!accessToken, accessToken ? "using SMOKE_ACCESS_TOKEN" : "missing token");
  }

  if (!accessToken) {
    console.error("\nNo access token — set SMOKE_ACCESS_TOKEN or complete OTP register manually.\n");
    process.exit(1);
  }

  const pref = await req("POST", "/auth/user/preferences", {
    token: accessToken,
    body: { preference: PREFERENCE },
  });
  log(
    "preference",
    pref.status === 200 || pref.status === 201 || pref.status === 400,
    `status=${pref.status} (400 ok if already set)`,
  );

  const tests = await req("GET", "/content/test", { token: accessToken });
  const list =
    tests.json?.data?.items ||
    tests.json?.data ||
    tests.json?.tests ||
    [];
  const count = Array.isArray(list) ? list.length : 0;
  log("list mocks", tests.status === 200, `status=${tests.status} count=${count}`);

  const me = await req("GET", "/payments/me", { token: accessToken });
  log("payments/me", me.status === 200, `plan=${me.json?.data?.plan || "?"}`);

  const invoices = await req("GET", "/payments/invoices", { token: accessToken });
  log("payments/invoices", invoices.status === 200, `status=${invoices.status}`);

  const notif = await req("GET", "/notifications", { token: accessToken });
  log(
    "notifications shape",
    notif.status === 200 &&
      (notif.json?.data?.items != null || notif.json?.notifications != null),
    `status=${notif.status}`,
  );

  console.log("\nSmoke finished. Full mock→result needs a published test + submit body.\n");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
