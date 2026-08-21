import { randomUUID } from "crypto";

import { pool } from "../auth/db.js";

const normalizeStatus = (status) => {
  const value = String(status || "").trim().toUpperCase();

  if (["OK", "PENDING", "WAITING_PAYMENT"].includes(value)) {
    return "pending";
  }

  if (["COMPLETED", "PAID", "APPROVED", "AUTHORIZED", "SUCCESS"].includes(value)) {
    return "paid";
  }

  if (value === "REFUNDED") {
    return "refunded";
  }

  if (value === "CHARGED_BACK") {
    return "charged_back";
  }

  if (["FAILED", "REJECTED", "CANCELED"].includes(value)) {
    return "failed";
  }

  return value ? value.toLowerCase() : "pending";
};

const resolveInvoiceStatus = ({ status, payedAt, event } = {}) => {
  if (payedAt) {
    return "paid";
  }

  const normalizedEvent = String(event || "").trim().toUpperCase();
  if (["TRANSACTION_PAID", "TRANSACTION_COMPLETED"].includes(normalizedEvent)) {
    return "paid";
  }

  if (normalizedEvent === "TRANSACTION_REFUNDED") {
    return "refunded";
  }

  if (normalizedEvent === "TRANSACTION_CHARGED_BACK") {
    return "charged_back";
  }

  if (normalizedEvent === "TRANSACTION_CANCELED") {
    return "failed";
  }

  return normalizeStatus(status);
};

