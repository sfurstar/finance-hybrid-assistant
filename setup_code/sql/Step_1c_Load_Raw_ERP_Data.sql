USE ROLE FIN_ENT_CHATBOT_POC2;
USE WAREHOUSE FIN_ENT_ETL_POC2_WH;
USE DATABASE FIN_ENT_AI_POC2;
USE SCHEMA RAW_FINANCE;

CREATE OR REPLACE TABLE CUSTOMER_RAW (
    CUSTOMER_ID STRING,
    CUSTOMER_NAME STRING,
    REGION STRING,
    INDUSTRY STRING,
    CUSTOMER_STATUS STRING,
    PAYMENT_TERMS STRING
);

INSERT INTO CUSTOMER_RAW
    (CUSTOMER_ID, CUSTOMER_NAME, REGION, INDUSTRY, CUSTOMER_STATUS, PAYMENT_TERMS)
VALUES
    ('CUST001', 'Acme Manufacturing',           'Midwest',   'Manufacturing', 'ACTIVE', 'NET 30'),
    ('CUST002', 'Northwind Retail Group',       'Northeast', 'Retail',        'ACTIVE', 'NET 45'),
    ('CUST003', 'BluePeak Logistics',           'South',     'Logistics',     'ACTIVE', 'NET 30'),
    ('CUST004', 'Summit Health Systems',        'West',      'Healthcare',    'ACTIVE', 'NET 60'),
    ('CUST005', 'Evergreen Industrial Supply',  'Midwest',   'Industrial',    'ACTIVE', 'NET 30'),
    ('CUST006', 'Horizon Field Services',       'South',     'Services',      'ACTIVE', 'NET 30'),
    ('CUST007', 'Cedar Grove Hospitality',      'Southeast', 'Hospitality',   'ACTIVE', 'NET 15'),
    ('CUST008', 'Atlas Construction Partners',  'Southwest', 'Construction',  'ACTIVE', 'NET 45'),
    ('CUST009', 'Brightline Education Network', 'Northeast', 'Education',     'ACTIVE', 'NET 30'),
    ('CUST010', 'Red River Energy',             'South',     'Energy',        'ACTIVE', 'NET 60'),
    ('CUST011', 'Sterling Business Solutions',  'Midwest',   'Professional Services', 'ACTIVE', 'NET 30'),
    ('CUST012', 'Lakefront Food Distributors',  'Great Lakes','Distribution', 'ACTIVE', 'NET 21');

    

    CREATE OR REPLACE TABLE INVOICE_RAW (
    INVOICE_ID STRING,
    CUSTOMER_ID STRING,
    INVOICE_DATE DATE,
    DUE_DATE DATE,
    AMOUNT NUMBER(12,2),
    CURRENCY STRING,
    STATUS STRING,
    INVOICE_DESCRIPTION STRING
);

INSERT INTO INVOICE_RAW
    (INVOICE_ID, CUSTOMER_ID, INVOICE_DATE, DUE_DATE, AMOUNT, CURRENCY, STATUS, INVOICE_DESCRIPTION)
