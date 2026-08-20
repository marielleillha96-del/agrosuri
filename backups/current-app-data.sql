--
-- PostgreSQL database dump
--

\restrict RVoIeOagRQI1wuKSU2oUlArWcMv74s2ymZmMRC4II98dt3xR85q8z3Lt3FB2zdv

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.4 (Ubuntu 18.4-0ubuntu0.26.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.app_refresh_tokens DROP CONSTRAINT IF EXISTS app_refresh_tokens_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.app_client_tracking DROP CONSTRAINT IF EXISTS app_client_tracking_yard_id_fkey;
ALTER TABLE IF EXISTS ONLY public.app_client_tracking DROP CONSTRAINT IF EXISTS app_client_tracking_driver_id_fkey;
ALTER TABLE IF EXISTS ONLY public.app_client_tracking DROP CONSTRAINT IF EXISTS app_client_tracking_client_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.app_client_tracking DROP CONSTRAINT IF EXISTS app_client_tracking_catalog_item_id_fkey;
DROP TRIGGER IF EXISTS set_app_yards_updated_at ON public.app_yards;
DROP TRIGGER IF EXISTS set_app_users_updated_at ON public.app_users;
DROP TRIGGER IF EXISTS set_app_drivers_updated_at ON public.app_drivers;
DROP TRIGGER IF EXISTS set_app_client_tracking_updated_at ON public.app_client_tracking;
DROP TRIGGER IF EXISTS set_app_catalog_items_updated_at ON public.app_catalog_items;
DROP INDEX IF EXISTS public.app_yards_state_idx;
DROP INDEX IF EXISTS public.app_users_role_idx;
DROP INDEX IF EXISTS public.app_users_email_idx;
DROP INDEX IF EXISTS public.app_users_cpf_digits_idx;
DROP INDEX IF EXISTS public.app_refresh_tokens_user_id_idx;
DROP INDEX IF EXISTS public.app_refresh_tokens_expires_at_idx;
DROP INDEX IF EXISTS public.app_drivers_status_idx;
DROP INDEX IF EXISTS public.app_client_tracking_status_idx;
DROP INDEX IF EXISTS public.app_client_tracking_client_user_id_idx;
DROP INDEX IF EXISTS public.app_catalog_items_sections_idx;
DROP INDEX IF EXISTS public.app_catalog_items_category_idx;
ALTER TABLE IF EXISTS ONLY public.app_yards DROP CONSTRAINT IF EXISTS app_yards_pkey;
ALTER TABLE IF EXISTS ONLY public.app_users DROP CONSTRAINT IF EXISTS app_users_pkey;
ALTER TABLE IF EXISTS ONLY public.app_users DROP CONSTRAINT IF EXISTS app_users_email_key;
ALTER TABLE IF EXISTS ONLY public.app_users DROP CONSTRAINT IF EXISTS app_users_cpf_key;
ALTER TABLE IF EXISTS ONLY public.app_refresh_tokens DROP CONSTRAINT IF EXISTS app_refresh_tokens_token_hash_key;
ALTER TABLE IF EXISTS ONLY public.app_refresh_tokens DROP CONSTRAINT IF EXISTS app_refresh_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.app_drivers DROP CONSTRAINT IF EXISTS app_drivers_pkey;
ALTER TABLE IF EXISTS ONLY public.app_client_tracking DROP CONSTRAINT IF EXISTS app_client_tracking_tracking_code_key;
ALTER TABLE IF EXISTS ONLY public.app_client_tracking DROP CONSTRAINT IF EXISTS app_client_tracking_pkey;
ALTER TABLE IF EXISTS ONLY public.app_catalog_items DROP CONSTRAINT IF EXISTS app_catalog_items_slug_key;
ALTER TABLE IF EXISTS ONLY public.app_catalog_items DROP CONSTRAINT IF EXISTS app_catalog_items_pkey;
DROP TABLE IF EXISTS public.app_yards;
DROP TABLE IF EXISTS public.app_users;
DROP TABLE IF EXISTS public.app_refresh_tokens;
DROP TABLE IF EXISTS public.app_drivers;
DROP TABLE IF EXISTS public.app_client_tracking;
DROP TABLE IF EXISTS public.app_catalog_items;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_catalog_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_catalog_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    slug text NOT NULL,
    category text NOT NULL,
    sections text[] DEFAULT '{}'::text[] NOT NULL,
    price numeric(12,2) DEFAULT 0 NOT NULL,
    location text,
    year_label text,
    image_url text,
    whatsapp text,
    badge text,
    gallery_count integer DEFAULT 1 NOT NULL,
    description text,
    is_published boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    gallery_images jsonb DEFAULT '[]'::jsonb NOT NULL
);


--
-- Name: app_client_tracking; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_client_tracking (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    client_user_id uuid,
    client_name text NOT NULL,
    client_email text,
    catalog_item_id uuid,
    item_name text NOT NULL,
    driver_id uuid,
    yard_id uuid,
    tracking_code text NOT NULL,
    status text DEFAULT 'em separacao'::text NOT NULL,
    current_location text,
    expected_delivery_date date,
    notes text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    alert_message text
);


--
-- Name: app_drivers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_drivers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    full_name text NOT NULL,
    cpf text,
    cnh text,
    phone text,
    email text,
    status text DEFAULT 'ativo'::text NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    commercial_address text,
    photo_url text
);


--
-- Name: app_refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_refresh_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


--
-- Name: app_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    full_name text NOT NULL,
    email text NOT NULL,
    whatsapp text NOT NULL,
    cpf text NOT NULL,
    cep text NOT NULL,
    address text NOT NULL,
    number text NOT NULL,
    district text NOT NULL,
    complement text,
    city text,
    state text,
    password_hash text NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    role text DEFAULT 'customer'::text NOT NULL,
    photo_url text
);


--
-- Name: app_yards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_yards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    city text,
    state text,
    address text,
    contact_name text,
    contact_phone text,
    capacity_info text,
    notes text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


