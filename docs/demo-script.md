# Demo Script

## Goal
Demonstrate that one Snowflake-native assistant can:
- answer structured finance questions
- retrieve invoice document evidence
- compare structured ERP-style data to source-document values

---

## Opening
Today I’m going to show a finance assistant built in Snowflake that can answer questions across both structured and unstructured data in a single experience.

The business problem is that important answers are often split across systems and documents. Revenue, balances, and invoice records live in structured tables, while the source invoices live as PDFs. In many environments, users can query one or the other, but not both together in one workflow.

This proof of concept addresses that problem using:
- Cortex Analyst for structured data
- Cortex Search for document retrieval
- a Cortex Agent to orchestrate both
- a Streamlit app as the user interface

---

## Demo prompt 1 — Structured question
**Prompt:**  
`What is total revenue by customer?`

### What to say
This question is purely structured. The agent routes to Cortex Analyst through the semantic finance layer and returns customer-level revenue totals. The app also shows the full structured results table.

### Business point
This demonstrates governed natural-language analytics over structured finance data without requiring SQL from the user.

---

## Demo prompt 2 — Document question
**Prompt:**  
`What does invoice INV-1010 say about the total amount due?`

### What to say
This question is document-based. The agent routes to the document retrieval lane, using Cortex Search over parsed invoice chunks. The app also shows parsed invoice facts extracted from the document itself.

### Business point
This demonstrates that users can retrieve source-document evidence, not just system-of-record values.

---

## Demo prompt 3 — Hybrid comparison question
**Prompt:**  
`Compare ERP and invoice document values for INV-1010 and tell me if they differ.`

### What to say
This is the key hybrid question. The agent uses both structured reconciliation logic and document-derived evidence. In this case, it identifies that the ERP amount and the document amount differ, while other fields such as due date and invoice date match.

### Business point
This demonstrates the real value of the solution: not just answering what the system says or what the document says, but whether they agree.

---

## Closing
This POC demonstrates a single Snowflake-native assistant that can reason across structured finance data and unstructured invoice documents in one experience.

Instead of asking:
- what does the ERP say?
- what does the invoice say?

the business can now ask:
- do they agree, and if not, why?

That is the key value of the solution.

---

## Recommended demo prompt order
1. `What is total revenue by customer?`
2. `What does invoice INV-1010 say about the total amount due?`
3. `Compare ERP and invoice document values for INV-1010 and tell me if they differ.`

---

## Optional backup prompts
- `Which customers have the highest overdue amounts?`
- `Which customers have overdue balances and invoice mismatches?`
