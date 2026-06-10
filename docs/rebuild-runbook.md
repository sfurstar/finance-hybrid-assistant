# Rebuild Runbook

## Purpose
This runbook documents the validated build order for recreating the Finance Hybrid Assistant POC in a fresh Snowflake environment.

It reflects the final working design, including:
- `AI_PARSE_DOCUMENT` for searchable document text
- `AI_EXTRACT` for invoice field extraction
- section-aware chunking for Cortex Search
- reconciliation between structured ERP-style data and extracted invoice values
- Cortex Analyst, Cortex Search, Cortex Agent, and Streamlit

This document is intended to be used alongside the ordered scripts in `setup code/sql/` and any helper scripts in `setup code/python/`.

---

## High-level build order

1. Bootstrap Snowflake objects
2. Load structured finance seed data
3. Generate and stage invoice PDFs
4. Parse invoice PDFs
5. Extract invoice fields with `AI_EXTRACT`
6. Build section-aware chunks
7. Create or refresh Cortex Search
8. Create curated finance views
9. Create reconciliation view
10. Create semantic view
11. Create Cortex Agent
12. Deploy Streamlit app
13. Validate end-to-end
14. Begin productionization

---

# Phase 0 — Pre-build decisions

## Objective
Confirm the naming convention and environment settings before building.

## Confirm these values
- role name
- database name
- ETL warehouse name
- app/query warehouse name
- compute pool name
- raw document stage name
- agent object name
- Streamlit app name

## Recommendation
Use consistent names from the beginning to avoid rework later.

---

# Phase 1 — Bootstrap Snowflake objects

## Objective
Create the foundational Snowflake environment.

## Create
- project role
- warehouses
- database
- schemas
- internal stage for invoice PDFs
- grants / ownership handoff

## Expected output
A clean project environment exists and can be managed under the project role.

## Validation
Confirm:
- role exists
- warehouses exist
- database and schemas exist
- stage exists and is accessible

## Notes
Use a server-side encrypted internal stage for document processing compatibility.

---

# Phase 2 — Load structured finance seed data

## Objective
Create the structured ERP-style source data for the POC.

## Create and populate
- `RAW_FINANCE.CUSTOMER_RAW`
- `RAW_FINANCE.INVOICE_RAW`
- `RAW_FINANCE.PAYMENT_RAW`
- `RAW_FINANCE.REVENUE_RAW`

## Expected output
Structured finance data is available for:
- revenue analysis
- invoice comparison
- AR and aging views

## Validation
Run row-count and spot-check queries to confirm:
- expected customer count
- expected invoice count
- expected payment and revenue rows

## Notes
Keep invoice IDs aligned to the invoice PDFs that will be generated.

---

# Phase 3 — Generate and stage invoice PDFs

## Objective
Create the synthetic invoice documents and upload them to Snowflake.

## Actions
- run the local/helper PDF generation script
- upload the resulting PDFs to the internal stage
- verify the stage directory listing

## Expected output
Invoice PDFs are present in the Snowflake stage and ready for document processing.

## Validation
Check:
- number of PDFs in stage
- file names match structured invoice IDs

## Notes
This stage becomes the source for both parsing and extraction.

---

# Phase 4 — Parse invoice PDFs

## Objective
Convert invoice PDFs into layout-aware searchable text.

## Create
- `CURATED_DOCS.INVOICE_PARSED`

## Processing
Use `AI_PARSE_DOCUMENT` in `LAYOUT` mode to populate:
- `DOCUMENT_ID`
- `RELATIVE_PATH`
- `FILE_URL`
- `PARSED_TEXT`

## Expected output
A parsed text table exists with one row per document.

## Validation
Spot-check several invoices and confirm:
- invoice header is visible
- bill-to section is visible
- line items are visible
- totals section is present in parsed text

## Notes
This parsed output remains useful even after moving extraction to `AI_EXTRACT`.

---

# Phase 5 — Extract invoice fields with `AI_EXTRACT`

## Objective
Extract normalized invoice business fields from the PDFs.

## Create
- `CURATED_DOCS.INVOICE_EXTRACT_AI_RAW`
- `CURATED_DOCS.INVOICE_EXTRACT_AI`

## Processing
1. store raw `AI_EXTRACT` output in the raw table
2. normalize the extracted values into the final extraction table

## Important implementation note
Extracted values are under:

`EXTRACTED_JSON:response:<field>`

and not at the top level.

## Expected output
A normalized extraction table exists with fields such as:
- invoice number
- customer name
- invoice date
- due date
- payment terms
- currency
- total due
- PO number

## Validation
Confirm:
- invoice number populated
- due dates populated
- total due populated
- known discrepancy invoices extract correctly

## Notes
Do not over-filter rows on the `error` field unless you have confirmed how null values appear in your account.

---

# Phase 6 — Validate extraction quality

## Objective
Confirm that invoice extraction is accurate enough to drive reconciliation and evidence display.

## Compare
- extracted values against expected document content
- extracted values against known discrepancy scenarios
- AI extraction vs any older extraction logic if both are present

## Expected output
Confidence that the extraction layer is reliable enough for the POC.

## Validation checks
Focus on:
- `INV-1002`
- `INV-1010`
- `INV-1023`
- `INV-1032`
- `INV-1035`