--
-- Data for Name: app_catalog_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_catalog_items (id, title, slug, category, sections, price, location, year_label, image_url, whatsapp, badge, gallery_count, description, is_published, created_at, updated_at, gallery_images) FROM stdin;
56379729-9b61-45ef-b3de-d04fee185ea8	Jonh deere 6150j	jonh-deere-6150j	Tratores	{destaques,relacionados,catalogo}	320000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1785194789/ywhgk4qdgyj9tvlmgbxk.jpg	\N	Máquinas	6	\N	t	2026-08-19 01:16:29.602845+00	2026-08-20 22:20:17.383263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1785194789/ywhgk4qdgyj9tvlmgbxk.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785194789/lw2zuhfyphhhelyiq2m6.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785194790/ynx847xhvd6aumlekfop.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785194791/basnecqnbnbj1uhzf6lf.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785194791/muxr2tuheydn4vqugesn.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785194792/cqwfte18poup9yeaos6e.jpg"]
d3f312f4-8f5a-48b6-9ecc-6c6d8829f8c0	Volvo Modelo L70F Ano 2021	volvo-modelo-l70f-ano-2021	Pás Carregadeiras	{catalogo,relacionados}	380000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784557637/qshd5ufbfabrrvmwb0bj.jpg	5542991645618	Máquinas	6	Pá carregadeira  Marca Volvo Modelo L70F Ano 2021 e 2022 Máquinas extra!   Valor 380.000 R$  à vista, ou financiamento pelo plano safra	t	2026-08-19 01:16:32.670502+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784557637/qshd5ufbfabrrvmwb0bj.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557638/h9yooaq4radkj17e7tcm.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557638/cps1vqytgovxp0tfr43i.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557639/yzc8tcubpxqyzjevomwb.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557639/wuf9rtm0etb4suqlzgd9.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557640/ssrviuw7vf4eikoauzzu.jpg"]
adb5851d-4908-4a80-a687-8f3967f189b0	CLIO EXPRESSION 1.0 16V	clio-expression-1-0-16v	Automóveis	{catalogo,relacionados}	24314.00	Ipiranga - PR	2015/2016	/catalogo-assets/clio-expression-1-0-16v/01.jpg	5542991645618	Carros	9	Marca: RENAULT\nModelo: CLIO\nVersão: CLIO EXPRESSION 1.0 16V\nAno de Fabricação: 2015\nAno Modelo: 2016	t	2026-08-18 22:14:40.434377+00	2026-08-19 01:45:22.303263+00	["/catalogo-assets/clio-expression-1-0-16v/01.jpg", "/catalogo-assets/clio-expression-1-0-16v/02.jpg", "/catalogo-assets/clio-expression-1-0-16v/03.jpg", "/catalogo-assets/clio-expression-1-0-16v/04.jpg", "/catalogo-assets/clio-expression-1-0-16v/05.jpg", "/catalogo-assets/clio-expression-1-0-16v/06.jpg", "/catalogo-assets/clio-expression-1-0-16v/07.jpg", "/catalogo-assets/clio-expression-1-0-16v/08.jpg", "/catalogo-assets/clio-expression-1-0-16v/09.jpg"]
63f0b6d9-e87e-45be-9948-804f366eb486	CIVIC EXR 2.0 16V I-VTEC	civic-exr-2-0-16v-i-vtec	Automóveis	{catalogo,relacionados}	70809.00	Ipiranga - PR	2015/2016	/catalogo-assets/civic-exr-2-0-16v-i-vtec/01.jpg	5542991645618	Carros	8	Marca: HONDA\nModelo: CIVIC\nCategoria: Automóveis\nVersão: CIVIC EXR 2.0 16V I-VTEC\nAno de Fabricação: 2015\nAno Modelo: 2016	t	2026-08-18 22:14:40.846141+00	2026-08-19 01:45:22.303263+00	["/catalogo-assets/civic-exr-2-0-16v-i-vtec/01.jpg", "/catalogo-assets/civic-exr-2-0-16v-i-vtec/02.jpg", "/catalogo-assets/civic-exr-2-0-16v-i-vtec/03.jpg", "/catalogo-assets/civic-exr-2-0-16v-i-vtec/04.jpg", "/catalogo-assets/civic-exr-2-0-16v-i-vtec/05.jpg", "/catalogo-assets/civic-exr-2-0-16v-i-vtec/06.jpg", "/catalogo-assets/civic-exr-2-0-16v-i-vtec/07.jpg", "/catalogo-assets/civic-exr-2-0-16v-i-vtec/08.jpg"]
e184fd87-8d30-46b6-897f-1bc2afa0288e	CITY LX 1.5 16V I-VTEC	city-lx-1-5-16v-i-vtec	Automóveis	{relacionados,catalogo}	30900.00	Ipiranga - PR	2016/2017	/catalogo-assets/city-lx-1-5-16v-i-vtec/08.jpg	5542991645618	Carros	8	\N	t	2026-08-18 22:14:40.02612+00	2026-08-19 01:45:22.303263+00	["/catalogo-assets/city-lx-1-5-16v-i-vtec/08.jpg", "/catalogo-assets/city-lx-1-5-16v-i-vtec/05.jpg", "/catalogo-assets/city-lx-1-5-16v-i-vtec/02.jpg", "/catalogo-assets/city-lx-1-5-16v-i-vtec/03.jpg", "/catalogo-assets/city-lx-1-5-16v-i-vtec/04.jpg", "/catalogo-assets/city-lx-1-5-16v-i-vtec/06.jpg", "/catalogo-assets/city-lx-1-5-16v-i-vtec/07.jpg", "/catalogo-assets/city-lx-1-5-16v-i-vtec/09.jpg"]
eaad4a6f-662e-478a-bfa1-ef2319ec9e21	SONIC SEDAN LTZ AT 1.6 16V - 2014	sonic-sedan-ltz-at-1-6-16v-2014	Automóveis	{relacionados,catalogo}	35401.00	Ipiranga - PR	2013/2014	/catalogo-assets/sonic-sedan-ltz-at-1-6-16v-2014/08.jpg	5542991645618	Carros	9	\N	t	2026-08-18 22:14:41.050091+00	2026-08-19 01:45:22.303263+00	["/catalogo-assets/sonic-sedan-ltz-at-1-6-16v-2014/08.jpg", "/catalogo-assets/sonic-sedan-ltz-at-1-6-16v-2014/01.jpg", "/catalogo-assets/sonic-sedan-ltz-at-1-6-16v-2014/02.jpg", "/catalogo-assets/sonic-sedan-ltz-at-1-6-16v-2014/03.jpg", "/catalogo-assets/sonic-sedan-ltz-at-1-6-16v-2014/04.jpg", "/catalogo-assets/sonic-sedan-ltz-at-1-6-16v-2014/05.jpg", "/catalogo-assets/sonic-sedan-ltz-at-1-6-16v-2014/06.jpg", "/catalogo-assets/sonic-sedan-ltz-at-1-6-16v-2014/07.jpg", "/catalogo-assets/sonic-sedan-ltz-at-1-6-16v-2014/09.jpg"]
9836ff38-9717-4297-8824-00b568524215	HB20S COMFORT	hb20s-comfort	Automóveis	{catalogo,destaques,relacionados}	23500.00	Ipiranga - PR	2017	/catalogo-assets/hb20s-comfort/03.jpg	5542991645618	Carros	9	\N	t	2026-08-18 22:14:39.821186+00	2026-08-19 01:45:22.303263+00	["/catalogo-assets/hb20s-comfort/03.jpg", "/catalogo-assets/hb20s-comfort/01.jpg", "/catalogo-assets/hb20s-comfort/02.jpg", "/catalogo-assets/hb20s-comfort/04.jpg", "/catalogo-assets/hb20s-comfort/05.jpg", "/catalogo-assets/hb20s-comfort/06.jpg", "/catalogo-assets/hb20s-comfort/07.jpg", "/catalogo-assets/hb20s-comfort/08.jpg", "/catalogo-assets/hb20s-comfort/09.jpg"]
fc3f0a0a-a397-4dac-a64b-2e2d70e8da1f	Trator Valtra A750 4x4	trator-valtra-a750-4x4	Tratores	{catalogo,destaques,relacionados}	145000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784556470/nyh9xnblzthjpbogb4ts.jpg	5542991645618	Máquinas	5	A 750 Ano: 2018\n2.300 horas	t	2026-08-19 01:16:34.735979+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784556470/nyh9xnblzthjpbogb4ts.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556471/nn6f1kb6zcrrtcxpcaoq.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556472/iygqlhdiljmmawn5pyid.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556472/stmaaenolumqamilxzn7.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556473/m8z3qsxjcfsqebb7yjx4.jpg"]
563004a1-0fa3-4a21-8b1f-b389de50b4c8	RETROESCAVADEIRA JCB 4CX	retroescavadeira-jcb-4cx	Retroescavadeiras	{catalogo,destaques,relacionados}	210000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1785193381/hgkr5cszbyhjxoeevpnl.jpg	5542991645618	Máquinas	8	Ano – 2022\n✅ Modelo: JCB 4CX\n✅ Único dono\n✅ Motor novo\n✅ 17.350 horas\n✅ Funcionando perfeitamente, pronta para entrar em operação.\n💳 Financiamento disponível junto ao Banco BV Financeira, com condições facilitadas.	t	2026-08-19 01:16:30.202413+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1785193381/hgkr5cszbyhjxoeevpnl.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193382/o0mctmc8jlpvbsahen3g.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193383/eape26xdobodxqjnijap.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193384/u3wqibo6owc0zw7dgafg.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193384/zknmvgjozofzpmjrfu01.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193385/si8yhfvchnrpvdaezyia.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193386/vzzr6qmbiiudk3lrika9.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193387/tkf7uewg9if9z9wbj7vq.jpg"]
299784f1-dc54-4fa2-8cf4-ed0a756446db	STRADA CD ADVENTURE 1.8 16V	strada-cd-adventure-1-8-16v	Picapes Pequenas	{catalogo,destaques,relacionados}	45930.00	Ipiranga - PR	2013/2014	/catalogo-assets/strada-cd-adventure-1-8-16v/01.jpg	5542991645618	Carros	9	Marca: FIAT\nModelo: STRADA CD\nVersão: STRADA CD ADVENTURE 1.8 16V\nAno de Fabricação: 2013\nAno Modelo: 2014\nTipo de Documento: Normal\nTipo de Chassi: Normal\nChave: Sim\nFinal de Placa: 5\nCombustível: FLEXÍVEL ÁLCOOL/GASOLINA	t	2026-08-18 22:14:41.254394+00	2026-08-19 01:45:22.303263+00	["/catalogo-assets/strada-cd-adventure-1-8-16v/01.jpg", "/catalogo-assets/strada-cd-adventure-1-8-16v/02.jpg", "/catalogo-assets/strada-cd-adventure-1-8-16v/03.jpg", "/catalogo-assets/strada-cd-adventure-1-8-16v/04.jpg", "/catalogo-assets/strada-cd-adventure-1-8-16v/05.jpg", "/catalogo-assets/strada-cd-adventure-1-8-16v/06.jpg", "/catalogo-assets/strada-cd-adventure-1-8-16v/07.jpg", "/catalogo-assets/strada-cd-adventure-1-8-16v/08.jpg", "/catalogo-assets/strada-cd-adventure-1-8-16v/09.jpg"]
c7ab1c69-5ba5-4fae-bda0-f3099874bbbb	COROLLA GLI CVT 1.8 16V	corolla-gli-cvt-1-8-16v	Automóveis	{relacionados,catalogo}	36000.00	Ipiranga - PR	2016/2017	/catalogo-assets/corolla-gli-cvt-1-8-16v/07.jpg	5542991645618	Carros	8	\N	t	2026-08-18 22:14:39.61783+00	2026-08-19 01:45:22.303263+00	["/catalogo-assets/corolla-gli-cvt-1-8-16v/07.jpg", "/catalogo-assets/corolla-gli-cvt-1-8-16v/01.jpg", "/catalogo-assets/corolla-gli-cvt-1-8-16v/02.jpg", "/catalogo-assets/corolla-gli-cvt-1-8-16v/03.jpg", "/catalogo-assets/corolla-gli-cvt-1-8-16v/04.jpg", "/catalogo-assets/corolla-gli-cvt-1-8-16v/05.jpg", "/catalogo-assets/corolla-gli-cvt-1-8-16v/06.jpg", "/catalogo-assets/corolla-gli-cvt-1-8-16v/08.jpg"]
60f9d4c1-7416-4d72-9e9d-f71a09fe2882	SAVEIRO CD CROSS 1.6 16V	saveiro-cd-cross-1-6-16v	Picapes Pequenas	{catalogo,destaques,relacionados}	60915.00	Ipiranga - PR	2016/2017	/catalogo-assets/saveiro-cd-cross-1-6-16v/01.jpg	5542991645618	Carros	8	Marca: VOLKSWAGEN\nModelo: SAVEIRO CD\nCategoria: Picapes Pequenas\nVersão: SAVEIRO CD CROSS 1.6 16V\nAno de Fabricação: 2016\nAno Modelo: 2017\nFIPE: R$ 60.915,00	t	2026-08-18 22:14:39.392266+00	2026-08-19 01:45:22.303263+00	["/catalogo-assets/saveiro-cd-cross-1-6-16v/01.jpg", "/catalogo-assets/saveiro-cd-cross-1-6-16v/02.jpg", "/catalogo-assets/saveiro-cd-cross-1-6-16v/03.jpg", "/catalogo-assets/saveiro-cd-cross-1-6-16v/04.jpg", "/catalogo-assets/saveiro-cd-cross-1-6-16v/05.jpg", "/catalogo-assets/saveiro-cd-cross-1-6-16v/06.jpg", "/catalogo-assets/saveiro-cd-cross-1-6-16v/07.jpg", "/catalogo-assets/saveiro-cd-cross-1-6-16v/08.jpg"]
b24ecf56-602d-47ca-b58f-fa78e2170a08	CARRETA AGRÍCOLA BASCULANTE 6 TONELADAS	carreta-agricola-basculante-6-toneladas	Implementos	{catalogo,destaques,relacionados}	28000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784558220/xjxwxoelgrg6b7xivmrp.jpg	5542991645618	Máquinas	7	CARRETA AGRÍCOLA BASCULANTE 6 TONELADAS\nEquipamento em excelente estado de conservação, revisado e pronto para o trabalho. Ideal para transporte de grãos, silagem e adubo, garantindo praticidade e eficiência no dia a dia da propriedade.\nEspecificações: • Capacidade de carga: 6 toneladas / 7 m³\n* 2 eixos separados (maior estabilidade)\n* Rodado aro 16\n* Medidas: 3.500 x 2.000 x 1.000 mm\n* Estrutura reforçada\n* Sistema hidráulico funcionando perfeitamente\nVALOR À VISTA: R$ 28.000,00	t	2026-08-19 01:16:32.154133+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784558220/xjxwxoelgrg6b7xivmrp.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784558221/fptppysatzkplnsiozaf.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784558222/uyje00qhhokpqvkcdu83.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784558223/puamnb413otwcwoul7rh.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784558223/u0in9fndmhknlzssbrpk.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784558224/cdjjy3qvdqjhurpd5ca3.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784558225/t3pzzzwnyscbjsl56uin.jpg"]
07e256dc-001c-4646-bcf4-9ab844964460	Colheitadeira New Holland TC 5090	colheitadeira-new-holland-tc-5090	Colheitadeiras	{catalogo,destaques,relacionados}	410000.00	Ipiranga - PR	2012	https://res.cloudinary.com/dihm0krca/image/upload/v1785193587/g0oxctvi8ctgjykqmpc9.jpg	5542991645618	Máquinas	8	✅ Ano: 2012\n✅ Horas de trilha: 1.200 h\n✅ Horas de motor: 1.600 h\n✅ Peneira fixa\n✅ Rodados duplos\n✅ Nunca colheu milho	t	2026-08-19 01:11:12.940497+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1785193587/g0oxctvi8ctgjykqmpc9.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193587/mqvukshe7jaa5dfwf1jf.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193588/etxkb1umptht3kv6ktgc.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193589/e9cyhrygnhginupmvqpr.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193589/u4ejm3bjfx3hwj4kuyav.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193590/qvvmpu10tabjgph8axqf.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193591/w1izw9hqtpozoisyz5wu.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785193591/ds1lhmw7ltuixmol3m9q.jpg"]
75e58f0e-1f7d-46e3-bf20-87978e48ed00	GRADE ARADORA TATU 16x28 – 2025	grade-aradora-tatu-16x28-2025	Implementos	{catalogo,destaques,relacionados}	19950.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784745409/o4ydb95plzj8irtgcwqc.jpg	5542991645618	Máquinas	3	Equipamento novo, nunca usado, em estado impecável e pronto para o trabalho.\n* Espaçamento: 270 mm\n* 100% funcional\n* Estrutura reforçada	t	2026-08-19 01:16:31.393758+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784745409/o4ydb95plzj8irtgcwqc.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784745410/cyfay7vcpyrnngah8pht.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784745411/eahqng1dfwposi1t6azb.jpg"]
716f40de-ccc2-4549-8c66-01a378eb90c4	HILUX SW4 SRX 2.8 D-4D	hilux-sw4-srx-2-8-d-4d	SUV Grandes	{catalogo,destaques,relacionados}	94000.00	Ipiranga - PR	2016	/catalogo-assets/hilux-sw4-srx-2-8-d-4d/03.jpg	5542991645618	Carros	9	\N	t	2026-08-18 22:14:40.223148+00	2026-08-19 01:45:22.303263+00	["/catalogo-assets/hilux-sw4-srx-2-8-d-4d/03.jpg", "/catalogo-assets/hilux-sw4-srx-2-8-d-4d/01.jpg", "/catalogo-assets/hilux-sw4-srx-2-8-d-4d/02.jpg", "/catalogo-assets/hilux-sw4-srx-2-8-d-4d/04.jpg", "/catalogo-assets/hilux-sw4-srx-2-8-d-4d/05.jpg", "/catalogo-assets/hilux-sw4-srx-2-8-d-4d/06.jpg", "/catalogo-assets/hilux-sw4-srx-2-8-d-4d/07.jpg", "/catalogo-assets/hilux-sw4-srx-2-8-d-4d/08.jpg", "/catalogo-assets/hilux-sw4-srx-2-8-d-4d/09.jpg"]
8517f3c7-d1b0-454b-af29-c7cc3ed75387	Mercedes GLA 200 1.6 16V	mercedes-gla-200-1-6-16v	Automóveis	{catalogo,destaques,relacionados}	128859.00	Ipiranga - PR	2015/2016	/catalogo-assets/mercedes-gla-200-1-6-16v/04.jpg	5542991645618	Carros	9	\N	t	2026-08-18 22:14:40.632686+00	2026-08-19 01:45:22.303263+00	["/catalogo-assets/mercedes-gla-200-1-6-16v/04.jpg", "/catalogo-assets/mercedes-gla-200-1-6-16v/01.jpg", "/catalogo-assets/mercedes-gla-200-1-6-16v/02.jpg", "/catalogo-assets/mercedes-gla-200-1-6-16v/03.jpg", "/catalogo-assets/mercedes-gla-200-1-6-16v/05.jpg", "/catalogo-assets/mercedes-gla-200-1-6-16v/06.jpg", "/catalogo-assets/mercedes-gla-200-1-6-16v/07.jpg", "/catalogo-assets/mercedes-gla-200-1-6-16v/08.jpg", "/catalogo-assets/mercedes-gla-200-1-6-16v/09.jpg"]
fcb4ca6a-8f94-4f5c-a278-9bc2f64cd2d8	Retroescavadeira Cat 416E	retroescavadeira-cat-416e	Retroescavadeiras	{catalogo,destaques,relacionados}	100000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784557707/beejhrjw8cnc5iml3hj6.jpg	5542991645618	Máquinas	8	\N	t	2026-08-19 01:16:32.382115+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784557707/beejhrjw8cnc5iml3hj6.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557703/slvb3hqiqzcnofsqxm9a.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557704/rvx3mcsxnm5bhsuqoq5i.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557705/zarlkhg3rgmlm6vd3ryh.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557705/n2jy4v9lpijj1v2y2oot.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557706/e6jb0i3zskawkk7trrxd.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557706/wk1juhzevypxkgd41veq.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557707/kr24rvslaeewvrtxkdal.jpg"]
3fea73c5-a65e-42b2-90bc-85e89b068585	•New holland 7630	new-holland-7630	Tratores	{catalogo,relacionados}	195000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784898783/z9wpaxxrytp5utjweelq.jpg	5542991645618	Máquinas	4	HORAS: 206 - ANO 2023\nTodo original \n150cv	t	2026-08-19 01:16:30.454593+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784898783/z9wpaxxrytp5utjweelq.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898784/pd87xus4d9ymecxajjzb.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898785/qwlfxrzagqcchitahle7.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898786/pkigq6ccvbmwkqmtkcep.jpg"]
6711c0b4-7d7d-4673-830d-14355ee247ab	MASSEY FERGUSON 275 CAFEEIRO	massey-ferguson-275-cafeeiro	Tratores	{relacionados,catalogo}	65000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784898439/yznrajke6rnstyf7084a.jpg	\N	Máquinas	5	\N	t	2026-08-19 01:16:30.708578+00	2026-08-20 22:19:47.41234+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784898439/yznrajke6rnstyf7084a.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898437/thcjmhbwesqffq7atlxb.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898437/jthtd5b4ntqtxxkdvk5s.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898438/i6mamrvtihbgiivyz3wt.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898441/iolpgcwd96kvdcsjxir6.jpg"]
acccb623-5d39-47f1-86b8-9f36b2f3003d	JONH DEERE 7505 (140cv)	jonh-deere-7505-140cv	Tratores	{relacionados,catalogo}	75000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1785194690/qsorj5nxwbsewr5m2dhj.jpg	\N	Máquinas	4	\N	t	2026-08-19 01:16:29.890656+00	2026-08-20 22:20:09.144657+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1785194690/qsorj5nxwbsewr5m2dhj.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785194689/l3c9ddanjwbhpsgcrdwv.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785194690/arvam14vaymjbtz23e17.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1785194691/qtxftxyiyvodrzu80ig3.jpg"]
db81b6b5-d2a0-4eef-b5db-f3fc8d3444fd	Trator Massey Ferguson 275 - 1995	trator-massey-ferguson-275-1995	Tratores	{catalogo,relacionados}	50000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784898345/dnina7rmpp5xmhpawnbl.jpg	5542991645618	Máquinas	6	✅Trator Massey Ferguson 275✅\n\n✅Ano 1995\n✅Motor de 75 cv\n✅Câmbio 3 alavanca\n\nBem calçado de pneus.\nHidráulico e tomada de força ok\n\nBom de mecânica	t	2026-08-19 01:16:30.906942+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784898345/dnina7rmpp5xmhpawnbl.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898346/r7rxvqaottyzw88fepkw.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898347/zljmzr1cjjr4kvicnoqs.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898347/il3xz8cawe6anua4bnhs.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898348/bknyamvnzrjrcye3ovgm.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898349/p6f0qjvbtytsudaowdkj.jpg"]
8886a02c-4895-4354-a656-b167cbe2482a	Pa-Carregadera Volto L70F	pa-carregadera-volto-l70f	Pás Carregadeiras	{catalogo,relacionados}	380000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784744931/jojsgydj7g5tfrsldte9.jpg	5542991645618	Máquinas	6	Pá carregadeira \nMarca Volvo\nModelo L70F\nAno 2021 e 2022\nMáquinas extra!	t	2026-08-19 01:16:31.82768+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784744931/jojsgydj7g5tfrsldte9.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784744932/egbnfrtixffilj67df9t.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784744933/smkbm7hsgpa5c68jmwnl.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784744933/kwcmixtwjh7zmnihnu45.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784744934/ehzsthkgf3qwqsqt1rof.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784744935/urhb0ojutwby60onqmla.jpg"]
3c72277f-6a51-4bd6-be44-87c5b7dce955	John Deere 5078E + Carregadeira JD 562	john-deere-5078e-carregadeira-jd-562	Tratores	{relacionados,catalogo}	164500.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784898047/brjhpi6pwu17d5sxfji4.jpg	\N	Máquinas	6	\N	t	2026-08-19 01:16:31.198178+00	2026-08-20 22:20:00.384354+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784898047/brjhpi6pwu17d5sxfji4.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898044/ngsmiqblqcpcq7z875hv.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898045/abo5sspevd02lysans72.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898045/bqt8yxdogrpiyrrmpd1h.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898046/fv5ilcarot3emvtr1tkc.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784898048/bwsrqbdjwwzmogd5czo9.jpg"]
35f6c35e-8227-4f6a-a8ab-8554bce86b29	Trator Massey Ferguson 275	trator-massey-ferguson-275	Tratores	{catalogo,relacionados}	77000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784557202/jce2lszgeiyl2i9xkmdi.jpg	5542991645618	Máquinas	5	DAMOS GARANTIA DE MOTOR E CÂMBIO\n1 ANO(75cv)Ano 2006-Horas 8.000	t	2026-08-19 01:16:33.992852+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784557202/jce2lszgeiyl2i9xkmdi.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557203/aubpe9eisjny0qywhcnv.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557204/kgywqduardothi0psitw.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557204/hbo2qtmdc5bvmw1ysh0v.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557205/kt5b1vyn6txd34pi7srd.jpg"]
76aae60f-7634-472f-bebb-1cf72201ba32	trator Valtra A950 4x4 95cv	trator-valtra-a950-4x4-95cv	Tratores	{catalogo,relacionados}	155000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784557047/pofriq2lr8t65kj40zkq.jpg	5542991645618	Máquinas	6	Ano:2015\nMotor 4cc/bomba injetora Bosch\nBarramento hidráulico/TDP/02 VCR's\n100% operacional \nSuper Redutor De Velocidade	t	2026-08-19 01:16:34.320975+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784557047/pofriq2lr8t65kj40zkq.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557048/rhjzgdmxbgntx0vz7dxy.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557048/r2gvkimhz0nqliicwiv5.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557049/ljnxfk5dbbmiu6vuod2n.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557049/k5scp8mg3hl6wtntbx2i.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557050/jjvpsrrscxj7zte6ad77.jpg"]
e52718c4-780e-46b1-ac01-81ef5321c62b	NewHoland 7630, Ano 2001	newholand-7630-ano-2001	Tratores	{relacionados,catalogo}	70000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784557476/rigm0wlnkrhubchlacg1.jpg	\N	Máquinas	3	\N	t	2026-08-19 01:16:33.177247+00	2026-08-20 22:19:30.759028+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784557476/rigm0wlnkrhubchlacg1.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557475/uof3x8pjkz7fgmgy5bvm.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557475/fqfzipk5nogsso8lwsnf.jpg"]
51cc5210-9b66-49f8-b82f-888fb3b77402	Case IH Farmall 110A (118 cv)	case-ih-farmall-110a-118-cv	Tratores	{relacionados,catalogo}	220000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784745209/injwx2jg9kuhehpzfanp.jpg	5542991645618	Máquinas	8	\N	t	2026-08-19 01:16:31.608275+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784745209/injwx2jg9kuhehpzfanp.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784745204/ff9fie6afwe0paotpn04.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784745205/cwswkhq3p2jlvr37waif.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784745206/uc4affelwyzi3jlfirkt.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784745207/ho6jruhyulollu1z5tp9.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784745208/bi6wvalnfntozaaxgqub.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784745210/lmqcava2c5jf2or3hfwk.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784745210/hwnbhjt3jk82fspqvng6.jpg"]
80803b57-a465-4a6c-9763-290c12dafa8e	Massey Ferguson 4275  4x4-Ano:2013	massey-ferguson-4275-4x4-ano-2013	Tratores	{catalogo,relacionados}	104000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784557571/ere2nbaxx9p8fnabxjan.jpg	5542991645618	Máquinas	8	trator Massey Ferguson 4275  4x4-Ano:2013 \nTração Central 4x4\nBarramento hidráulico/TDP/02 VCR's\n4.771 horas	t	2026-08-19 01:16:32.954031+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784557571/ere2nbaxx9p8fnabxjan.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557573/scu7uzzn6clq8dzejpks.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557573/xjvqouoyxvk6jcg43hn1.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557574/vw4twfvwwmjapusmrml4.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557575/k0wuayzddgf6adkl2zqk.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557575/ngecnaaugvlxea8xdeyt.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557577/kmrms5mxldlja1g4cdyx.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557577/odqe1aydgwjkrsp9059w.jpg"]
f13f8502-4c76-47a4-87da-acf626c9a768	MASSEY FERGUSON 290 4x2 ANO 1980 COM LAMINA	massey-ferguson-290-4x2-ano-1980-com-lamina	Tratores	{catalogo,relacionados}	48000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784557397/za3kjubyqdv2myxth5j8.jpg	5542991645618	Máquinas	7	Original e revisada.\nCom garantia e procedência.\nTRATOR MASSEY FERGUSON 290 ANO 1980\nREALIZAMOS FINANCIAMETOS	t	2026-08-19 01:16:33.402671+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784557397/za3kjubyqdv2myxth5j8.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557398/g52gu0zkocfks3dpbnm4.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557399/goxrce4fn7gdmtejvxh2.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557399/g1bwfh6smmr6z464rmm0.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557400/b0w7tahnwe8ragaeo8xa.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557401/yl9j8mikmekdtnpukudr.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557401/vrrq69fyxkjiglnuganr.jpg"]
0457af06-1bce-450b-95f6-2cc3df21e271	Massey ferguson 290 (4x4)	massey-ferguson-290-4x4	Tratores	{catalogo,relacionados}	95000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784557328/rhuzxxiixnvpzlbv0ed4.jpg	5542991645618	Máquinas	5	✅Ano 2005 \n✅Pneus bons \n✅Revisado funciona perfeitamente \n✅Conjunto frontal de concha	t	2026-08-19 01:16:33.690307+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784557328/rhuzxxiixnvpzlbv0ed4.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557329/b6dk1rr4kmhxlyrcs3nt.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557329/tqmklqi6jsmiohsgditq.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557330/t55658op4gybbdpmppsp.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784557330/v1zatu3ydm7daqgk8h47.jpg"]
bf4b2775-084a-4818-a790-fd3d57a1b209	TRATOR MASSEY FERGUSON 292-ANO 2008	trator-massey-ferguson-292-ano-2008	Tratores	{catalogo,relacionados}	95000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784556974/zi8bdjhgig96fk0mfhym.jpg	5542991645618	Máquinas	6	TRATOR MASSEY FERGUSON 292-ANO 2008-LAMINA\n\nO VALOR DO TRATOR 💲 VALORR$95.000.00\nREALIZAMOS FINANCIAMENTO	t	2026-08-19 01:16:34.540195+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784556974/zi8bdjhgig96fk0mfhym.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556975/xwjrkpa29o8selq751he.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556975/zymc6uvj7bpv3juff12j.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556976/xxd9j1ktx7smbodb7xue.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556977/gfoo3ujz7vxxxcoxwfuj.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556977/rqfe1iow4xyyxis2kkmq.jpg"]
11471f7e-66e4-4319-b30b-384d98c37b63	MASSEY FERGUSON 4290 – 2015	massey-ferguson-4290-2015	Tratores	{catalogo,relacionados}	120000.00	Ipiranga - PR	\N	https://res.cloudinary.com/dihm0krca/image/upload/v1784556352/g1x40ojacvrp6rowaey1.jpg	5542991645618	Máquinas	7	MASSEY FERGUSON 4290 – 2015 | CABINADO\nTrator em excelente estado de conservação, pronto para o trabalho!\nPrincipais características: • Cabine fechada (mais conforto e segurança)\n* Comando duplo\n* Pneus novos\n* Pesos traseiros e dianteiros\n* Máquina revisada e bem cuidada\nDocumentação: • Possui nota fiscal de origem\n* Manual disponivel	t	2026-08-19 01:16:34.986445+00	2026-08-19 01:45:22.303263+00	["https://res.cloudinary.com/dihm0krca/image/upload/v1784556352/g1x40ojacvrp6rowaey1.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556353/b9vgaqzum9t9cgkutnpd.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556354/ltn7ustriwnamuwio6js.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556355/f4phszozwgvfq8oueznl.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556355/vkjm5mlwb2vhx74uleon.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556356/aq6hd5qm6ub35ix7ilvb.jpg", "https://res.cloudinary.com/dihm0krca/image/upload/v1784556357/siuehf8o2y09ibgq4b7z.jpg"]
\.


