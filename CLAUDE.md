# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a dbt project for Jaffle Shop configured with CI/CD pipeline capabilities using GitHub Actions and Google Cloud Platform (GCP). The project demonstrates best practices for testing and deploying dbt models with state-based builds.

## Core Commands

### Development Commands
```bash
# Install dbt dependencies
dbt deps

# Debug dbt configuration
dbt debug

# Run all models
dbt run

# Run tests
dbt test

# Full build (run + test)
dbt build

# Generate documentation
dbt docs generate
dbt docs serve
```

### Environment-Specific Commands
```bash
# Development environment
dbt run --target dev

# Production environment  
dbt run --target prod

# PR environment (for CI/CD)
dbt run --target pr --vars '{"schema_id": "unique_identifier"}'
```

### State-Based Commands (for CI/CD)
```bash
# Build only modified models and downstream dependencies
dbt build --select state:modified+ --defer --state path/to/manifest

# Full build when no manifest exists
dbt build
```

## Project Architecture

### Configuration
- **Database**: Google BigQuery
- **Authentication**: Service account JSON with environment variables
- **Profiles**: Three targets (dev, prod, pr) configured in `profiles.yml`
- **Dependencies**: Managed via `packages.yml` with dbt_utils, dbt_project_evaluator, dbt_expectations, and codegen

### Directory Structure
```
models/
├── jaffle-shop/
    ├── staging/          # Raw data transformations
    │   ├── _sources.yml  # Source configurations
    │   └── stg_*.sql     # Staging models
    └── marts/            # Business logic models
        ├── dim_*.sql     # Dimension tables
        └── fact_*.sql    # Fact tables
macros/                   # Custom SQL macros
├── cents_to_dollars.sql  # Cross-database currency conversion
└── drop_pr_staging_schemas.sql
data-tests/              # Custom data tests
seeds/                   # Static reference data
snapshots/              # SCD Type 2 tracking
```

### Key Components

**Staging Layer**: Raw data transformations following the pattern `stg_<source_table>`. All staging models reference sources defined in `_sources.yml`.

**Marts Layer**: Business logic models organized into dimensions (`dim_*`) and facts (`fact_*`) following dimensional modeling principles.

**Custom Macros**: Cross-database compatibility macros like `cents_to_dollars` that handle different SQL dialects (BigQuery, Postgres, Trino).

**Testing Strategy**: Combination of generic tests, custom data tests in `data-tests/`, and source freshness checks configured with 1-day warning, 7-day error thresholds.

## Environment Variables Required

All BigQuery connection parameters are externalized:
- `DBT_ENV_SECRET_PROJECT_ID`
- `DBT_ENV_SECRET_TYPE`
- `DBT_ENV_SECRET_PRIVATE_KEY_ID`
- `DBT_ENV_SECRET_PRIVATE_KEY`
- `DBT_ENV_SECRET_CLIENT_EMAIL`
- `DBT_ENV_SECRET_CLIENT_ID`
- `DBT_ENV_SECRET_AUTH_URI`
- `DBT_ENV_SECRET_TOKEN_URI`
- `DBT_ENV_SECRET_AUTH_PROVIDER_X509_CERT_URL`
- `DBT_ENV_SECRET_CLIENT_X509_CERT_URL`

Optional:
- `ENABLE_DBT_PROJECT_EVALUATOR`: Enable project evaluator package (default: false)
- `DBT_PROJECT_EVALUATOR_SEVERITY`: Severity level for project evaluator (default: warn)

## CI/CD Pipeline Integration

The project uses state-based builds for efficient CI/CD:
- **CI**: Builds only modified models in isolated PR schemas using `--defer` to reference production
- **CD**: Updates production with modified models and downstream dependencies
- **Manifest Management**: Uses `manifest.json` stored in GCP for state comparison

When working locally, use `dbt build` for full builds or implement state-based workflows by downloading production manifest from your deployment platform.