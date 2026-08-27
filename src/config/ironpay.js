const LOCALHOST_HOSTNAMES = new Set(["localhost", "127.0.0.1", "0.0.0.0"]);

const buildPublicWebhookUrl = (appDomain) => {
  if (!appDomain) {
    return null;
  }

  const normalizedDomain = String(appDomain).trim().replace(/^https?:\/\//i, "").replace(/\/+$/, "");

  if (!normalizedDomain) {
    return null;
  }

  return `https://${normalizedDomain}/api/webhooks/ironpay`;
};

export const resolveIronCallbackUrl = ({
  appUrl = "http://localhost:3000",
  appDomain = "localhost",
  appEnv = "development",
  callbackUrl = process.env.IRON_CALLBACK_URL
} = {}) => {
  const fallbackUrl = new URL("/api/webhooks/ironpay", appUrl).toString();
  const publicWebhookUrl = buildPublicWebhookUrl(appDomain) || fallbackUrl;
  const normalizedCallbackUrl = String(callbackUrl || "").trim();

  if (!normalizedCallbackUrl) {
    return appEnv === "production" ? publicWebhookUrl : fallbackUrl;
  }

  try {
    const parsed = new URL(normalizedCallbackUrl);

    if (LOCALHOST_HOSTNAMES.has(parsed.hostname) && appEnv === "production") {
      return publicWebhookUrl;
    }

    return parsed.toString();
  } catch {
    return appEnv === "production" ? publicWebhookUrl : fallbackUrl;
  }
};
