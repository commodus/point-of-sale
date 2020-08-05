--
-- PostgreSQL database dump
--

-- Dumped from database version 10.12 (Ubuntu 10.12-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.12 (Ubuntu 10.12-0ubuntu0.18.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE ONLY public.tables DROP CONSTRAINT "tables_tableId_key";
ALTER TABLE ONLY public.menus DROP CONSTRAINT "menus_itemId_key";
ALTER TABLE public."waitLists" ALTER COLUMN "waitId" DROP DEFAULT;
ALTER TABLE public.orders ALTER COLUMN "orderId" DROP DEFAULT;
ALTER TABLE public."orderItems" ALTER COLUMN "orderItemId" DROP DEFAULT;
ALTER TABLE public.menus ALTER COLUMN "itemId" DROP DEFAULT;
ALTER TABLE public.checks ALTER COLUMN "checkId" DROP DEFAULT;
DROP SEQUENCE public."waitLists_waitId_seq";
DROP TABLE public."waitLists";
DROP TABLE public.tables;
DROP SEQUENCE public."orders_orderId_seq";
DROP TABLE public.orders;
DROP SEQUENCE public."orderItems_orderItemId_seq";
DROP TABLE public."orderItems";
DROP SEQUENCE public."menus_itemId_seq";
DROP TABLE public.menus;
DROP SEQUENCE public."checks_checkId_seq";
DROP TABLE public.checks;
DROP TABLE public."checkOrders";
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: checkOrders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."checkOrders" (
    "checkId" integer NOT NULL,
    "orderId" integer NOT NULL
);


--
-- Name: checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checks (
    "checkId" integer NOT NULL,
    "isPaid" boolean DEFAULT false NOT NULL,
    "tableId" integer NOT NULL,
    "taxRate" integer DEFAULT 7 NOT NULL,
    tip money,
    "createdAt" timestamp without time zone NOT NULL
);


--
-- Name: checks_checkId_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."checks_checkId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checks_checkId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."checks_checkId_seq" OWNED BY public.checks."checkId";


--
-- Name: menus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menus (
    "itemId" integer NOT NULL,
    item character varying(255) NOT NULL,
    cost money NOT NULL,
    "salePrice" money NOT NULL,
    "imageUrl" character varying(255)
);


--
-- Name: menus_itemId_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."menus_itemId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: menus_itemId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."menus_itemId_seq" OWNED BY public.menus."itemId";


--
-- Name: orderItems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."orderItems" (
    "orderItemId" integer NOT NULL,
    "orderId" integer NOT NULL,
    "itemId" integer NOT NULL,
    "isCompleted" boolean DEFAULT false NOT NULL,
    discount integer,
    "createdAt" timestamp without time zone NOT NULL
);


--
-- Name: orderItems_orderItemId_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."orderItems_orderItemId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orderItems_orderItemId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."orderItems_orderItemId_seq" OWNED BY public."orderItems"."orderItemId";


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    "orderId" integer NOT NULL,
    "isSent" boolean DEFAULT false NOT NULL,
    "tableId" integer NOT NULL,
    "orderedAt" timestamp without time zone NOT NULL
);


--
-- Name: orders_orderId_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."orders_orderId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_orderId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."orders_orderId_seq" OWNED BY public.orders."orderId";


--
-- Name: tables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tables (
    "tableId" integer NOT NULL,
    "tableStatus" integer DEFAULT 0 NOT NULL,
    "timeSeated" timestamp without time zone
);


--
-- Name: waitLists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."waitLists" (
    "waitId" integer NOT NULL,
    name character varying(255) NOT NULL,
    "partySize" integer NOT NULL,
    "time" time with time zone NOT NULL,
    comment character varying(255) NOT NULL,
    "isSeated" boolean DEFAULT false NOT NULL
);


--
-- Name: waitLists_waitId_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."waitLists_waitId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: waitLists_waitId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."waitLists_waitId_seq" OWNED BY public."waitLists"."waitId";


--
-- Name: checks checkId; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checks ALTER COLUMN "checkId" SET DEFAULT nextval('public."checks_checkId_seq"'::regclass);


--
-- Name: menus itemId; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menus ALTER COLUMN "itemId" SET DEFAULT nextval('public."menus_itemId_seq"'::regclass);


--
-- Name: orderItems orderItemId; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."orderItems" ALTER COLUMN "orderItemId" SET DEFAULT nextval('public."orderItems_orderItemId_seq"'::regclass);


--
-- Name: orders orderId; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN "orderId" SET DEFAULT nextval('public."orders_orderId_seq"'::regclass);


--
-- Name: waitLists waitId; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."waitLists" ALTER COLUMN "waitId" SET DEFAULT nextval('public."waitLists_waitId_seq"'::regclass);


--
-- Data for Name: checkOrders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."checkOrders" ("checkId", "orderId") FROM stdin;
\.


--
-- Data for Name: checks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checks ("checkId", "isPaid", "tableId", "taxRate", tip, "createdAt") FROM stdin;
\.


--
-- Data for Name: menus; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.menus ("itemId", item, cost, "salePrice", "imageUrl") FROM stdin;
1	Gen Premium Streak	$5.07	$16.64	/public/images/gen-premiun-steak.png
2	Spice Pork Bulgogi	$8.58	$14.83	/public/images/spicy-pork-chop.png
3	Premium Chadol	$1.99	$11.36	/public/images/premium-chadol.png
4	Hawaiian Steak	$5.52	$15.27	/public/images/hawaiian-steak.png
5	Yangyum Galbi	$2.62	$15.01	/public/images/yangyum-galbi.png
6	Beef Bulgogi	$5.69	$10.79	/public/images/beef-bulgogi.png
7	Samgyubsal	$4.90	$12.56	/public/images/pork-belly.png
8	Spicy Samgyubsal	$5.96	$11.09	/public/images/spicy-pork.png
9	Red Wine Samgyubsal	$4.33	$10.02	/public/images/wine-pork.png
10	Cajun Samgyubsal	$0.45	$12.77	/public/images/cajun-pork.png
\.


--
-- Data for Name: orderItems; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."orderItems" ("orderItemId", "orderId", "itemId", "isCompleted", discount, "createdAt") FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders ("orderId", "isSent", "tableId", "orderedAt") FROM stdin;
\.


--
-- Data for Name: tables; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tables ("tableId", "tableStatus", "timeSeated") FROM stdin;
1	0	\N
2	0	\N
3	0	\N
4	0	\N
5	0	\N
6	0	\N
7	0	\N
8	0	\N
9	0	\N
10	0	\N
\.


--
-- Data for Name: waitLists; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."waitLists" ("waitId", name, "partySize", "time", comment, "isSeated") FROM stdin;
1	Uzair	1	17:07:25.878813-07	Big Anime Table	f
2	Jason	4	17:10:25.878813-07	Family of 4	f
3	Kevin	5	17:15:25.878813-07	4th of july no mask	f
4	Julius	3	17:16:25.878813-07	Three musketeers	f
\.


--
-- Name: checks_checkId_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."checks_checkId_seq"', 1, false);


--
-- Name: menus_itemId_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."menus_itemId_seq"', 1, false);


--
-- Name: orderItems_orderItemId_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."orderItems_orderItemId_seq"', 1, false);


--
-- Name: orders_orderId_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."orders_orderId_seq"', 1, false);


--
-- Name: waitLists_waitId_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."waitLists_waitId_seq"', 4, true);


--
-- Name: menus menus_itemId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT "menus_itemId_key" UNIQUE ("itemId");


--
-- Name: tables tables_tableId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tables
    ADD CONSTRAINT "tables_tableId_key" UNIQUE ("tableId");


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--