--
-- Data for Name: app_client_tracking; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_client_tracking (id, client_user_id, client_name, client_email, catalog_item_id, item_name, driver_id, yard_id, tracking_code, status, current_location, expected_delivery_date, notes, created_at, updated_at, alert_message) FROM stdin;
3b8435fc-0fb1-4973-ac8a-14d5cd8cae86	db7c92e8-eb22-41a5-9418-ac20c8becbf2	PEDRO BENETTO	pedro@teste.com	63f0b6d9-e87e-45be-9948-804f366eb486	CIVIC EXR 2.0 16V I-VTEC	d633881f-e3d2-4819-a081-c5d44545b5e0	f3ad854c-3384-4dfc-8e89-1b2195cfba92	5443325532	Aguardando nota fiscal	Rua teste	2027-01-03	\N	2026-08-18 23:07:13.879726+00	2026-08-18 23:07:13.879726+00	Aguardando nota fiscal
7155be70-0a4d-4360-aa97-c5884f2f64d7	\N	Cliente Rastreio Demo	cliente.rastreio@agromaquinasipiranga.com.br	\N	SAVEIRO CD CROSS 1.6 16V	d633881f-e3d2-4819-a081-c5d44545b5e0	f3ad854c-3384-4dfc-8e89-1b2195cfba92	AMI-0001	Aguardando nota fiscal	Caçapava, SP	2026-08-22	Carga liberada e aguardando emissão final da nota fiscal para seguir viagem.	2026-08-18 22:42:46.55176+00	2026-08-20 22:19:02.561017+00	\N
9c098cc9-c9c3-422b-a548-b6dfc0bae138	be967cff-0975-454b-a87a-ae6a15cd33d7	Teresina Piauí	joelton@gmail.com	fc3f0a0a-a397-4dac-a64b-2e2d70e8da1f	Trator Valtra A750 4x4	490cafd8-6382-4158-82ca-739d8eb7d08c	f3ad854c-3384-4dfc-8e89-1b2195cfba92	65562	Em andamento	Rua 7 de Dezembro 140, Centro, Ipiranga - PR, 84450-000, Ipiranga - PR	2026-09-10	Destino final: Mauá, SP	2026-08-20 22:22:54.817285+00	2026-08-20 22:22:54.817285+00	Aguardando nota fiscal
\.


