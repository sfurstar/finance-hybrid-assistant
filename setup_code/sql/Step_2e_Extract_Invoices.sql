USE ROLE FIN_ENT_CHATBOT_POC2;
USE WAREHOUSE FIN_ENT_ETL_POC2_WH;
USE DATABASE FIN_ENT_AI_POC2;

TRUNCATE TABLE FIN_ENT_AI_POC2.CURATED_DOCS.INVOICE_EXTRACT;

INSERT INTO FIN_ENT_AI_POC2.CURATED_DOCS.INVOICE_EXTRACT (
    DOCUMENT_ID,
    RELATIVE_PATH,
    INVOICE_NUMBER,
    CUSTOMER_NAME,
    INVOICE_DATE,
    DUE_DATE,
    PAYMENT_TERMS,
    CURRENCY,
    TOTAL_DUE,
    PO_NUMBER
)
SELECT
    DOCUMENT_ID,
    RELATIVE_PATH,

    REGEXP_SUBSTR(
        PARSED_TEXT,
        'Invoice No:\\s*([A-Z0-9-]+)',
        1, 1, 'ie', 1
    ) AS INVOICE_NUMBER,

    TRIM(
        REGEXP_SUBSTR(
            PARSED_TEXT,
            '\\|\\s*([A-Za-z0-9 .&,-]+)\\n[^|]+\\|\\s*Customer ID:',
            1, 1, 'ie', 1
        )
    ) AS CUSTOMER_NAME,

    TRY_TO_DATE(
        REGEXP_SUBSTR(
            PARSED_TEXT,
            'Invoice Date:\\s*([0-9]{4}-[0-9]{2}-[0-9]{2})',
            1, 1, 'ie', 1
        )
    ) AS INVOICE_DATE,

    TRY_TO_DATE(
        REGEXP_SUBSTR(
            PARSED_TEXT,
            'Due Date:\\s*([0-9]{4}-[0-9]{2}-[0-9]{2})',
            1, 1, 'ie', 1
        )
    ) AS DUE_DATE,

    REGEXP_SUBSTR(
        PARSED_TEXT,
        'Terms:\\s*([A-Z ]+[0-9]+)',
        1, 1, 'ie', 1
    ) AS PAYMENT_TERMS,

    REGEXP_SUBSTR(
        PARSED_TEXT,
        'Currency:\\s*([A-Z]{3})',
        1, 1, 'ie', 1
    ) AS CURRENCY,

    TRY_TO_DECIMAL(
        REPLACE(
            REGEXP_SUBSTR(
                PARSED_TEXT,
                'Total Amount Due\\s*\\|\\s*\\$([0-9,]+\\.[0-9]{2})',
                1, 1, 'ie', 1
            ),
            ',',
            ''
        ),
        12,
        2
    ) AS TOTAL_DUE,

    REGEXP_SUBSTR(
        PARSED_TEXT,
        'PO Number:\\s*([A-Z0-9-]+)',
        1, 1, 'ie', 1
    ) AS PO_NUMBER

FROM FIN_ENT_AI_POC2.CURATED_DOCS.INVOICE_PARSED;

SELECT
    DOCUMENT_ID,
    INVOICE_NUMBER,
    CUSTOMER_NAME,
    INVOICE_DATE,
    DUE_DATE,
    PAYMENT_TERMS,
    CURRENCY,
    TOTAL_DUE,
    PO_NUMBER
FROM FIN_ENT_AI_POC2.CURATED_DOCS.INVOICE_EXTRACT
ORDER BY INVOICE_NUMBER;