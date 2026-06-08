# Architecture and Data Flow Summary

## Objective
Build a single Snowflake-native assistant that can answer questions across both:
- structured finance data
- unstructured invoice documents

The assistant supports three categories of questions:
- **structured analysis**
- **document evidence**
- **hybrid comparison**

---

## Business problem
In many organizations, critical business answers are split across:
- system-of-record data in structured tables
- source evidence in unstructured documents

This creates friction when users need to answer:
- What does the system say?
- What does the invoice say?
- Do they agree, and if not, why?

This POC addresses that problem with one assistant over both data types.

---

## Architecture overview

### 1. Structured data lane
Raw finance data lands in Snowflake tables such as:
- customers
- invoices
- payments
- revenue

These are transformed into curated finance views for:
- revenue
- open balances
- overdue balances
- aging

A semantic view is then built for Cortex Analyst.

### 2. Document lane
Invoice PDFs are staged in Snowflake and processed through:
- `AI_PARSE_DOCUMENT` for layout-aware text
- `AI_EXTRACT` for structured invoice field extraction

The parsed content is converted into:
- facts chunks
- header chunks
- summary chunks
- line-item chunks
- totals chunks

These are indexed in Cortex Search.

### 3. Reconciliation lane
A reconciliation view compares:
- ERP-style structured values
- document-derived values from `AI_EXTRACT`

This enables comparison of:
- invoice date
- due date
- payment terms
- currency
- amount
- customer naming
- document-only metadata such as PO number

### 4. Orchestration layer
A Cortex Agent routes user questions to:
- Cortex Analyst for structured questions
- Cortex Search for document retrieval
- both for hybrid comparison questions

### 5. User experience layer
A Streamlit app provides:
- natural-language chat interface
- structured result tables
- document evidence panels
- reconciliation evidence panels
- key-facts cards

---

## End-to-end data flow

### Structured flow
Source finance data -> raw finance tables -> curated finance views -> semantic view -> Cortex Analyst -> app response

### Document flow
Invoice PDF -> Snowflake stage -> `AI_PARSE_DOCUMENT` -> parsed text -> `AI_EXTRACT` -> normalized invoice fields -> chunk table -> Cortex Search -> app response

### Hybrid flow
Structured invoice data + document-extracted fields -> reconciliation view -> Cortex Agent -> app response

---

## Key Snowflake services used
- `AI_PARSE_DOCUMENT`
- `AI_EXTRACT`
- Cortex Search
- Cortex Analyst
- Cortex Agent
- Streamlit in Snowflake (container runtime)

---

## Why the architecture matters
This design allows the user to ask one question and receive an answer grounded in:
- structured business records
- source-document evidence
- or both at the same time

That is the key value of the solution.

---

## Example question types

### Structured
`What is total revenue by customer?`

### Document
`What does invoice INV-1010 say about the total amount due?`

### Hybrid
`Compare ERP and invoice document values for INV-1010 and tell me if they differ.`