--
-- Data for Name: app_drivers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_drivers (id, full_name, cpf, cnh, phone, email, status, notes, created_at, updated_at, commercial_address, photo_url) FROM stdin;
d633881f-e3d2-4819-a081-c5d44545b5e0	Leandro Teixeira Fernandes	987.654.321-00	Categoria D	(12) 99737-1569	leandro.fernandes@agromaquinasipiranga.com.br	Situação regular	Motorista responsável pela entrega monitorada do cliente demo.	2026-08-18 22:42:45.649551+00	2026-08-18 22:42:45.649551+00	\N	\N
eeb8faac-762c-4ac5-a47d-4768b84fb0c8	TESTE	42536166821	D	119999999	teste@gmail.com	ativo	\N	2026-08-18 22:59:19.264476+00	2026-08-18 22:59:19.264476+00	\N	\N
a121c2a7-a7d0-42c5-b923-976ec4de8d63	PEDRO FARIAS	464.220.118-14	D	1199999999	pedroca@gmail.com	Situação regular	\N	2026-08-19 19:14:52.679421+00	2026-08-19 19:14:52.679421+00	Rua São João, 795	data:image/jpeg;base64,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
490cafd8-6382-4158-82ca-739d8eb7d08c	PEDRO FARIAS	464.220.118-14	D	1199999999	pedroca@gmail.com	Situação regular	\N	2026-08-19 19:14:52.880686+00	2026-08-19 19:14:52.880686+00	Rua São João, 795	data:image/jpeg;base64,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
\.