VALUES
    ('INV-1001', 'CUST001', '2026-01-05', '2026-02-04', 18500.00, 'USD', 'OPEN',     'January equipment maintenance services'),
    ('INV-1002', 'CUST001', '2026-02-08', '2026-03-10', 22400.00, 'USD', 'OPEN',     'February replacement parts and inspection'),
    ('INV-1003', 'CUST001', '2026-03-02', '2026-04-01', 19850.00, 'USD', 'OPEN',     'March scheduled maintenance services'),

    ('INV-1004', 'CUST002', '2026-01-11', '2026-02-25', 14200.00, 'USD', 'PAID',     'Store systems support services'),
    ('INV-1005', 'CUST002', '2026-02-14', '2026-03-31', 16750.00, 'USD', 'OPEN',     'POS integration support'),
    ('INV-1006', 'CUST002', '2026-03-03', '2026-04-17', 15990.00, 'USD', 'OPEN',     'Retail reporting services'),

    ('INV-1007', 'CUST003', '2026-01-07', '2026-02-06', 12600.00, 'USD', 'PAID',     'Logistics optimization consulting'),
    ('INV-1008', 'CUST003', '2026-02-09', '2026-03-11', 13150.00, 'USD', 'OPEN',     'Distribution routing analytics'),
    ('INV-1009', 'CUST003', '2026-03-06', '2026-04-05', 14900.00, 'USD', 'OPEN',     'Freight operations reporting'),

    ('INV-1010', 'CUST004', '2026-01-09', '2026-03-10', 30500.00, 'USD', 'OPEN',     'Clinical data platform subscription'),
    ('INV-1011', 'CUST004', '2026-02-12', '2026-04-13', 31800.00, 'USD', 'OPEN',     'Patient analytics services'),
    ('INV-1012', 'CUST004', '2026-03-04', '2026-05-03', 28900.00, 'USD', 'OPEN',     'Healthcare reporting services'),

    ('INV-1013', 'CUST005', '2026-01-06', '2026-02-05', 11200.00, 'USD', 'PAID',     'Industrial supply planning support'),
    ('INV-1014', 'CUST005', '2026-02-10', '2026-03-12', 11850.00, 'USD', 'PAID',     'Procurement optimization services'),
    ('INV-1015', 'CUST005', '2026-03-07', '2026-04-06', 12100.00, 'USD', 'OPEN',     'Inventory reporting enhancement'),

    ('INV-1016', 'CUST006', '2026-01-13', '2026-02-12', 9800.00,  'USD', 'PAID',     'Field service dispatch support'),
    ('INV-1017', 'CUST006', '2026-02-17', '2026-03-19', 10450.00, 'USD', 'OPEN',     'Technician utilization analytics'),
    ('INV-1018', 'CUST006', '2026-03-05', '2026-04-04', 10975.00, 'USD', 'OPEN',     'Service performance reporting'),

    ('INV-1019', 'CUST007', '2026-01-08', '2026-01-23', 8700.00,  'USD', 'PAID',     'Hospitality booking insights'),
    ('INV-1020', 'CUST007', '2026-02-11', '2026-02-26', 9250.00,  'USD', 'OPEN',     'Guest operations dashboard'),
    ('INV-1021', 'CUST007', '2026-03-08', '2026-03-23', 9100.00,  'USD', 'OPEN',     'Revenue management support'),

    ('INV-1022', 'CUST008', '2026-01-10', '2026-02-24', 21400.00, 'USD', 'OPEN',     'Construction schedule analytics'),
    ('INV-1023', 'CUST008', '2026-02-13', '2026-03-30', 19800.00, 'USD', 'OPEN',     'Project cost reporting'),
    ('INV-1024', 'CUST008', '2026-03-09', '2026-04-23', 23600.00, 'USD', 'OPEN',     'Labor forecasting services'),

    ('INV-1025', 'CUST009', '2026-01-14', '2026-02-13', 7600.00,  'USD', 'PAID',     'Student performance reporting'),
    ('INV-1026', 'CUST009', '2026-02-18', '2026-03-20', 8200.00,  'USD', 'PAID',     'Education KPI dashboard'),
    ('INV-1027', 'CUST009', '2026-03-10', '2026-04-09', 8450.00,  'USD', 'OPEN',     'Enrollment trend analysis'),

    ('INV-1028', 'CUST010', '2026-01-12', '2026-03-13', 27600.00, 'USD', 'OPEN',     'Energy operations reporting'),
    ('INV-1029', 'CUST010', '2026-02-16', '2026-04-17', 28850.00, 'USD', 'OPEN',     'Well production analytics'),
    ('INV-1030', 'CUST010', '2026-03-06', '2026-05-05', 29400.00, 'USD', 'OPEN',     'Field output forecasting'),

    ('INV-1031', 'CUST011', '2026-01-15', '2026-02-14', 13400.00, 'USD', 'PAID',     'Business advisory services'),
    ('INV-1032', 'CUST011', '2026-02-19', '2026-03-21', 14150.00, 'USD', 'OPEN',     'Performance scorecard development'),
    ('INV-1033', 'CUST011', '2026-03-07', '2026-04-06', 13800.00, 'USD', 'OPEN',     'Finance process optimization'),

    ('INV-1034', 'CUST012', '2026-01-16', '2026-02-06', 11900.00, 'USD', 'PAID',     'Distribution efficiency analytics'),
    ('INV-1035', 'CUST012', '2026-02-15', '2026-03-08', 12350.00, 'USD', 'OPEN',     'Warehouse throughput reporting'),
    ('INV-1036', 'CUST012', '2026-03-09', '2026-03-30', 12825.00, 'USD', 'OPEN',     'Route planning dashboard support');


    CREATE OR REPLACE TABLE PAYMENT_RAW (
    PAYMENT_ID STRING,
    INVOICE_ID STRING,
    PAYMENT_DATE DATE,
    PAYMENT_AMOUNT NUMBER(12,2),
    PAYMENT_METHOD STRING
);

INSERT INTO PAYMENT_RAW
    (PAYMENT_ID, INVOICE_ID, PAYMENT_DATE, PAYMENT_AMOUNT, PAYMENT_METHOD)
