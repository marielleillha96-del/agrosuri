import { findInvoiceByPublicToken, findInvoiceBySigiloTransactionId, syncInvoiceWithSigilo } from "../../src/invoices/repository.js";
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
    const expectedToken = process.env.SIGILO_WEBHOOK_TOKEN;

    if (expectedToken && payload.token !== expectedToken) {
      return sendJson(req, res, 401, { message: "Token de webhook inválido." });
    }

    const transaction = payload.transaction || {};
    const transactionId = payload.transactionId || transaction.id;
    const clientIdentifier = transaction.identifier || payload.clientIdentifier;
    const invoice =
      (transactionId && (await findInvoiceBySigiloTransactionId(transactionId))) ||
      (clientIdentifier && (await findInvoiceByPublicToken(String(clientIdentifier).trim())));

    if (!invoice) {
      return sendJson(req, res, 200, { received: true, matched: false });
    }

    const normalizedTransaction = {
      ...transaction,
      id: transactionId || transaction.id || invoice.sigiloTransactionId,
      status: transaction.status || payload.status || invoice.sigiloStatus,
      paymentMethod: transaction.paymentMethod || invoice.sigiloPaymentMethod || "PIX",
      payedAt: transaction.payedAt || null,
      pixInformation: transaction.pixInformation || payload.pixInformation || {
        qrCode: payload.pix?.code || payload.pixInformation?.qrCode || invoice.pixCode || null,
        image: payload.pix?.image || payload.pixInformation?.image || invoice.pixImage || null
      },
      details: payload.details || transaction.details || null
    };

    await syncInvoiceWithSigilo(invoice, normalizedTransaction);
    return sendJson(req, res, 200, { received: true, matched: true });
  } catch (error) {
    console.error(error);
    return sendJson(req, res, 500, { message: "Erro ao processar webhook da SigiloPay." });
  }
}
