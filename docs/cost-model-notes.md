# Cost Model Notes

## Purpose
This document explains the high-level cost model for the Finance Hybrid Assistant POC and the impact of moving from custom invoice extraction logic to `AI_EXTRACT`.

---

## Cost categories in this POC

### 1. Document parsing
`AI_PARSE_DOCUMENT` is used to parse staged invoice PDFs into layout-aware text.

Cost model:
- page-based

### 2. Document extraction
`AI_EXTRACT` is used to extract structured invoice fields from the PDFs.

Cost model:
- token-based
- for paged formats like PDF, each page counts as 970 input tokens
- prompt tokens and output tokens also contribute

### 3. Cortex Search
Cortex Search is used to index and retrieve document chunks.

Cost model includes:
- indexed search data
- service usage / serving
- embedding/indexing-related usage

### 4. Snowflake warehouse compute
Warehouses are used for:
- ETL and build steps
- chunk generation
- validation
- app-side SQL queries

### 5. Streamlit container runtime
The Streamlit app runs on container runtime and uses a compute pool.

Important note:
- one app consumes an entire compute-pool node while running

---

## Current POC cost profile
Current design:
- `AI_PARSE_DOCUMENT`
- `AI_EXTRACT`
- Cortex Search
- warehouse compute
- compute pool for Streamlit

The largest ongoing cost in a demo or light pilot environment may be the container-runtime Streamlit app, depending on how long the app stays active.

---

## Why consider `AI_EXTRACT`
Moving from custom extraction logic to `AI_EXTRACT` can increase document-processing cost, but it offers:
- more reliable extraction
- less brittle parsing logic
- easier operationalization
- cleaner path to scale

The business decision is not only technical. It is a tradeoff between:
- runtime cost
- extraction quality
- maintenance effort

---

## Worksheet assumptions
The Excel workbook included with this project is designed to compare:

### Current POC
- parsing cost
- search cost
- warehouse cost
- Streamlit runtime cost

### Future POC / scaled extraction path
- parsing cost
- `AI_EXTRACT` cost
- search cost
- warehouse cost
- Streamlit runtime cost

Yellow cells in the workbook are intended as user inputs.

---

## Usage measurement
To move from estimate to measured cost, capture actual usage from Snowflake usage views for:
- AI functions
- Cortex Search
- warehouse metering
- compute-pool / Streamlit runtime

The recommended approach is:
1. measure current pipeline usage
2. measure future pipeline usage
3. compare extraction quality and cost together

---

## Recommendation
For the POC:
- use the workbook for scenario planning
- use Snowflake usage views for measured cost
- evaluate `AI_EXTRACT` not only on cost, but on extraction reliability and operational simplification