--
-- Data for Name: app_refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_refresh_tokens (id, user_id, token_hash, expires_at, revoked_at, created_at) FROM stdin;
d3764bde-1c84-4dc0-9721-d4817aa2ed3f	8cfdba65-596d-4cb2-a770-81c41eee7262	b8ad0672f307437369739c4863c5f51ca10bcca77f57171f6bf10a6357344faa	2026-09-17 12:59:46.235382+00	\N	2026-08-18 12:59:46.235382+00
f8daea2e-d84d-4a68-8215-873a3f262d81	8cfdba65-596d-4cb2-a770-81c41eee7262	c8464804943a86c19441358edab87f04ff7bb8e9f2fe7fd6ecb08733d86d6ad7	2026-09-17 12:59:53.477233+00	\N	2026-08-18 12:59:53.477233+00
2359e596-04f8-4c98-8136-a30ed2fa4b2b	8cfdba65-596d-4cb2-a770-81c41eee7262	83a03ef3eff5cae108109ba8b8507a1f9d0d7979905fc99db3b35138adac3821	2026-09-17 17:21:54.600117+00	\N	2026-08-18 17:21:54.600117+00
e886a507-a770-488e-807a-38b729ba7d04	8cfdba65-596d-4cb2-a770-81c41eee7262	df428886c0236ccde77981d37c2d6502c3f16da7a653c94b03c96ac4a84fbec2	2026-09-17 17:37:58.580064+00	\N	2026-08-18 17:37:58.580064+00
823f234c-63a8-4501-a187-69250a1fcfae	8cfdba65-596d-4cb2-a770-81c41eee7262	6cacfd2e0c9e03744dead5e367a30579c4cf6e00819a4f203f52bcc114006827	2026-09-17 17:49:33.109746+00	\N	2026-08-18 17:49:33.109746+00
7992ef2a-d3f4-4fa6-9b71-f88aa40e1f78	8cfdba65-596d-4cb2-a770-81c41eee7262	19cfba16c246b7b4711bf67892f943c7091ba472c28e29e446f71fa6b3260b8c	2026-09-17 22:54:27.702906+00	\N	2026-08-18 22:54:27.702906+00
d72505ef-4c33-455d-b85d-cfd81a544d39	8cfdba65-596d-4cb2-a770-81c41eee7262	b0cebea5d3d68371b1e2171f1d9451473cf36409648eb106f3736b0cb8343ab6	2026-09-17 22:57:15.989311+00	\N	2026-08-18 22:57:15.989311+00
24fd6545-0ab2-4dfe-a476-08de6fd5f4ca	8cfdba65-596d-4cb2-a770-81c41eee7262	873138abafa0e2e18b9e02922b2662c0e78037c436cdc94b1a8fe8d18ef4b2f1	2026-09-17 22:57:16.736011+00	\N	2026-08-18 22:57:16.736011+00
03154cdc-4592-4780-977d-c980600d1a61	8cfdba65-596d-4cb2-a770-81c41eee7262	486291010c507127a96ee5fbae7ebdc71a51429e2b78fd55179fa398fbe6ebc7	2026-09-17 22:57:55.022594+00	\N	2026-08-18 22:57:55.022594+00
e2804d9e-76e6-43b4-95c7-61ce9aca3387	8cfdba65-596d-4cb2-a770-81c41eee7262	736a0cf2de72ade4136bfce886fc685ca0456a58e4681605071e33ca384bb298	2026-09-17 22:57:55.871394+00	\N	2026-08-18 22:57:55.871394+00
1c2d974d-ce4a-4d4c-b9c8-aebf3140e835	8cfdba65-596d-4cb2-a770-81c41eee7262	bb135b38770a873c0a9bed54a09ca8f3a654f4c6afe5e7a6300964ed42706f49	2026-09-17 22:59:29.139549+00	\N	2026-08-18 22:59:29.139549+00
fe21795c-d3e4-45c9-8510-c76b9e408f80	db7c92e8-eb22-41a5-9418-ac20c8becbf2	fbae23fa6ac50e771f2bc160e803f20e9745b1c8ca37728b7b736dc37ea022c0	2026-09-17 23:06:27.174208+00	\N	2026-08-18 23:06:27.174208+00
6571f9a0-887c-4acb-bddf-21f9cde0a7fe	db7c92e8-eb22-41a5-9418-ac20c8becbf2	146f8ec22ed1c15544b32ec1370136c485308242d0a5dbb64be7c96ea0c17261	2026-09-17 23:07:23.776915+00	2026-08-18 23:07:24.160775+00	2026-08-18 23:07:23.776915+00
e5bb225d-7c76-41ab-8d1f-e55e9a3d5aec	db7c92e8-eb22-41a5-9418-ac20c8becbf2	1d4f8b62e87fdd9b2106c368c8b83fce299c955af27502b283797e18107ed1dc	2026-09-17 23:07:24.221069+00	2026-08-18 23:07:24.557182+00	2026-08-18 23:07:24.221069+00
04493c51-7293-48d7-90ae-0f036a5707e7	db7c92e8-eb22-41a5-9418-ac20c8becbf2	ffea65d6a31c13af58394befca86192c9244bab5fd31ab9f525a86a9ca939bfd	2026-09-17 23:09:26.674238+00	\N	2026-08-18 23:09:26.674238+00
fc8a0268-caff-4281-a78c-af621a6e7897	8cfdba65-596d-4cb2-a770-81c41eee7262	1d5e396f18a69ee8fa4256718798cb2ec63ed7a2da64b931b2cacfbb64fcc2b8	2026-09-18 01:59:41.458739+00	\N	2026-08-19 01:59:41.458739+00
7ccd14a6-e4c4-4a50-990a-f867fba111ae	8cfdba65-596d-4cb2-a770-81c41eee7262	b52071060148dbb4a5c7d4de0859cbb22e40b578eee7a308b6df7cdf884e3252	2026-09-19 13:51:35.375559+00	\N	2026-08-20 13:51:35.375559+00
d4e9fb4c-575b-47d6-934d-e5164f083e32	be967cff-0975-454b-a87a-ae6a15cd33d7	475462031d91082fb3386e67d2df679cd98f859442c82dcfe313490356792b5d	2026-09-19 22:22:10.261821+00	\N	2026-08-20 22:22:10.261821+00
\.