## Notes
At this stage, confirm which scenarios are:
- true mismatches
- informational exceptions only

---

# Phase 7 — Build section-aware chunks

## Objective
Prepare the document content for reliable retrieval in Cortex Search.

## Create
- `CURATED_DOCS.INVOICE_CHUNK`

## Chunk types
- `FACTS`
- `HEADER`
- `SUMMARY`
- `LINE_ITEMS`
- `TOTALS`

## Processing approach
Use section-aware chunking based on stable invoice markers, not complex regex.

## Expected output
Each invoice produces multiple meaningful search chunks, including a dedicated totals chunk.

## Validation
For at least one invoice, confirm all chunk types exist and that:
- `FACTS` contains extracted values
- `TOTALS` contains subtotal, tax, and total amount due

## Notes
This is a key quality improvement over fixed-length chunking.

---

# Phase 8 — Create or refresh Cortex Search

## Objective
Index the improved chunk table for document retrieval.

## Create or refresh
- `SEARCH.INVOICE_SEARCH_SVC`

## Expected output
Invoice chunks are searchable through Cortex Search.

## Validation
Use `SEARCH_PREVIEW` to test queries such as:
- invoice number + total amount due
- subtotal / tax / total amount due
- payment terms

## Notes
If the source query schema changed, recreate the service.
If only rows changed, refresh may be enough.

---

# Phase 9 — Build curated finance views

## Objective
Create the governed structured finance layer.

## Create views for
- open AR by invoice
- customer revenue monthly
- AR aging
- customer balance summary

## Expected output
A stable analytical finance layer exists for structured questions.

## Validation
Run direct SQL against each view and confirm expected counts and values.

---

# Phase 10 — Build reconciliation view

## Objective
Compare structured ERP-style invoice values to document-extracted values.

## Create
- `CURATED_FINANCE.INVOICE_RECON_V`

## Expected output
A reconciliation layer exists that can identify:
- amount mismatches
- due date mismatches
- payment terms mismatches
- customer naming differences
- document-only metadata such as PO number

## Validation
Check:
- expected mismatch count
- expected discrepancy invoices
- details in `RECON_EXCEPTION_DETAIL`

## Notes
Be explicit about which fields drive `OVERALL_RECON_STATUS` and which are informational only.

---

# Phase 11 — Build semantic view

## Objective
Create the structured analytical interface for Cortex Analyst.

## Create
- `SEMANTIC.FINANCE_ANALYST_SV`

## Expected output
The semantic model is available for governed natural-language structured analysis.

## Validation
Run validation queries using `SEMANTIC_VIEW(...)` syntax and confirm:
- customer-level revenue metrics
- open balance metrics
- overdue amount metrics

## Notes
Do not rely on `SELECT *` semantics for semantic views.

---

# Phase 12 — Build Cortex Agent

## Objective
Create the hybrid agent that can route across structured, document, and hybrid questions.

## Create
- `APP.FINANCE_HYBRID_AGENT_POC`

## Configure tools
- Analyst
- Search

## Expected output
One saved agent object exists and is callable from the application.

## Validation
Test:
1. structured question
2. document question
3. hybrid comparison question

## Notes
Use the exact final saved agent object name in the app.

---

# Phase 13 — Deploy Streamlit app

## Objective
Deploy the user-facing application.

## Deploy
- Streamlit app
- container runtime
- compute pool
- query warehouse

## Expected output
A working Streamlit app can call the Cortex Agent and display answers with supporting evidence.

## Validation
Confirm the app can successfully answer:
- structured question
- document question
- hybrid question

## Notes
Because the app calls the Cortex Agent directly, it should use container runtime.

---

# Phase 14 — Polish the app

## Objective
Make the app demo-ready and business-friendly.

## Add
- grouped starter questions
- answer-type badges
- structured result tables
- document evidence cards
- hybrid reconciliation key facts
- debug panels off by default

## Expected output
A polished app suitable for demos and stakeholder walkthroughs.

---

# Phase 15 — Begin productionization

## Objective
Start turning the POC into an operational pipeline.

## Build
- document control table
- stream on the control table
- registration / parse / extract / chunk procedures
- task graph
- search refresh task
- event-table monitoring
- alerts

## Expected output
New invoices can be processed through an automated pipeline with monitoring and alerting.

---

# Final validation checklist

## Structured
- `What is total revenue by customer?`

## Document
- `What does invoice INV-1010 say about the total amount due?`

## Hybrid
- `Compare ERP and invoice document values for INV-1010 and tell me if they differ.`

## Technical checks
- all expected PDFs staged
- all documents parsed
- all invoices extracted
- facts and totals chunks present
- search service validated
- reconciliation returns expected mismatch count
- semantic view validated
- agent responds correctly
- Streamlit app works in container runtime

---

# Suggested corresponding script layout

```text
setup code/sql/
  01_bootstrap.sql
  02_seed_structured_data.sql
  03_stage_invoice_pdfs.sql
  04_parse_invoices.sql
  05_ai_extract_invoices.sql
  06_build_chunks.sql
  07_build_search_service.sql
  08_curated_finance_views.sql
  09_reconciliation.sql
  10_semantic_view.sql
  11_agent.sql
  12_streamlit.sql
  13_pipeline_automation.sql
```

This runbook should be updated whenever the validated build order changes.
