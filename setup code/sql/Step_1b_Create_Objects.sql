use role sysadmin;
-- =========================================================
-- STEP 1B - OBJECT BOOTSTRAP
-- Run as SYSADMIN
-- Purpose:
--   1) create warehouses
--   2) create database
--   3) create schemas
--   4) grant baseline usage privileges to role
-- =========================================================

USE ROLE SYSADMIN;

-- ---------------------------------------------------------
-- 1. Create warehouses
-- ---------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS FIN_ENT_APP_POC2_WH
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for Streamlit app, Cortex Search, Analyst, and interactive POC usage';

CREATE WAREHOUSE IF NOT EXISTS FIN_ENT_ETL_POC2_WH
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for ingestion, parsing, transforms, and back-end prep jobs';

-- ---------------------------------------------------------
-- 2. Create database
-- ---------------------------------------------------------
CREATE DATABASE IF NOT EXISTS FIN_ENT_AI_POC2
  COMMENT = 'Database for the Snowflake Cortex + Streamlit chatbot POC';

-- ---------------------------------------------------------
-- 3. Create schemas
-- ---------------------------------------------------------
USE DATABASE FIN_ENT_AI_POC2;

CREATE SCHEMA IF NOT EXISTS RAW_FINANCE
  COMMENT = 'Raw structured finance data for the chatbot POC';

CREATE SCHEMA IF NOT EXISTS RAW_DOCS
  COMMENT = 'Raw document metadata and external/internal stage references';

CREATE SCHEMA IF NOT EXISTS CURATED_FINANCE
  COMMENT = 'Curated finance marts and views for revenue and AR analysis';

CREATE SCHEMA IF NOT EXISTS CURATED_DOCS
  COMMENT = 'Parsed, extracted, and chunked document data for retrieval';

CREATE SCHEMA IF NOT EXISTS SEMANTIC
  COMMENT = 'Semantic views for Cortex Analyst';

CREATE SCHEMA IF NOT EXISTS SEARCH
  COMMENT = 'Cortex Search services and related retrieval objects';

CREATE SCHEMA IF NOT EXISTS APP
  COMMENT = 'Streamlit app and application support objects';

-- ---------------------------------------------------------
-- 4. Grant baseline warehouse usage
-- ---------------------------------------------------------
GRANT USAGE, OPERATE ON WAREHOUSE FIN_ENT_APP_POC2_WH TO ROLE FIN_ENT_CHATBOT_POC2;
GRANT USAGE, OPERATE ON WAREHOUSE FIN_ENT_ETL_POC2_WH TO ROLE FIN_ENT_CHATBOT_POC2;

-- ---------------------------------------------------------
-- 5. Grant database usage
-- ---------------------------------------------------------
GRANT USAGE ON DATABASE FIN_ENT_AI_POC2 TO ROLE FIN_ENT_CHATBOT_POC2;

-- ---------------------------------------------------------
-- 6. Grant schema usage
-- ---------------------------------------------------------
GRANT USAGE ON ALL SCHEMAS IN DATABASE FIN_ENT_AI_POC2 TO ROLE FIN_ENT_CHATBOT_POC2;

-- ---------------------------------------------------------
-- 7. Grant create privileges needed for the POC build
-- ---------------------------------------------------------
GRANT CREATE TABLE ON SCHEMA FIN_ENT_AI_POC2.RAW_FINANCE TO ROLE FIN_ENT_CHATBOT_POC2;
GRANT CREATE TABLE ON SCHEMA FIN_ENT_AI_POC2.RAW_DOCS TO ROLE FIN_ENT_CHATBOT_POC2;
GRANT CREATE TABLE ON SCHEMA FIN_ENT_AI_POC2.CURATED_FINANCE TO ROLE FIN_ENT_CHATBOT_POC2;
GRANT CREATE TABLE ON SCHEMA FIN_ENT_AI_POC2.CURATED_DOCS TO ROLE FIN_ENT_CHATBOT_POC2;

GRANT CREATE VIEW ON SCHEMA FIN_ENT_AI_POC2.CURATED_FINANCE TO ROLE FIN_ENT_CHATBOT_POC2;
GRANT CREATE VIEW ON SCHEMA FIN_ENT_AI_POC2.CURATED_DOCS TO ROLE FIN_ENT_CHATBOT_POC2;

