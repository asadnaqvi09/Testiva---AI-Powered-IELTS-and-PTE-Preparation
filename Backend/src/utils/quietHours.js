/**
 * L7 — Quiet hours helper (HH:mm local to user timezone).
 * Push is skipped during quiet window; in-app + socket still deliver.
 */

const HHMM = /^([01]?\d|2[0-3]):([0-5]\d)$/;

export const parseHhMm = (value) => {
  if (typeof value !== "string" || !HHMM.test(value.trim())) return null;
  const [h, m] = value.trim().split(":").map(Number);
  return h * 60 + m;
};

/** Minutes since midnight in IANA timezone (fallback Asia/Karachi). */
export const localMinutesNow = (timeZone = "Asia/Karachi", date = new Date()) => {
  try {
    const parts = new Intl.DateTimeFormat("en-GB", {
      timeZone,
      hour: "2-digit",
      minute: "2-digit",
      hour12: false,
    }).formatToParts(date);
    const hour = Number(parts.find((p) => p.type === "hour")?.value ?? 0);
    const minute = Number(parts.find((p) => p.type === "minute")?.value ?? 0);
    return hour * 60 + minute;
  } catch {
    return date.getUTCHours() * 60 + date.getUTCMinutes();
  }
};

/**
 * @param {object} prefs — notif_prefs JSON (quietHoursEnabled, quietStart, quietEnd, timezone)
 * @returns {boolean} true if push should be suppressed
 */
export const isInQuietHours = (prefs, date = new Date()) => {
  if (!prefs || typeof prefs !== "object") return false;
  if (!prefs.quietHoursEnabled) return false;
  const start = parseHhMm(prefs.quietStart || "22:00");
  const end = parseHhMm(prefs.quietEnd || "07:00");
  if (start == null || end == null) return false;
  const now = localMinutesNow(prefs.timezone || "Asia/Karachi", date);
  // Overnight window (e.g. 22:00–07:00)
  if (start > end) {
    return now >= start || now < end;
  }
  // Same-day window (e.g. 13:00–15:00)
  return now >= start && now < end;
};
