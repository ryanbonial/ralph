# Sanity CMS Integration for Ralph PRD

This directory contains Sanity schema definitions and migration tools for storing Ralph PRD (Product Requirements Document) data in Sanity CMS.

## Overview

Ralph can use Sanity CMS as a source of truth for PRD storage, enabling:
- **Team collaboration**: Multiple developers can access and update the PRD
- **Visual editing**: Use Sanity Studio UI for PRD management
- **Version history**: Track changes to features over time
- **Real-time sync**: Changes are immediately available across all Ralph instances

## Directory Structure

```
.ralph/sanity/
├── schemas/              # Sanity schema definitions
│   ├── index.js         # Schema export
│   ├── ralphProject.js  # Main PRD document schema
│   └── ralphFeature.js  # Feature object schema
├── migrate.js           # Migration script (JSON → Sanity)
└── README.md           # This file
```

## Schema Structure

### ralphProject (Document Type)

The main document type representing a complete PRD:

- `project` (string, required): Project name
- `description` (text, required): Project description
- `schema_version` (string): PRD schema version (default: "2.0")
- `features` (array of ralphFeature): List of features
- `notes` (array of text): Project notes and guidance
- `field_definitions` (object): Documentation for field meanings

### ralphFeature (Object Type)

Individual feature within the PRD:

- `id` (string, required): Feature ID (e.g., "001", "013", "000a")
- `type` (string, required): feature | bug | refactor | test | spike
- `category` (string, required): setup | infrastructure | functional | testing | quality | documentation
- `priority` (string, required): critical | high | medium | low
- `description` (text, required): Feature description
- `steps` (array of strings, required): Implementation steps
- `estimated_complexity` (string, required): small | medium | large
- `depends_on` (array of strings): Feature IDs that must be completed first
- `passes` (boolean, required): True when fully implemented (default: false)
- `iterations_taken` (number, required): Number of Ralph iterations to complete (default: 0)
- `blocked_reason` (text, optional): Why the feature is blocked, if applicable

## Setup Instructions

### Option 1: Deploy to Existing Sanity Project

If you already have a Sanity project:

1. **Copy schemas to your Sanity Studio**:
   ```bash
   cp .ralph/sanity/schemas/*.js path/to/your/studio/schemas/
   ```

2. **Import schemas in your Studio config**:
   ```javascript
   // sanity.config.js
   import {ralphProject, ralphFeature} from './schemas'

   export default defineConfig({
     // ... other config
     schema: {
       types: [ralphProject, ralphFeature, /* ...other types */]
     }
   })
   ```

3. **Deploy schema**:
   ```bash
   cd path/to/your/studio
   npx sanity@latest schema deploy
   ```

### Option 2: Deploy Without Local Studio (Using MCP Tools)

If using Claude with Sanity MCP server:

1. **Deploy schemas directly to Sanity Cloud**:
   Use the `mcp__Sanity__deploy_schema` tool with the schema content from:
   - `.ralph/sanity/schemas/ralphFeature.js`
   - `.ralph/sanity/schemas/ralphProject.js`

2. **Configure Ralph** (see below)

### Option 3: Create New Sanity Project

If you don't have a Sanity project yet:

1. **Create project**:
   ```bash
   npm create sanity@latest
   ```

2. **Follow Option 1** to add Ralph schemas

## Migration: JSON → Sanity

To migrate your existing `.ralph/prd.json` to Sanity:

### Using the Migration Script

```bash
# Generate Sanity document JSON
node .ralph/sanity/migrate.js > prd-document.json

# Import to Sanity (requires Sanity CLI)
cd path/to/your/studio
sanity dataset import ../path/to/prd-document.json production --replace
```

### Using Sanity MCP Tools

If using Claude with Sanity MCP:

```bash
# Generate document JSON
node .ralph/sanity/migrate.js > prd-document.json

# Then use mcp__Sanity__create_documents_from_json tool
# with the content from prd-document.json
```

## Configuring Ralph for Sanity

In `ralph.sh`, set these environment variables:

```bash
# Sanity configuration (for future feature 014)
export SANITY_PROJECT_ID="your-project-id"
export SANITY_DATASET="production"
export SANITY_TOKEN="your-write-token"

# PRD storage mode (file | sanity)
export PRD_STORAGE="sanity"  # Use Sanity as source of truth
```

To find your project ID:
- Run `sanity debug --secrets` in your Studio directory
- Or check `sanity.config.js` file
- Or visit https://sanity.io/manage

## Current Status

**Feature 013**: ✅ Schema created
- Sanity schemas are defined and ready to deploy
- Migration script is available
- Configuration added to ralph.sh

**Feature 014**: ✅ Sanity API integration complete
- PRD can be fetched from Sanity using GROQ queries
- Feature status updates via Sanity mutations API
- `PRD_STORAGE=sanity` mode fully functional
- Authentication and error handling implemented
- No local file syncing - Sanity is the single source of truth

## How Sanity Integration Works

When `PRD_STORAGE=sanity`, Ralph operates as follows:

**1. Startup Validation**:
- Validates SANITY_PROJECT_ID, SANITY_DATASET, and SANITY_TOKEN are set
- Tests connection by fetching PRD from Sanity
- Fails fast if configuration is invalid or connection fails

**2. PRD Fetching**:
- Uses GROQ query: `*[_type == "ralphProject"][0]`
- Fetches complete PRD document including all features
- No local file caching - always fetches fresh data

**3. Feature Updates** (by Agent):
- Agent modifies PRD data in Sanity directly
- Uses Sanity mutations API to update feature status
- Updates `passes`, `iterations_taken`, and `blocked_reason` fields
- Changes are immediately visible to all Ralph instances

**4. API Endpoints Used**:
- **Query API**: `https://{projectId}.api.sanity.io/v2021-10-21/data/query/{dataset}`
- **Mutations API**: `https://{projectId}.api.sanity.io/v2021-10-21/data/mutate/{dataset}`

## Testing the Schema

To test the schema without deploying:

```bash
# Validate PRD migration
node .ralph/sanity/migrate.js .ralph/prd.json

# Check for errors in output
# The JSON should be valid Sanity document structure
```

## Next Steps

1. **Deploy schemas** to your Sanity project using one of the options above
2. **Create API token** with Editor permissions at https://sanity.io/manage
3. **Migrate your PRD** using the migration script
4. **Configure environment** with SANITY_PROJECT_ID, SANITY_DATASET, SANITY_TOKEN
5. **Run Ralph** with `PRD_STORAGE=sanity` to use Sanity as source of truth
6. **Optional**: Implement Sanity Studio UI for visual editing (Feature 016)

## Resources

- [Sanity Schema Documentation](https://www.sanity.io/docs/schema-types)
- [Sanity CLI Reference](https://www.sanity.io/docs/cli)
- [Ralph Documentation](../../README.md)
