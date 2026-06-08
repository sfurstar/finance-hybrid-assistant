use role accountadmin;
use warehouse compute_wh;

-- =========================================================
-- STEP 1A - ACCOUNT BOOTSTRAP
-- Run as ACCOUNTADMIN
-- Purpose:
--   1) create custom role for the POC
--   2) grant AI privileges needed for Cortex features
-- =========================================================

USE ROLE ACCOUNTADMIN;

-- ---------------------------------------------------------
-- 1. Create custom role
-- ---------------------------------------------------------
CREATE ROLE IF NOT EXISTS FIN_ENT_CHATBOT_POC2
  COMMENT = 'Role for the Enterprise AI chatbot POC';

-- ---------------------------------------------------------
-- 2. AI privileges for Cortex features
--
-- For this POC, grant:
--   - USE AI FUNCTIONS ON ACCOUNT
--   - SNOWFLAKE.CORTEX_USER database role
-- ---------------------------------------------------------
GRANT USE AI FUNCTIONS ON ACCOUNT TO ROLE FIN_ENT_CHATBOT_POC2;

GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE FIN_ENT_CHATBOT_POC2;
GRANT ROLE FIN_ENT_CHATBOT_POC2 TO USER SFURST;
GRANT ROLE FIN_ENT_CHATBOT_POC2 TO USER "STEVEN.FURST@CGI.COM";

-- ---------------------------------------------------------
-- 3. Optional future-facing grant for Agents-only callers
--    Not required for this POC because CORTEX_USER is enough,
--    but included here commented out for reference.
-- ---------------------------------------------------------
-- GRANT DATABASE ROLE SNOWFLAKE.CORTEX_AGENT_USER TO ROLE FIN_ENT_CHATBOT_POC2;

-- ---------------------------------------------------------
-- 4. OPTIONAL hardening
--
-- By default, USE AI FUNCTIONS may be granted to PUBLIC.
-- Uncomment only if you want to restrict AI function usage
-- account-wide and have validated the impact.
-- ---------------------------------------------------------
-- REVOKE USE AI FUNCTIONS ON ACCOUNT FROM ROLE PUBLIC;

-- ---------------------------------------------------------
-- 5. Verification
-- ---------------------------------------------------------
SHOW ROLES LIKE 'FIN_ENT_CHATBOT_POC2';
SHOW GRANTS TO ROLE FIN_ENT_CHATBOT_POC2;