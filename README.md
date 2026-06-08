# Finance Hybrid Assistant POC

## Overview
This project is a Snowflake-native proof of concept for a hybrid business assistant that can answer questions across both:

- **structured finance data** such as customers, invoices, payments, revenue, balances, and aging
- **unstructured invoice documents** such as PDF invoices parsed, extracted, chunked, and indexed in Snowflake

The solution demonstrates a single agent experience that can:
- answer structured analytics questions
- retrieve document-backed invoice evidence
- compare structured ERP-style values to document-derived values
- explain mismatches in one workflow

---

## Repository structure

```text
finance-hybrid-assistant/
├── app/
│   └── streamlit_app.py
├── docs/
│   ├── architecture-summary.md
│   ├── demo-script.md
│   ├── cost-model-notes.md
│   └── rebuild-runbook.md
├── setup code/
│   ├── python/
│   └── sql/
├── requirements.txt
└── README.md
```

### Folder descriptions

#### `app/`
Contains the Streamlit application used to demonstrate the solution.  
The app connects to the saved Cortex Agent and presents:
- structured answers
- document-backed answers
- hybrid reconciliation answers
- supporting evidence panels

#### `docs/`
Contains supporting documentation for:
- architecture and data flow
- demo narrative / walkthrough
- cost and pricing notes
- rebuild instructions for a fresh environment

#### `setup code/`
Contains the build scripts, listed in execution order, used to create the environment and demo objects in Snowflake.

- `python/` contains helper scripts such as invoice PDF generation
- `sql/` contains the Snowflake SQL used to create objects, load data, build services, and validate the POC

---

## Core business use case
The primary use case is invoice and receivables investigation.

Examples:
- What is total revenue by customer?
- What does invoice INV-1010 say about the total amount due?
- Compare ERP and invoice document values for INV-1010 and tell me if they differ.

---

## What this POC solves
In many organizations, important business answers are split across:
- **structured systems of record**
- **unstructured source documents**

This POC demonstrates how a single assistant can answer:
- what the system says
- what the document says
- whether they agree

This pattern is relevant across industries including finance, insurance, healthcare, manufacturing, supply chain, energy, and the public sector.

---

## High-level architecture

The solution is built from four main layers:

### 1. Structured data layer
- raw finance tables
- curated finance views
- semantic view for Cortex Analyst

### 2. Document processing layer
- invoice PDFs staged in Snowflake
- `AI_PARSE_DOCUMENT` used for searchable document text and layout
- `AI_EXTRACT` used for invoice field extraction
- section-aware chunks prepared for Cortex Search

### 3. Reconciliation layer
- compares ERP-style invoice values to extracted document values
- surfaces amount, due date, terms, customer-name, and other differences

### 4. Experience layer
- Cortex Search for document retrieval
- Cortex Analyst for structured analysis
- Cortex Agent for orchestration
- Streamlit UI running on container runtime

---

## Main Snowflake objects

### Security / compute / storage
- Role: `FIN_ENT_CHATBOT_POC`
- Database: `FIN_ENT_AI_POC`
- Warehouses:
  - ETL warehouse
  - app/query warehouse
- Compute pool:
  - Streamlit container runtime pool

### Schemas
- `RAW_FINANCE`
- `RAW_DOCS`
- `CURATED_DOCS`
- `CURATED_FINANCE`
- `SEMANTIC`
- `SEARCH`
- `APP`

### Key objects
- raw finance source tables
- internal stage for invoice PDFs
- `CURATED_DOCS.INVOICE_PARSED`
- `CURATED_DOCS.INVOICE_EXTRACT_AI_RAW`
- `CURATED_DOCS.INVOICE_EXTRACT_AI`
- `CURATED_DOCS.INVOICE_CHUNK`
- `CURATED_FINANCE.INVOICE_RECON_V`
- `SEMANTIC.FINANCE_ANALYST_SV`
- `SEARCH.INVOICE_SEARCH_SVC`
- `APP.FINANCE_HYBRID_AGENT_POC`
- Streamlit app object

---

## Key design decisions

### Why `AI_PARSE_DOCUMENT`
`AI_PARSE_DOCUMENT` is used to convert staged invoice PDFs into layout-aware text suitable for:
- searchable document content
- document chunking
- Cortex Search indexing

### Why `AI_EXTRACT`
`AI_EXTRACT` is used to extract invoice fields such as:
- invoice number
- customer name
- invoice date
- due date
- payment terms
- currency
- total due
- PO number

This replaced earlier custom extraction logic and gives a more scalable extraction path.

### Why Cortex Search
Cortex Search is used to retrieve document evidence from parsed and chunked invoice content.

### Why Cortex Analyst
Cortex Analyst is used to answer governed questions over structured finance data through a semantic view.

### Why a Cortex Agent
A single agent orchestrates structured, unstructured, and hybrid questions in one experience.

### Why Streamlit container runtime
The Streamlit app calls the Cortex Agent directly, so it runs on **container runtime**.

---

## Demo prompts
Use these validated prompts for demos:

1. `What is total revenue by customer?`
2. `What does invoice INV-1010 say about the total amount due?`
3. `Compare ERP and invoice document values for INV-1010 and tell me if they differ.`

Optional additional prompts:
- `Which customers have the highest overdue amounts?`
- `Which customers have overdue balances and invoice mismatches?`

---

## Setup sequence
The `setup code/sql/` folder is organized in execution order.

At a high level the build process is:

1. create role, warehouses, database, schemas, and stage
2. load structured finance seed data
3. generate and upload invoice PDFs
4. parse invoice PDFs
5. extract invoice fields with `AI_EXTRACT`
6. build section-aware chunks
7. create Cortex Search
8. build curated finance views
9. build reconciliation view
10. build semantic view
11. create Cortex Agent
12. deploy Streamlit app

---

## Current status
This repo reflects a working POC that demonstrates:
- structured finance question answering
- document-backed invoice retrieval
- hybrid ERP vs invoice comparison
- supporting evidence display in the app

The next phase is productionization:
- automated ingestion
- streams / tasks orchestration
- monitoring and alerts
- extraction hardening
- operational cost measurement