VALUES
    ('PAY-2001', 'INV-1001', '2026-02-03', 10000.00, 'ACH'),
    ('PAY-2002', 'INV-1004', '2026-02-20', 14200.00, 'WIRE'),
    ('PAY-2003', 'INV-1007', '2026-02-05', 12600.00, 'ACH'),
    ('PAY-2004', 'INV-1013', '2026-02-04', 11200.00, 'ACH'),
    ('PAY-2005', 'INV-1014', '2026-03-10', 11850.00, 'ACH'),
    ('PAY-2006', 'INV-1016', '2026-02-11', 9800.00,  'WIRE'),
    ('PAY-2007', 'INV-1019', '2026-01-22', 8700.00,  'ACH'),
    ('PAY-2008', 'INV-1025', '2026-02-12', 7600.00,  'ACH'),
    ('PAY-2009', 'INV-1026', '2026-03-18', 8200.00,  'ACH'),
    ('PAY-2010', 'INV-1031', '2026-02-13', 13400.00, 'WIRE'),
    ('PAY-2011', 'INV-1034', '2026-02-05', 11900.00, 'ACH'),

    ('PAY-2012', 'INV-1005', '2026-03-20', 6000.00,  'ACH'),
    ('PAY-2013', 'INV-1008', '2026-03-09', 5000.00,  'ACH'),
    ('PAY-2014', 'INV-1010', '2026-03-08', 15000.00, 'WIRE'),
    ('PAY-2015', 'INV-1017', '2026-03-18', 4000.00,  'ACH'),
    ('PAY-2016', 'INV-1020', '2026-03-01', 3000.00,  'CARD'),
    ('PAY-2017', 'INV-1022', '2026-03-01', 8000.00,  'WIRE'),
    ('PAY-2018', 'INV-1028', '2026-03-10', 10000.00, 'ACH'),
    ('PAY-2019', 'INV-1032', '2026-03-25', 7000.00,  'ACH'),
    ('PAY-2020', 'INV-1035', '2026-03-07', 6000.00,  'ACH');


    CREATE OR REPLACE TABLE REVENUE_RAW (
    REVENUE_ID STRING,
    CUSTOMER_ID STRING,
    REVENUE_DATE DATE,
    REVENUE_AMOUNT NUMBER(12,2),
    REVENUE_CATEGORY STRING
);

INSERT INTO REVENUE_RAW
    (REVENUE_ID, CUSTOMER_ID, REVENUE_DATE, REVENUE_AMOUNT, REVENUE_CATEGORY)
VALUES
    ('REV-3001', 'CUST001', '2026-01-31', 21000.00, 'Services'),
    ('REV-3002', 'CUST001', '2026-02-28', 23500.00, 'Services'),
    ('REV-3003', 'CUST001', '2026-03-31', 22000.00, 'Services'),

    ('REV-3004', 'CUST002', '2026-01-31', 15000.00, 'Services'),
    ('REV-3005', 'CUST002', '2026-02-28', 17100.00, 'Services'),
    ('REV-3006', 'CUST002', '2026-03-31', 16400.00, 'Services'),

    ('REV-3007', 'CUST003', '2026-01-31', 12800.00, 'Analytics'),
    ('REV-3008', 'CUST003', '2026-02-28', 13500.00, 'Analytics'),
    ('REV-3009', 'CUST003', '2026-03-31', 15100.00, 'Analytics'),

    ('REV-3010', 'CUST004', '2026-01-31', 31200.00, 'Subscription'),
    ('REV-3011', 'CUST004', '2026-02-28', 32000.00, 'Subscription'),
    ('REV-3012', 'CUST004', '2026-03-31', 29500.00, 'Subscription'),

    ('REV-3013', 'CUST005', '2026-01-31', 11400.00, 'Services'),
    ('REV-3014', 'CUST005', '2026-02-28', 12050.00, 'Services'),
    ('REV-3015', 'CUST005', '2026-03-31', 12300.00, 'Services'),

    ('REV-3016', 'CUST006', '2026-01-31', 9950.00,  'Services'),
    ('REV-3017', 'CUST006', '2026-02-28', 10600.00, 'Services'),
    ('REV-3018', 'CUST006', '2026-03-31', 11150.00, 'Services'),

    ('REV-3019', 'CUST007', '2026-01-31', 8850.00,  'Services'),
    ('REV-3020', 'CUST007', '2026-02-28', 9400.00,  'Services'),
    ('REV-3021', 'CUST007', '2026-03-31', 9200.00,  'Services'),

    ('REV-3022', 'CUST008', '2026-01-31', 21900.00, 'Project Services'),
    ('REV-3023', 'CUST008', '2026-02-28', 20100.00, 'Project Services'),
    ('REV-3024', 'CUST008', '2026-03-31', 24000.00, 'Project Services'),

    ('REV-3025', 'CUST009', '2026-01-31', 7750.00,  'Services'),
    ('REV-3026', 'CUST009', '2026-02-28', 8350.00,  'Services'),
    ('REV-3027', 'CUST009', '2026-03-31', 8600.00,  'Services'),

    ('REV-3028', 'CUST010', '2026-01-31', 28100.00, 'Analytics'),
    ('REV-3029', 'CUST010', '2026-02-28', 29000.00, 'Analytics'),
    ('REV-3030', 'CUST010', '2026-03-31', 29700.00, 'Analytics'),

    ('REV-3031', 'CUST011', '2026-01-31', 13600.00, 'Consulting'),
    ('REV-3032', 'CUST011', '2026-02-28', 14400.00, 'Consulting'),
    ('REV-3033', 'CUST011', '2026-03-31', 14050.00, 'Consulting'),

    ('REV-3034', 'CUST012', '2026-01-31', 12100.00, 'Services'),
    ('REV-3035', 'CUST012', '2026-02-28', 12500.00, 'Services'),
    ('REV-3036', 'CUST012', '2026-03-31', 12950.00, 'Services');

