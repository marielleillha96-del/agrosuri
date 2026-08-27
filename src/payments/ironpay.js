const DEFAULT_API_BASE_URL = "https://api.ironpayapp.com.br/api/public/v1";

const normalizeApiBaseUrl = (value) => {
  const rawValue = String(value || "").trim();

  if (!rawValue) {
    return DEFAULT_API_BASE_URL;
  }

  try {
    const url = new URL(rawValue);
    const pathname = url.pathname.replace(/\/+$/, "");

    if (/\/api\/v1$/i.test(pathname) && !/\/api\/public\/v1$/i.test(pathname)) {
      url.pathname = pathname.replace(/\/api\/v1$/i, "/api/public/v1");
      return url.toString().replace(/\/+$/, "");
    }

    if (!pathname || pathname === "/") {
      url.pathname = "/api/public/v1";
      return url.toString().replace(/\/+$/, "");
    }

    return url.toString().replace(/\/+$/, "");
  } catch {
    return rawValue.replace(/\/+$/, "");
  }
};

const getApiBaseUrl = () => normalizeApiBaseUrl(process.env.IRON_API_BASE_URL || DEFAULT_API_BASE_URL);
const getApiToken = () => process.env.IRON_API_TOKEN || process.env.IRONPAY_API_TOKEN;
const getDefaultOfferHash = () => process.env.IRON_DEFAULT_OFFER_HASH || process.env.IRON_OFFER_HASH;
const getDefaultProductHash = () =>
  process.env.IRON_DEFAULT_PRODUCT_HASH || process.env.IRON_PRODUCT_HASH || getDefaultOfferHash();

const normalizeAmountToCents = (amount) => {
  const numericAmount = Number(amount || 0);
  if (!Number.isFinite(numericAmount)) {
    return 0;
  }

  return Math.round(numericAmount * 100);
};

const toDigits = (value) => String(value || "").replace(/\D/g, "");

const diffDaysFromToday = (dateValue) => {
  if (!dateValue) {
    return null;
  }

  const target = new Date(`${String(dateValue).slice(0, 10)}T00:00:00-03:00`);
  if (Number.isNaN(target.getTime())) {
    return null;
  }

  const now = new Date();
  const millisPerDay = 24 * 60 * 60 * 1000;
  const diff = Math.ceil((target.getTime() - now.getTime()) / millisPerDay);
  return Number.isFinite(diff) && diff > 0 ? diff : 1;
};

const getAuthSearchParams = () => {
  const apiToken = getApiToken();

  if (!apiToken) {
    throw new Error("Credenciais da IronPay não configuradas.");
  }

  const params = new URLSearchParams();
  params.set("api_token", apiToken);
  return params;
};

const readJsonResponse = async (response) => {
  const text = await response.text();

  if (!text) {
    return null;
  }

  try {
    return JSON.parse(text);
  } catch (_error) {
    return { raw: text };
  }
};

const normalizeErrorMessage = (payload, fallback) =>
  payload?.message || payload?.errorDescription || payload?.details?.issue || fallback;

const normalizePixBlock = (payload) => {
  const pix = payload?.pix || payload?.data?.pix || payload?.transaction?.pix || {};

  return {
    code:
      pix.pix_copy_paste ||
      pix.code ||
      pix.pix_qr_code ||
      payload?.pix_qr_code ||
      payload?.data?.pix_qr_code ||
      null,
    image: pix.pix_image || pix.image || payload?.pix_image || payload?.data?.pix_image || null,
    expiresAt: pix.expires_at || pix.expiresAt || payload?.expires_at || payload?.data?.expires_at || null,
    base64: pix.base64 || payload?.pix_base64 || payload?.data?.pix_base64 || ""
  };
};

const normalizeTransactionPayload = (payload, fallbackPaymentMethod = "pix") => {
  const transaction = payload?.transaction || payload?.data || payload || {};
  const paymentStatus = String(
    transaction.payment_status ||
      transaction.status ||
      payload?.payment_status ||
      payload?.status ||
      ""
  ).trim();
  const paymentMethod = String(
    transaction.payment_method || payload?.payment_method || fallbackPaymentMethod || "pix"
  ).trim();
  const transactionHash =
    transaction.hash ||
    transaction.transaction_hash ||
    transaction.transactionHash ||
    payload?.hash ||
    payload?.transactionId ||
    payload?.transaction_id ||
    payload?.id ||
    null;

  return {
    id: transactionHash,
    hash: transactionHash,
    status: paymentStatus || "pending",
    paymentStatus: paymentStatus || "pending",
    paymentMethod,
    amount: transaction.amount ?? payload?.amount ?? null,
    order: transaction.order || payload?.order || null,
    customer: transaction.customer || payload?.customer || null,
    details: transaction.details || payload?.details || null,
    postbackUrl: transaction.postback_url || payload?.postback_url || null,
    pix: normalizePixBlock(payload),
    raw: payload
  };
};

