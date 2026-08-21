import { findInvoiceByPublicToken, syncInvoiceWithSigilo } from "../../../../src/invoices/repository.js";
import { fetchSigiloTransaction } from "../../../../src/payments/sigilopay.js";
import { handleOptions, sendJson } from "../../../_lib/http.js";

const normalizeInvoicePayload = (invoice) => {
  if (!invoice) {
    return null;
  }

  return {
    id: invoice.id,
    publicToken: invoice.publicToken,
    clientUserId: invoice.clientUserId,
    clientName: invoice.clientName,
    clientEmail: invoice.clientEmail,
    clientPhone: invoice.clientPhone,
    clientDocument: invoice.clientDocument,
    title: invoice.title,
    amount: Number(invoice.amount || 0),
    dueDate: invoice.dueDate,
    description: invoice.description,
    status: invoice.status,
    sigiloTransactionId: invoice.sigiloTransactionId,
    sigiloOrderId: invoice.sigiloOrderId,
    sigiloPaymentMethod: invoice.sigiloPaymentMethod,
    sigiloStatus: invoice.sigiloStatus,
    pixCode: invoice.pixCode,
    pixImage: invoice.pixImage,
    paymentUrl: invoice.paymentUrl,
    callbackUrl: invoice.callbackUrl,
    sigiloDetails: invoice.sigiloDetails,
    sigiloPayload: invoice.sigiloPayload,
    paidAt: invoice.paidAt,
    createdAt: invoice.createdAt,
    updatedAt: invoice.updatedAt
  };
};

export default async function handler(req, res) {
  if (handleOptions(req, res)) {
    return;
  }

  if (req.method !== "GET") {
    return sendJson(req, res, 405, { message: "Método não permitido." });
  }

  try {
    const token = req.query?.token || new URL(req.url || "/", "http://localhost").pathname.split("/").filter(Boolean).pop();
    const invoice = await findInvoiceByPublicToken(String(token || "").trim());

    if (!invoice) {
      return sendJson(req, res, 404, { message: "Fatura não encontrada." });
    }

    return sendJson(req, res, 200, { invoice: normalizeInvoicePayload(invoice) });
  } catch (error) {
    console.error(error);
    return sendJson(req, res, 500, { message: "Erro ao carregar fatura pública." });
  }
}