const serializeInvoice = (row) => {
  if (!row) {
    return null;
  }

  return {
    id: row.id,
    publicToken: row.public_token,
    clientUserId: row.client_user_id,
    clientName: row.client_name,
    clientEmail: row.client_email,
    clientPhone: row.client_phone,
    clientDocument: row.client_document,
    title: row.title,
    amount: Number(row.amount || 0),
    dueDate: row.due_date,
    description: row.description,
    status: row.paid_at ? "paid" : row.status,
    sigiloTransactionId: row.sigilo_transaction_id,
    sigiloOrderId: row.sigilo_order_id,
    sigiloPaymentMethod: row.sigilo_payment_method,
    sigiloStatus: row.sigilo_status,
    pixCode: row.pix_code,
    pixImage: row.pix_image,
    paymentUrl: row.payment_url,
    callbackUrl: row.callback_url,
    sigiloDetails: row.sigilo_details || null,
    sigiloPayload: row.sigilo_payload || null,
    paidAt: row.paid_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
};

let invoiceSchemaPromise;

export const ensureInvoiceSchema = async () => {
  if (!invoiceSchemaPromise) {
    invoiceSchemaPromise = pool.query(`
      create table if not exists public.app_invoices (
        id uuid primary key default gen_random_uuid(),
        public_token text not null unique,
        client_user_id uuid references public.app_users(id) on delete set null,
        client_name text not null,
        client_email text,
        client_phone text,
        client_document text,
        title text not null,
        amount numeric(12, 2) not null default 0,
        due_date date,
        description text,
        status text not null default 'pending',
        sigilo_transaction_id text unique,
        sigilo_order_id text,
        sigilo_payment_method text not null default 'PIX',
        sigilo_status text,
        pix_code text,
        pix_image text,
        payment_url text,
        callback_url text,
        sigilo_details jsonb not null default '{}'::jsonb,
        sigilo_payload jsonb not null default '{}'::jsonb,
        paid_at timestamptz,
        created_at timestamptz not null default timezone('utc', now()),
        updated_at timestamptz not null default timezone('utc', now())
      );

      create index if not exists app_invoices_public_token_idx on public.app_invoices (public_token);
      create index if not exists app_invoices_client_user_id_idx on public.app_invoices (client_user_id);
      create index if not exists app_invoices_status_idx on public.app_invoices (status);
      create index if not exists app_invoices_sigilo_transaction_id_idx on public.app_invoices (sigilo_transaction_id);

      drop trigger if exists set_app_invoices_updated_at on public.app_invoices;
      create trigger set_app_invoices_updated_at
      before update on public.app_invoices
      for each row
      execute function public.set_updated_at();
    `);
  }

  return invoiceSchemaPromise;
};

export const createInvoiceToken = () => `inv_${randomUUID().replace(/-/g, "").slice(0, 18)}`;

export const createInvoice = async ({
  publicToken,
  clientUserId = null,
  clientName,
  clientEmail = null,
  clientPhone = null,
  clientDocument = null,
  title,
  amount,
  dueDate = null,
  description = null,
  sigiloTransactionId = null,
  sigiloOrderId = null,
  sigiloPaymentMethod = "PIX",
  sigiloStatus = "pending",
  pixCode = null,
  pixImage = null,
  paymentUrl = null,
  callbackUrl = null,
  sigiloDetails = {},
  sigiloPayload = {},
  status = "pending",
  paidAt = null
}) => {
  await ensureInvoiceSchema();

  const { rows } = await pool.query(
    `
      insert into public.app_invoices (
        public_token, client_user_id, client_name, client_email, client_phone, client_document,
        title, amount, due_date, description, status, sigilo_transaction_id, sigilo_order_id,
        sigilo_payment_method, sigilo_status, pix_code, pix_image, payment_url, callback_url,
        sigilo_details, sigilo_payload, paid_at
      )
      values (
        $1,$2,$3,$4,$5,$6,
        $7,$8,$9,$10,$11,$12,$13,
        $14,$15,$16,$17,$18,$19,
        $20::jsonb,$21::jsonb,$22
      )
      returning *
    `,
    [
      publicToken,
      clientUserId,
      clientName,
      clientEmail,
      clientPhone,
      clientDocument,
      title,
      amount,
      dueDate || null,
      description,
      status,
      sigiloTransactionId,
      sigiloOrderId,
      sigiloPaymentMethod,
      sigiloStatus,
      pixCode,
      pixImage,
      paymentUrl,
      callbackUrl,
      JSON.stringify(sigiloDetails || {}),
      JSON.stringify(sigiloPayload || {}),
      paidAt
    ]
  );

  return serializeInvoice(rows[0]);
};

export const listInvoices = async () => {
  await ensureInvoiceSchema();

  const { rows } = await pool.query(`
    select *
    from public.app_invoices
    order by created_at desc
  `);

  return rows.map(serializeInvoice);
};

export const countInvoices = async () => {
  await ensureInvoiceSchema();

  const { rows } = await pool.query(`select count(*)::int as total from public.app_invoices`);
  return rows[0]?.total || 0;
};

export const findInvoiceById = async (id) => {
  await ensureInvoiceSchema();

  const { rows } = await pool.query(`select * from public.app_invoices where id = $1 limit 1`, [id]);
  return serializeInvoice(rows[0] || null);
};

export const findInvoiceByPublicToken = async (publicToken) => {
  await ensureInvoiceSchema();

  const { rows } = await pool.query(`select * from public.app_invoices where public_token = $1 limit 1`, [
    publicToken
  ]);
  return serializeInvoice(rows[0] || null);
};

export const findInvoiceBySigiloTransactionId = async (transactionId) => {
  await ensureInvoiceSchema();

  const { rows } = await pool.query(
    `select * from public.app_invoices where sigilo_transaction_id = $1 limit 1`,
    [transactionId]
  );

  return serializeInvoice(rows[0] || null);
};

export const updateInvoiceByPublicToken = async (publicToken, changes) => {
  await ensureInvoiceSchema();

  const fields = [];
  const values = [publicToken];
  const pushField = (column, value) => {
    if (value === undefined) {
      return;
    }

    values.push(value);
    fields.push(`${column} = $${values.length}`);
  };

  pushField("client_user_id", changes.clientUserId);
  pushField("client_name", changes.clientName);
  pushField("client_email", changes.clientEmail);
  pushField("client_phone", changes.clientPhone);
  pushField("client_document", changes.clientDocument);
  pushField("title", changes.title);
  pushField("amount", changes.amount);
  pushField("due_date", changes.dueDate);
  pushField("description", changes.description);
  pushField("status", changes.status);
  pushField("sigilo_transaction_id", changes.sigiloTransactionId);
  pushField("sigilo_order_id", changes.sigiloOrderId);
  pushField("sigilo_payment_method", changes.sigiloPaymentMethod);
  pushField("sigilo_status", changes.sigiloStatus);
  pushField("pix_code", changes.pixCode);
  pushField("pix_image", changes.pixImage);
  pushField("payment_url", changes.paymentUrl);
  pushField("callback_url", changes.callbackUrl);
  pushField("sigilo_details", changes.sigiloDetails ? JSON.stringify(changes.sigiloDetails) : undefined);
  pushField("sigilo_payload", changes.sigiloPayload ? JSON.stringify(changes.sigiloPayload) : undefined);
  pushField("paid_at", changes.paidAt);

  if (!fields.length) {
    return findInvoiceByPublicToken(publicToken);
  }

  const { rows } = await pool.query(
    `
      update public.app_invoices
      set ${fields.join(", ")}
      where public_token = $1
      returning *
    `,
    values
  );

  return serializeInvoice(rows[0] || null);
};

export const updateInvoiceFromSigilo = async (publicToken, sigiloPayload) => {
  const transaction = sigiloPayload?.transaction || {};
  const pixInformation = sigiloPayload?.pix || sigiloPayload?.pixInformation || {};

  return updateInvoiceByPublicToken(publicToken, {
    sigiloTransactionId: sigiloPayload?.transactionId || transaction.id || null,
    sigiloOrderId: sigiloPayload?.order?.id || sigiloPayload?.orderId || null,
    sigiloPaymentMethod: transaction.paymentMethod || "PIX",
    sigiloStatus: transaction.status || sigiloPayload?.status || null,
    pixCode: pixInformation.code || pixInformation.qrCode || null,
    pixImage: pixInformation.image || null,
    status: resolveInvoiceStatus({
      status: transaction.status || sigiloPayload?.status || "pending",
      payedAt: transaction.payedAt || sigiloPayload?.payedAt || null,
      event: sigiloPayload?.event || transaction.event
    }),
    paidAt: transaction.payedAt || sigiloPayload?.payedAt || null,
    sigiloDetails: sigiloPayload?.details || null,
    sigiloPayload
  });
};

export const syncInvoiceWithSigilo = async (invoice, sigiloTransaction) => {
  if (!invoice) {
    return null;
  }

  const transaction = sigiloTransaction || {};
  const pixInformation = transaction.pixInformation || {};
  const status = resolveInvoiceStatus({
    status: transaction.status || invoice.sigiloStatus || "pending",
    payedAt: transaction.payedAt || invoice.paidAt || null,
    event: transaction.event
  });

  return updateInvoiceByPublicToken(invoice.publicToken, {
    sigiloTransactionId: transaction.id || invoice.sigiloTransactionId || null,
    sigiloOrderId: transaction.orderId || invoice.sigiloOrderId || null,
    sigiloPaymentMethod: transaction.paymentMethod || invoice.sigiloPaymentMethod || "PIX",
    sigiloStatus: transaction.status || invoice.sigiloStatus || null,
    pixCode: pixInformation.qrCode || invoice.pixCode || null,
    pixImage: pixInformation.image || invoice.pixImage || null,
    status,
    paidAt: transaction.payedAt || invoice.paidAt || null,
    sigiloDetails: transaction.details || invoice.sigiloDetails || null,
    sigiloPayload: transaction
  });
};