--
-- Data for Name: app_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_users (id, full_name, email, whatsapp, cpf, cep, address, number, district, complement, city, state, password_hash, created_at, updated_at, role, photo_url) FROM stdin;
8cfdba65-596d-4cb2-a770-81c41eee7262	Administrador Agro Maquinas Ipiranga	admin@agromaquinasipiranga.com.br	(43) 99999-9999	000.000.000-00	00000-000	Painel Administrativo	S/N	Centro	\N	Ipiranga	PR	$2b$12$Zn62/KwaN3OcYLfGUcpHfO7nUZUbxAJY5kGN601yqS6tReI.lyPJq	2026-08-18 12:59:45.537863+00	2026-08-18 12:59:45.537863+00	admin	\N
db7c92e8-eb22-41a5-9418-ac20c8becbf2	PEDRO BENETTO	pedro@teste.com	1199999999	48017548592	09330800	Teste de rua	391	Bairro teste	03	Sao Paulo	SP	$2b$12$b9NhGcrZsuvkbQ0YsSXof.fylzu42EQgUazuSdFSzdZUKEs1cm7S.	2026-08-18 23:06:27.112509+00	2026-08-18 23:06:27.112509+00	customer	\N
be967cff-0975-454b-a87a-ae6a15cd33d7	Teresina Piauí	joelton@gmail.com	(11) 9999-9999	485.466.511-22	09340-600	Rua José Ferrari	10	Jardim Estrela	03	Mauá	SP	$2b$12$/XZ2yF1.YU409FXr8IIVeOJ3J5CUDwWhKyyYq/ze6uOCIxJJjziEO	2026-08-20 22:22:10.193122+00	2026-08-20 22:22:10.193122+00	customer	\N
\.


