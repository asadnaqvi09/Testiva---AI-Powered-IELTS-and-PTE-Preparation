import os from "os";
import * as BonjourNs from "bonjour-service";

const BonjourCtor =
  BonjourNs.Bonjour ||
  BonjourNs.default?.Bonjour ||
  BonjourNs.default;

const SKIP_IFACE = /virtual|vethernet|vmware|hyper-v|loopback|docker|wsl|bluetooth|vnic|pseudo/i;
const PREFER_IFACE = /wi-?fi|wlan|wireless/i;

const isIPv4 = (iface) =>
  iface &&
  !iface.internal &&
  (iface.family === "IPv4" || iface.family === 4);

/**
 * Pick a LAN IPv4 for TXT records. Prefers Wi-Fi; skips VM/virtual adapters.
 */
export const getLanIPv4 = () => {
  const ifaces = os.networkInterfaces();
  const preferred = [];
  const others = [];

  for (const [name, list] of Object.entries(ifaces)) {
    if (SKIP_IFACE.test(name)) continue;
    for (const iface of list || []) {
      if (!isIPv4(iface)) continue;
      const entry = { name, address: iface.address };
      if (PREFER_IFACE.test(name)) preferred.push(entry);
      else others.push(entry);
    }
  }

  return preferred[0]?.address || others[0]?.address || null;
};

/**
 * Advertise this API on the LAN via mDNS (`Testiva._testiva._tcp.local`).
 * Failures are logged only — REST keeps running.
 */
export const advertiseTestivaMdns = (port) => {
  const lanIp = getLanIPv4();
  try {
    if (typeof BonjourCtor !== "function") {
      throw new Error("bonjour-service export is not constructable");
    }
    const bonjour = new BonjourCtor();
    const service = bonjour.publish({
      name: "Testiva",
      type: "testiva",
      protocol: "tcp",
      port: Number(port),
      disableIPv6: true,
      txt: {
        path: "/api/v1",
        ip: lanIp || "",
      },
    });

    service.on("up", () => {
      console.log(
        `  📣 mDNS: Testiva._testiva._tcp.local port ${port}` +
          (lanIp ? ` (${lanIp})` : ""),
      );
    });

    service.on("error", (err) => {
      console.warn("[mdns] advertise error:", err?.message || err);
    });
  } catch (err) {
    console.warn("[mdns] advertise failed:", err?.message || err);
  }
};
