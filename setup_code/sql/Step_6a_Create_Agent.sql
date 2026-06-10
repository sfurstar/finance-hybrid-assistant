USE ROLE FIN_ENT_CHATBOT_POC2;
USE WAREHOUSE FIN_ENT_APP_POC2_WH;
USE DATABASE FIN_ENT_AI_POC2;
USE SCHEMA APP;

CREATE OR REPLACE AGENT FINANCE_HYBRID_AGENT_POC2
  COMMENT = 'Hybrid finance chatbot agent for structured revenue/AR analysis and invoice document retrieval'
  FROM SPECIFICATION
$$
models:
  orchestration: claude-sonnet-4-5

orchestration:
  budget:
    seconds: 45
    tokens: 24000

instructions:
  system: "You are a finance copilot for a Snowflake POC. Use Cortex Analyst for structured finance questions and Cortex Search for invoice document evidence. Prefer precise numeric answers. If ERP and document-derived values differ, surface both and explain the discrepancy."
  orchestration: "Route revenue, AR, and structured finance questions to FinanceAnalyst. Route invoice document questions to InvoiceSearch. For reconciliation questions use both."
  response: "Answer clearly and concisely. For structured answers include key numbers. For document answers include relevant invoice evidence."
  sample_questions:
    - question: "What is total revenue by customer?"
      answer: "I will use the finance semantic view to calculate total revenue by customer."
    - question: "Which invoices have mismatches?"
      answer: "I will analyze the reconciliation data and summarize the mismatched invoices."
    - question: "What does invoice INV-1010 say about the total amount due?"
      answer: "I will search the invoice document content and return the relevant evidence."
    - question: "Compare ERP and invoice document values for INV-1010."
      answer: "I will combine structured reconciliation data with invoice document retrieval."

tools:
  - tool_type: cortex_analyst_tool
    tool_name: FinanceAnalyst
    tool_resources:
      semantic_view: FIN_ENT_AI_POC2.SEMANTIC.FINANCE_ANALYST_SV
      warehouse: FIN_ENT_APP_POC2_WH

  - tool_type: cortex_search_tool
    tool_name: InvoiceSearch
    tool_resources:
      cortex_search_service: FIN_ENT_AI_POC2.SEARCH.INVOICE_SEARCH_SVC
      max_results: 5
      title_column: DOCUMENT_ID
      id_column: DOCUMENT_ID
$$;

-- verify
SHOW AGENTS IN SCHEMA FIN_ENT_AI_POC2.APP;

DESCRIBE AGENT FIN_ENT_AI_POC2.APP.FINANCE_HYBRID_AGENT_POC2;