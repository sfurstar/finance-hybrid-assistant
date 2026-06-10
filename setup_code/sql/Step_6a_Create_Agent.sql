USE ROLE FIN_ENT_CHATBOT_POC2;
USE WAREHOUSE FIN_ENT_APP_POC2_WH;
USE DATABASE FIN_ENT_AI_POC2;
USE SCHEMA APP;

CREATE OR REPLACE AGENT FINANCE_HYBRID_AGENT_POC2
  COMMENT = 'Hybrid finance chatbot agent for structured revenue/AR analysis and invoice document retrieval'
  PROFILE = '{"display_name": "Finance Hybrid Assistant", "avatar": "finance-bot", "color": "blue"}'
  FROM SPECIFICATION
$$
models:
  orchestration: claude-4-sonnet

orchestration:
  budget:
    seconds: 45
    tokens: 24000

instructions:
  system: "You are a finance copilot for a Snowflake POC. Use Cortex Analyst for structured finance questions and Cortex Search for invoice document evidence. Prefer precise numeric answers. If ERP and document-derived values differ, report both and clearly identify the mismatch."
  orchestration: "Route revenue, balances, overdue amounts, AR aging, and mismatch-summary questions to Analyst. Route invoice text, document evidence, due date wording, total amount due wording, and source-document questions to Search. For questions that compare ERP values with invoice documents, combine both tools."
  response: "Answer clearly and concisely. For structured answers, provide the result first. For document-backed answers, cite the invoice number or document identifier when available. If information conflicts across tools, say so explicitly."
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
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "FinanceAnalyst"
      description: "Use this for structured finance questions about revenue, open balances, overdue amounts, aging, and reconciliation summaries."
  - tool_spec:
      type: "cortex_search"
      name: "InvoiceSearch"
      description: "Use this for invoice document retrieval, invoice text evidence, due date wording, total amount due wording, and document-grounded answers."

tool_resources:
  FinanceAnalyst:
    semantic_view: "FIN_ENT_AI_POC2.SEMANTIC.FINANCE_ANALYST_SV"
    warehouse: FIN_ENT_AI_POC2_WH

  InvoiceSearch:
    name: "FIN_ENT_AI_POC2.SEARCH.INVOICE_SEARCH_SVC"
    max_results: "5"
    title_column: "DOCUMENT_ID"
    id_column: "DOCUMENT_ID"
$$;

---show and test

SHOW AGENTS IN SCHEMA FIN_ENT_AI_POC2.APP;

DESCRIBE AGENT FIN_ENT_AI_POC2.APP.FINANCE_HYBRID_AGENT_POC2;

USE ROLE FIN_ENT_CHATBOT_POC2;
USE WAREHOUSE FIN_ENT_APP_POC2_WH;
USE DATABASE FIN_ENT_AI_POC2;
USE SCHEMA APP;

SELECT TRY_PARSE_JSON(
  SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'FIN_ENT_AI_POC2.APP.FINANCE_HYBRID_AGENT_POC2',
    $${
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "What does INV-1010 say about total amount due?"
            }
          ]
        }
      ],
      "stream": false
    }$$
  )
) AS RESPONSE;tools:
  - tool_type: cortex_analyst_tool
    tool_name: FinanceAnalyst
    tool_resources:
      semantic_model: "@my_db.my_schema.my_stage/model.yaml"
      warehouse: MY_WAREHOUSE  # <-- add this