--
-- Data for Name: app_yards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_yards (id, name, city, state, address, contact_name, contact_phone, capacity_info, notes, created_at, updated_at) FROM stdin;
f3ad854c-3384-4dfc-8e89-1b2195cfba92	Pátio São José dos Campos	Ipiranga	PR	Rua 7 de Dezembro 140, Centro, Ipiranga - PR, 84450-000	Central Agro Máquinas	(12) 99737-1569	Operação ativa	Base principal de expedição.	2026-08-18 22:42:46.159316+00	2026-08-19 01:45:22.303263+00
\.


--
-- Name: app_catalog_items app_catalog_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_catalog_items
    ADD CONSTRAINT app_catalog_items_pkey PRIMARY KEY (id);


--
-- Name: app_catalog_items app_catalog_items_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_catalog_items
    ADD CONSTRAINT app_catalog_items_slug_key UNIQUE (slug);


--
-- Name: app_client_tracking app_client_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_client_tracking
    ADD CONSTRAINT app_client_tracking_pkey PRIMARY KEY (id);


--
-- Name: app_client_tracking app_client_tracking_tracking_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_client_tracking
    ADD CONSTRAINT app_client_tracking_tracking_code_key UNIQUE (tracking_code);


--
-- Name: app_drivers app_drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_drivers
    ADD CONSTRAINT app_drivers_pkey PRIMARY KEY (id);


