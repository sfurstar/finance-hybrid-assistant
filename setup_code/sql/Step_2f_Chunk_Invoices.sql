USE ROLE FIN_ENT_CHATBOT_POC2;
USE WAREHOUSE FIN_ENT_ETL_POC2_WH;
USE DATABASE FIN_ENT_AI_POC2;
USE SCHEMA CURATED_DOCS;

TRUNCATE TABLE INVOICE_CHUNK;

INSERT INTO INVOICE_CHUNK (
    CHUNK_ID,
    DOCUMENT_ID,
    RELATIVE_PATH,
    INVOICE_NUMBER,
    CUSTOMER_NAME,
    DUE_DATE,
    TOTAL_DUE,
    CHUNK_TYPE,
    CHUNK_INDEX,
    CHUNK_TEXT
)
WITH base AS (
    SELECT
        p.DOCUMENT_ID,
        p.RELATIVE_PATH,
        p.PARSED_TEXT,
        e.INVOICE_NUMBER,
        e.CUSTOMER_NAME,
        e.DUE_DATE,
        e.TOTAL_DUE,
        e.INVOICE_DATE,
        e.PAYMENT_TERMS,
        e.PO_NUMBER
    FROM FIN_ENT_AI_POC2.CURATED_DOCS.INVOICE_PARSED p
    LEFT JOIN FIN_ENT_AI_POC2.CURATED_DOCS.INVOICE_EXTRACT e
      ON p.DOCUMENT_ID = e.DOCUMENT_ID
),
facts_chunk AS (
    SELECT
        DOCUMENT_ID || '-FACTS' AS CHUNK_ID,
        DOCUMENT_ID,
        RELATIVE_PATH,
        INVOICE_NUMBER,
        CUSTOMER_NAME,
        DUE_DATE,
        TOTAL_DUE,
        'FACTS' AS CHUNK_TYPE,
        1 AS CHUNK_INDEX,
        TRIM(
            'Invoice Number: ' || COALESCE(INVOICE_NUMBER, '') || CHAR(10) ||
            'Customer Name: ' || COALESCE(CUSTOMER_NAME, '') || CHAR(10) ||
            'Invoice Date: ' || COALESCE(TO_VARCHAR(INVOICE_DATE, 'YYYY-MM-DD'), '') || CHAR(10) ||
            'Due Date: ' || COALESCE(TO_VARCHAR(DUE_DATE, 'YYYY-MM-DD'), '') || CHAR(10) ||
            'Total Amount Due: ' || COALESCE(TO_VARCHAR(TOTAL_DUE, '99999990.00'), '') || CHAR(10) ||
            'Payment Terms: ' || COALESCE(PAYMENT_TERMS, '') || CHAR(10) ||
            'PO Number: ' || COALESCE(PO_NUMBER, '')
        ) AS CHUNK_TEXT
    FROM base
),
header_chunk AS (
    SELECT
        DOCUMENT_ID || '-HEADER' AS CHUNK_ID,
        DOCUMENT_ID,
        RELATIVE_PATH,
        INVOICE_NUMBER,
        CUSTOMER_NAME,
        DUE_DATE,
        TOTAL_DUE,
        'HEADER' AS CHUNK_TYPE,
        2 AS CHUNK_INDEX,
        TRIM(
            SPLIT_PART(PARSED_TEXT, '|  Bill To |', 1)
        ) AS CHUNK_TEXT
    FROM base
),
summary_chunk AS (
    SELECT
        DOCUMENT_ID || '-SUMMARY' AS CHUNK_ID,
        DOCUMENT_ID,
        RELATIVE_PATH,
        INVOICE_NUMBER,
        CUSTOMER_NAME,
        DUE_DATE,
        TOTAL_DUE,
        'SUMMARY' AS CHUNK_TYPE,
        3 AS CHUNK_INDEX,
        TRIM(
            '|  Bill To |' ||
            SPLIT_PART(
                SPLIT_PART(PARSED_TEXT, '|  Bill To |', 2),
                '|  Service Period |',
                1
            )
        ) AS CHUNK_TEXT
    FROM base
),
line_items_chunk AS (
    SELECT
        DOCUMENT_ID || '-LINEITEMS' AS CHUNK_ID,
        DOCUMENT_ID,
        RELATIVE_PATH,
        INVOICE_NUMBER,
        CUSTOMER_NAME,
        DUE_DATE,
        TOTAL_DUE,
        'LINE_ITEMS' AS CHUNK_TYPE,
        4 AS CHUNK_INDEX,
        TRIM(
            '|  Service Period |' ||
            SPLIT_PART(
                SPLIT_PART(PARSED_TEXT, '|  Service Period |', 2),
                'Please remit payment by the due date shown above.',
                1
            )
        ) AS CHUNK_TEXT
    FROM base
),
totals_chunk AS (
    SELECT
        DOCUMENT_ID || '-TOTALS' AS CHUNK_ID,
        DOCUMENT_ID,
        RELATIVE_PATH,
        INVOICE_NUMBER,
        CUSTOMER_NAME,
        DUE_DATE,
        TOTAL_DUE,
        'TOTALS' AS CHUNK_TYPE,
        5 AS CHUNK_INDEX,
        TRIM(
            'Please remit payment by the due date shown above.' ||
            SPLIT_PART(
                SPLIT_PART(PARSED_TEXT, 'Please remit payment by the due date shown above.', 2),
                'Questions regarding this invoice',
                1
            )
        ) AS CHUNK_TEXT
    FROM base
)
SELECT * FROM facts_chunk
UNION ALL
SELECT * FROM header_chunk WHERE CHUNK_TEXT IS NOT NULL AND CHUNK_TEXT <> ''
UNION ALL
SELECT * FROM summary_chunk WHERE CHUNK_TEXT IS NOT NULL AND CHUNK_TEXT <> ''
UNION ALL
SELECT * FROM line_items_chunk WHERE CHUNK_TEXT IS NOT NULL AND CHUNK_TEXT <> ''
UNION ALL
SELECT * FROM totals_chunk WHERE CHUNK_TEXT IS NOT NULL AND CHUNK_TEXT <> '';



SELECT
    DOCUMENT_ID,
    CHUNK_TYPE,
    CHUNK_INDEX,
    LEFT(CHUNK_TEXT, 400) AS CHUNK_PREVIEW
FROM FIN_ENT_AI_POC2.CURATED_DOCS.INVOICE_CHUNK
WHERE DOCUMENT_ID = 'INV-1010.pdf'
ORDER BY CHUNK_INDEX;