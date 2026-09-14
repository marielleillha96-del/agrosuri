import crypto from "crypto";
import { findInvoiceByIronTransactionHash, findInvoiceByPublicToken, syncInvoiceWithIron } from "../../src/invoices/repository.js";
import { handleOptions, readJsonBody, sendJson } from "../_lib/http.js";

const getBearerToken = (authorization) => {
  const value = String(authorization || "").trim();
  const match = value.match(/^Bearer\s+(.+)$/i);
  return match ? match[1].trim() : value;
};

const getWebhookToken = () => process.env.NOWBANK_WEBHOOK_TOKEN || process.env.NOWHUBPAY_WEBHOOK_TOKEN;
const getWebhookSecret = () => process.env.NOWBANK_WEBHOOK_SECRET || process.env.NOWHUBPAY_WEBHOOK_SECRET;

const timingSafeEqual = (left, right) => {
  const leftBuffer = Buffer.from(String(left || ""));
  const rightBuffer = Buffer.from(String(right || ""));

  return leftBuffer.length === rightBuffer.length && crypto.timingSafeEqual(leftBuffer, rightBuffer);
};

const isValidSignature = (req, payload) => {
  const secret = getWebhookSecret();

  if (!secret) {
    return true;
  }

  const signature = String(req.headers["x-signature"] || "").trim().replace(/^sha256=/i, "");

  if (!signature) {
    return false;
  }

  const rawBody = req.rawBody || JSON.stringify(payload || {});
  const expectedSignature = crypto.createHmac("sha256", secret).update(rawBody).digest("hex");

  return timingSafeEqual(signature, expectedSignature);
};

const isPaidStatus = (status) => String(status || "").trim().toUpperCase() === "COMPLETED";

const normalizePixImage = (value) => {
  const rawValue = String(value || "").trim();

  if (!rawValue) {
    return null;
  }

  if (/^data:image\//i.test(rawValue)) {
    return rawValue;
  }

  return `data:image/png;base64,${rawValue}`;
};

export default async function handler(req, res) {
  if (handleOptions(req, res)) {
    return;
  }

  if (req.method !== "POST") {
    return sendJson(req, res, 405, { message: "Método não permitido." });
  }

  try {
    const payload = await readJsonBody(req);
    const expectedToken = getWebhookToken();
    const incomingToken =
      getBearerToken(req.headers.authorization) ||
      req.query?.token ||
      req.headers["x-webhook-token"] ||
      req.headers["x-nowbank-token"] ||
      req.headers["x-syncpay-token"];

    if (expectedToken && incomingToken !== expectedToken) {
      return sendJson(req, res, 401, { message: "Token de webhook inválido." });
    }

    if (!isValidSignature(req, payload)) {
      return sendJson(req, res, 401, { message: "Assinatura do webhook inválida." });
    }

    const data = payload?.data && typeof payload.data === "object" ? payload.data : payload || {};
    const transactionId =
      data.transaction_id ||
      payload.transaction_id ||
      data.id ||
      payload.id ||
      payload.reference_id ||
      payload.identifier ||
      null;
    const externalId = data.external_id || payload.external_id || payload.identifier || null;
    const invoice =
      (transactionId && (await findInvoiceByIronTransactionHash(transactionId))) ||
      (externalId && (await findInvoiceByPublicToken(String(externalId).trim()))) ||
      (transactionId && (await findInvoiceByPublicToken(String(transactionId).trim())));

    if (!invoice) {
      return sendJson(req, res, 200, { received: true, matched: false });
    }

    const status = data.status || payload.status || invoice.ironStatus || invoice.sigiloStatus;
    const normalizedTransaction = {
      id: transactionId || invoice.ironTransactionHash || invoice.sigiloTransactionId,
      hash: transactionId || invoice.ironTransactionHash || invoice.sigiloTransactionId,
      status,
      paymentStatus: status,
      paymentMethod: data.payment_method || payload.payment_method || invoice.ironPaymentMethod || invoice.sigiloPaymentMethod || "pix",
      payedAt: isPaidStatus(status) ? data.updated_at || payload.updated_at || payload.created_at || new Date().toISOString() : null,
      pixInformation: {
        qrCode: data.pix_copy_paste || payload.pix_copy_paste || invoice.ironPixCode || invoice.pixCode || null,
        image: normalizePixImage(data.pix_qr_code || payload.pix_qr_code) || invoice.ironPixImage || invoice.pixImage || null
      },
      details: {
        amount: data.amount ?? payload.amount ?? null,
        endToEnd: data.end_to_end_id || payload.end_to_end_id || null,
        eventId: payload.id || null,
        eventType: payload.type || "deposit.updated",
        payerDocument: data.payer_document || data.payer?.document || null,
        payerName: data.payer_name || data.payer?.name || null
      },
      event: payload.type || "deposit.updated"
    };

    await syncInvoiceWithIron(invoice, normalizedTransaction);
    return sendJson(req, res, 200, { received: true, matched: true });
  } catch (error) {
    console.error(error);
    return sendJson(req, res, 500, { message: "Erro ao processar webhook da NowBank." });
  }
}