--
-- Name: app_refresh_tokens app_refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_refresh_tokens
    ADD CONSTRAINT app_refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: app_refresh_tokens app_refresh_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_refresh_tokens
    ADD CONSTRAINT app_refresh_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: app_users app_users_cpf_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_users
    ADD CONSTRAINT app_users_cpf_key UNIQUE (cpf);


--
-- Name: app_users app_users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_users
    ADD CONSTRAINT app_users_email_key UNIQUE (email);


--
-- Name: app_users app_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_users
    ADD CONSTRAINT app_users_pkey PRIMARY KEY (id);


--
-- Name: app_yards app_yards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_yards
    ADD CONSTRAINT app_yards_pkey PRIMARY KEY (id);


--
-- Name: app_catalog_items_category_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX app_catalog_items_category_idx ON public.app_catalog_items USING btree (category);


--
-- Name: app_catalog_items_sections_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX app_catalog_items_sections_idx ON public.app_catalog_items USING gin (sections);


--
-- Name: app_client_tracking_client_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX app_client_tracking_client_user_id_idx ON public.app_client_tracking USING btree (client_user_id);


--
-- Name: app_client_tracking_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX app_client_tracking_status_idx ON public.app_client_tracking USING btree (status);


--
-- Name: app_drivers_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX app_drivers_status_idx ON public.app_drivers USING btree (status);


--
-- Name: app_refresh_tokens_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX app_refresh_tokens_expires_at_idx ON public.app_refresh_tokens USING btree (expires_at);


--
-- Name: app_refresh_tokens_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX app_refresh_tokens_user_id_idx ON public.app_refresh_tokens USING btree (user_id);


--
-- Name: app_users_cpf_digits_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX app_users_cpf_digits_idx ON public.app_users USING btree (regexp_replace(cpf, '\D'::text, ''::text, 'g'::text));


--
-- Name: app_users_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX app_users_email_idx ON public.app_users USING btree (lower(email));


--
-- Name: app_users_role_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX app_users_role_idx ON public.app_users USING btree (role);


--
-- Name: app_yards_state_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX app_yards_state_idx ON public.app_yards USING btree (state);


--
-- Name: app_catalog_items set_app_catalog_items_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_app_catalog_items_updated_at BEFORE UPDATE ON public.app_catalog_items FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: app_client_tracking set_app_client_tracking_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_app_client_tracking_updated_at BEFORE UPDATE ON public.app_client_tracking FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: app_drivers set_app_drivers_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_app_drivers_updated_at BEFORE UPDATE ON public.app_drivers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: app_users set_app_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_app_users_updated_at BEFORE UPDATE ON public.app_users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: app_yards set_app_yards_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_app_yards_updated_at BEFORE UPDATE ON public.app_yards FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: app_client_tracking app_client_tracking_catalog_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_client_tracking
    ADD CONSTRAINT app_client_tracking_catalog_item_id_fkey FOREIGN KEY (catalog_item_id) REFERENCES public.app_catalog_items(id) ON DELETE SET NULL;


--
-- Name: app_client_tracking app_client_tracking_client_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_client_tracking
    ADD CONSTRAINT app_client_tracking_client_user_id_fkey FOREIGN KEY (client_user_id) REFERENCES public.app_users(id) ON DELETE SET NULL;


--
-- Name: app_client_tracking app_client_tracking_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_client_tracking
    ADD CONSTRAINT app_client_tracking_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.app_drivers(id) ON DELETE SET NULL;


--
-- Name: app_client_tracking app_client_tracking_yard_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_client_tracking
    ADD CONSTRAINT app_client_tracking_yard_id_fkey FOREIGN KEY (yard_id) REFERENCES public.app_yards(id) ON DELETE SET NULL;


--
-- Name: app_refresh_tokens app_refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_refresh_tokens
    ADD CONSTRAINT app_refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict RVoIeOagRQI1wuKSU2oUlArWcMv74s2ymZmMRC4II98dt3xR85q8z3Lt3FB2zdv