const buildTransactionBody = ({
  identifier,
  amount,
  client,
  dueDate,
  metadata,
  callbackUrl,
  offerHash,
  paymentMethod = "pix"
}) => {
  const resolvedOfferHash = offerHash || getDefaultOfferHash();
  const resolvedProductHash = getDefaultProductHash();

  if (!resolvedOfferHash) {
    throw new Error("Informe IRON_DEFAULT_OFFER_HASH para criar transações na IronPay.");
  }

  if (!client?.name || !client?.email || !client?.phone || !client?.document) {
    throw new Error("Dados do cliente incompletos para gerar a cobrança na IronPay.");
  }

  const body = {
    amount: normalizeAmountToCents(amount),
    offer_hash: resolvedOfferHash,
    payment_method: paymentMethod,
    installments: 1,
    customer: {
      name: String(client.name).trim(),
      email: String(client.email).trim().toLowerCase(),
      phone_number: toDigits(client.phone),
      document: toDigits(client.document)
    },
    cart: [
      {
        product_hash: resolvedProductHash,
        title: String(metadata?.invoiceTitle || identifier || "Cobrança AGRO SURI").trim(),
        cover: null,
        price: normalizeAmountToCents(amount),
        quantity: 1,
        operation_type: 1,
        tangible: false
      }
    ]
  };

  if (identifier) {
    body.identifier = String(identifier).trim();
  }

  if (callbackUrl) {
    body.postback_url = callbackUrl;
  }

  if (dueDate) {
    body.expire_in_days = diffDaysFromToday(dueDate) || 1;
  }

  if (metadata) {
    body.tracking = metadata;
  }

  return body;
};

export const createIronPixPayment = async ({
  identifier,
  amount,
  client,
  dueDate,
  metadata,
  callbackUrl,
  offerHash,
  paymentMethod = "pix"
}) => {
  const response = await fetch(`${getApiBaseUrl()}/transactions?${getAuthSearchParams().toString()}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(
      buildTransactionBody({
        identifier,
        amount,
        client,
        dueDate,
        metadata,
        callbackUrl,
        offerHash,
        paymentMethod
      })
    )
  });

  const payload = await readJsonResponse(response);

  if (!response.ok) {
    throw new Error(normalizeErrorMessage(payload, "Não foi possível gerar a cobrança PIX na IronPay."));
  }

  return normalizeTransactionPayload(payload, paymentMethod);
};

export const fetchIronTransaction = async ({ id, identifier }) => {
  const searchParams = new URLSearchParams(getAuthSearchParams());

  if (identifier) {
    searchParams.set("identifier", String(identifier).trim());
  }

  const requestUrls = [];

  if (id) {
    requestUrls.push(`${getApiBaseUrl()}/transactions/${encodeURIComponent(String(id).trim())}?${searchParams.toString()}`);
    searchParams.set("hash", String(id).trim());
    requestUrls.push(`${getApiBaseUrl()}/transactions?${searchParams.toString()}`);
    searchParams.delete("hash");
    searchParams.set("transaction_hash", String(id).trim());
    requestUrls.push(`${getApiBaseUrl()}/transactions?${searchParams.toString()}`);
  } else {
    requestUrls.push(`${getApiBaseUrl()}/transactions?${searchParams.toString()}`);
  }

  let lastError = null;

  for (const url of requestUrls) {
    const response = await fetch(url, {
      method: "GET",
      headers: {
        Accept: "application/json"
      }
    });

    const payload = await readJsonResponse(response);

    if (response.ok) {
      return normalizeTransactionPayload(payload);
    }

    lastError = new Error(normalizeErrorMessage(payload, "Não foi possível consultar a transação na IronPay."));
  }

  throw lastError || new Error("Não foi possível consultar a transação na IronPay.");
};
