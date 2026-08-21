import { findInvoiceById, syncInvoiceWithSigilo } from "../../../../src/invoices/repository.js";
import { fetchSigiloTransaction } from "../../../../src/payments/sigilopay.js";
import { requireAdmin } from "../../../_lib/admin.js";
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

  if (req.method !== "POST") {
    return sendJson(req, res, 405, { message: "Método não permitido." });
  }

  const admin = await requireAdmin(req, res);
  if (!admin) {
    return;
  }

  try {
    const id = req.query?.id || new URL(req.url || "/", "http://localhost").pathname.split("/").filter(Boolean)[3];

    if (!id) {
      return sendJson(req, res, 400, { message: "ID da fatura não informado." });
    }

    const invoice = await findInvoiceById(String(id).trim());
    if (!invoice) {
      return sendJson(req, res, 404, { message: "Fatura não encontrada." });
    }

    const transaction = await fetchSigiloTransaction({
      id: invoice.sigiloTransactionId,
      clientIdentifier: invoice.publicToken
    });

    const updatedInvoice = await syncInvoiceWithSigilo(invoice, transaction);
    return sendJson(req, res, 200, { invoice: normalizeInvoicePayload(updatedInvoice) });
  } catch (error) {
    console.error(error);
    return sendJson(req, res, 502, { message: error.message || "Erro ao sincronizar fatura." });
  }
}