GRANT CREATE SEMANTIC VIEW ON SCHEMA FIN_ENT_AI_POC2.SEMANTIC TO ROLE FIN_ENT_CHATBOT_POC2;
GRANT CREATE CORTEX SEARCH SERVICE ON SCHEMA FIN_ENT_AI_POC2.SEARCH TO ROLE FIN_ENT_CHATBOT_POC2;
GRANT CREATE PROCEDURE ON SCHEMA FIN_ENT_AI_POC2.APP TO ROLE FIN_ENT_CHATBOT_POC2;
GRANT CREATE STAGE ON SCHEMA FIN_ENT_AI_POC2.RAW_DOCS TO ROLE FIN_ENT_CHATBOT_POC2;
GRANT CREATE STREAMLIT ON SCHEMA FIN_ENT_AI_POC2.APP TO ROLE FIN_ENT_CHATBOT_POC2;

-- ---------------------------------------------------------
-- 8. Future grants for readable curated objects
-- ---------------------------------------------------------
GRANT SELECT ON FUTURE TABLES IN SCHEMA FIN_ENT_AI_POC2.CURATED_FINANCE TO ROLE FIN_ENT_CHATBOT_POC2;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA FIN_ENT_AI_POC2.CURATED_FINANCE TO ROLE FIN_ENT_CHATBOT_POC2;

GRANT SELECT ON FUTURE TABLES IN SCHEMA FIN_ENT_AI_POC2.CURATED_DOCS TO ROLE FIN_ENT_CHATBOT_POC2;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA FIN_ENT_AI_POC2.CURATED_DOCS TO ROLE FIN_ENT_CHATBOT_POC2;

GRANT SELECT ON FUTURE SEMANTIC VIEWS IN SCHEMA FIN_ENT_AI_POC2.SEMANTIC TO ROLE FIN_ENT_CHATBOT_POC2;


-- ---------------------------------------------------------
-- 4. Transfer ownership to the POC role
--
-- This makes FIN_ENT_CHATBOT_POC2 the owner of the database,
-- schemas, and warehouses so later build steps can be run
-- directly with that role instead of SYSADMIN.
--
-- COPY CURRENT GRANTS preserves any existing grants.
-- ---------------------------------------------------------

GRANT OWNERSHIP ON WAREHOUSE FIN_ENT_APP_POC2_WH TO ROLE FIN_ENT_CHATBOT_POC2 COPY CURRENT GRANTS;
GRANT OWNERSHIP ON WAREHOUSE FIN_ENT_ETL_POC2_WH TO ROLE FIN_ENT_CHATBOT_POC2 COPY CURRENT GRANTS;

GRANT OWNERSHIP ON DATABASE FIN_ENT_AI_POC2 TO ROLE FIN_ENT_CHATBOT_POC2 COPY CURRENT GRANTS;

GRANT OWNERSHIP ON SCHEMA FIN_ENT_AI_POC2.RAW_FINANCE TO ROLE FIN_ENT_CHATBOT_POC2 COPY CURRENT GRANTS;
GRANT OWNERSHIP ON SCHEMA FIN_ENT_AI_POC2.RAW_DOCS TO ROLE FIN_ENT_CHATBOT_POC2 COPY CURRENT GRANTS;
GRANT OWNERSHIP ON SCHEMA FIN_ENT_AI_POC2.CURATED_FINANCE TO ROLE FIN_ENT_CHATBOT_POC2 COPY CURRENT GRANTS;
GRANT OWNERSHIP ON SCHEMA FIN_ENT_AI_POC2.CURATED_DOCS TO ROLE FIN_ENT_CHATBOT_POC2 COPY CURRENT GRANTS;
GRANT OWNERSHIP ON SCHEMA FIN_ENT_AI_POC2.SEMANTIC TO ROLE FIN_ENT_CHATBOT_POC2 COPY CURRENT GRANTS;
GRANT OWNERSHIP ON SCHEMA FIN_ENT_AI_POC2.SEARCH TO ROLE FIN_ENT_CHATBOT_POC2 COPY CURRENT GRANTS;
GRANT OWNERSHIP ON SCHEMA FIN_ENT_AI_POC2.APP TO ROLE FIN_ENT_CHATBOT_POC2 COPY CURRENT GRANTS;

-- ---------------------------------------------------------
-- 9. Verification
-- ---------------------------------------------------------
SHOW WAREHOUSES LIKE 'FIN_ENT%';
SHOW DATABASES LIKE 'FIN_ENT_AI_POC2';
SHOW SCHEMAS IN DATABASE FIN_ENT_AI_POC2;

SHOW GRANTS ON DATABASE FIN_ENT_AI_POC2;
SHOW GRANTS TO ROLE FIN_ENT_CHATBOT_POC2;