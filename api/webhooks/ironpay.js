import { findInvoiceByIronTransactionHash, findInvoiceByPublicToken, syncInvoiceWithIron } from "../../src/invoices/repository.js";
import { handleOptions, sendJson } from "../_lib/http.js";

export default async function handler(req, res) {
  if (handleOptions(req, res)) {
    return;
  }

  if (req.method !== "POST") {
    return sendJson(req, res, 405, { message: "Método não permitido." });
  }

  try {
    const payload = req.body || {};
    const expectedToken = process.env.IRON_WEBHOOK_TOKEN;
    const incomingToken =
      payload.token ||
      req.query?.token ||
      req.headers["x-webhook-token"] ||
      req.headers["x-ironpay-token"];

    if (expectedToken && incomingToken && incomingToken !== expectedToken) {
      return sendJson(req, res, 401, { message: "Token de webhook inválido." });
    }

    const transaction = payload.transaction || payload.data || {};
    const transactionId = payload.transactionId || transaction.hash || transaction.id;
    const clientIdentifier = transaction.identifier || payload.clientIdentifier;
    const invoice =
      (transactionId && (await findInvoiceByIronTransactionHash(transactionId))) ||
      (clientIdentifier && (await findInvoiceByPublicToken(String(clientIdentifier).trim())));

    if (!invoice) {
      return sendJson(req, res, 200, { received: true, matched: false });
    }

    const normalizedTransaction = {
      ...transaction,
      id: transactionId || transaction.hash || transaction.id || invoice.ironTransactionHash || invoice.sigiloTransactionId,
      hash: transactionId || transaction.hash || transaction.id || invoice.ironTransactionHash || invoice.sigiloTransactionId,
      status: transaction.paymentStatus || transaction.status || payload.status || invoice.ironStatus || invoice.sigiloStatus,
      paymentStatus:
        transaction.paymentStatus || transaction.status || payload.status || invoice.ironStatus || invoice.sigiloStatus,
      paymentMethod: transaction.paymentMethod || invoice.ironPaymentMethod || invoice.sigiloPaymentMethod || "pix",
      payedAt: transaction.payedAt || null,
      pixInformation: transaction.pixInformation || payload.pixInformation || {
        qrCode: payload.pix?.code || payload.pixInformation?.qrCode || invoice.ironPixCode || invoice.pixCode || null,
        image: payload.pix?.image || payload.pixInformation?.image || invoice.ironPixImage || invoice.pixImage || null
      },
      details: payload.details || transaction.details || null,
      event: payload.event || transaction.event || null
    };

    await syncInvoiceWithIron(invoice, normalizedTransaction);
    return sendJson(req, res, 200, { received: true, matched: true });
  } catch (error) {
    console.error(error);
    return sendJson(req, res, 500, { message: "Erro ao processar webhook da IronPay." });
  }
}
