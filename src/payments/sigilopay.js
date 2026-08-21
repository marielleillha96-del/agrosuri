const DEFAULT_API_BASE_URL = "https://app.sigilopay.com.br/api/v1";

const getApiBaseUrl = () => process.env.SIGILO_API_BASE_URL || DEFAULT_API_BASE_URL;

const getAuthHeaders = () => {
  const publicKey = process.env.SIGILO_PUBLIC_KEY;
  const secretKey = process.env.SIGILO_SECRET_KEY;

  if (!publicKey || !secretKey) {
    throw new Error("Credenciais da SigiloPay não configuradas.");
  }

  return {
    "x-public-key": publicKey,
    "x-secret-key": secretKey
  };
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

export const createSigiloPixPayment = async ({ identifier, amount, client, dueDate, metadata, callbackUrl }) => {
  const response = await fetch(`${getApiBaseUrl()}/gateway/pix/receive`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...getAuthHeaders()
    },
    body: JSON.stringify({
      identifier,
      amount,
      client,
      ...(dueDate ? { dueDate } : {}),
      ...(metadata ? { metadata } : {}),
      ...(callbackUrl ? { callbackUrl } : {})
    })
  });

  const payload = await readJsonResponse(response);

  if (!response.ok) {
    throw new Error(normalizeErrorMessage(payload, "Não foi possível gerar a cobrança PIX."));
  }

  return payload;
};

export const fetchSigiloTransaction = async ({ id, clientIdentifier }) => {
  const searchParams = new URLSearchParams();

  if (id) {
    searchParams.set("id", id);
  }

  if (clientIdentifier) {
    searchParams.set("clientIdentifier", clientIdentifier);
  }

  const response = await fetch(`${getApiBaseUrl()}/gateway/transactions?${searchParams.toString()}`, {
    method: "GET",
    headers: getAuthHeaders()
  });

  const payload = await readJsonResponse(response);

  if (!response.ok) {
    throw new Error(normalizeErrorMessage(payload, "Não foi possível consultar a transação."));
  }

  return payload;
};
