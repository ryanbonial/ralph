#!/usr/bin/env node

/**
 * Migration script to convert .ralph/prd.json to Sanity documents
 *
 * Usage:
 *   node .ralph/sanity/migrate.js [path-to-prd.json]
 *
 * This script reads a Ralph PRD JSON file and outputs Sanity-compatible
 * document structure that can be imported using the Sanity CLI or MCP tools.
 */

const fs = require('fs');
const path = require('path');

// Read PRD file path from command line or use default
const prdPath = process.argv[2] || path.join(__dirname, '..', 'prd.json');

// Check if file exists
if (!fs.existsSync(prdPath)) {
  console.error(`Error: PRD file not found at ${prdPath}`);
  process.exit(1);
}

// Read and parse PRD
let prdData;
try {
  const prdContent = fs.readFileSync(prdPath, 'utf8');
  prdData = JSON.parse(prdContent);
} catch (error) {
  console.error(`Error reading or parsing PRD file: ${error.message}`);
  process.exit(1);
}

// Validate PRD structure
if (!prdData.project || !prdData.features || !Array.isArray(prdData.features)) {
  console.error('Error: Invalid PRD structure. Must contain "project" and "features" array.');
  process.exit(1);
}

// Generate Sanity document ID from project name
function generateDocumentId(projectName) {
  return projectName
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

// Convert PRD to Sanity document
const sanityDocument = {
  _type: 'ralphProject',
  _id: generateDocumentId(prdData.project),
  project: prdData.project,
  description: prdData.description || '',
  schema_version: prdData.schema_version || '2.0',
  features: prdData.features.map(feature => ({
    _type: 'ralphFeature',
    _key: feature.id,
    id: feature.id,
    type: feature.type || 'feature',
    category: feature.category || 'functional',
    priority: feature.priority || 'medium',
    description: feature.description || '',
    steps: feature.steps || [],
    estimated_complexity: feature.estimated_complexity || 'medium',
    depends_on: feature.depends_on || [],
    passes: feature.passes || false,
    iterations_taken: feature.iterations_taken || 0,
    blocked_reason: feature.blocked_reason || null
  })),
  notes: prdData.notes || [],
  field_definitions: prdData.field_definitions || {}
};

// Output the Sanity document as JSON
console.log(JSON.stringify(sanityDocument, null, 2));

// Print summary to stderr so it doesn't interfere with JSON output
console.error('\n=== Migration Summary ===');
console.error(`Project: ${sanityDocument.project}`);
console.error(`Document ID: ${sanityDocument._id}`);
console.error(`Features: ${sanityDocument.features.length}`);
console.error('========================\n');
console.error('To import this document into Sanity:');
console.error('1. Save the output to a file: node migrate.js > prd-document.json');
console.error('2. Use Sanity CLI: sanity dataset import prd-document.json production');
console.error('3. Or use the Sanity MCP create_documents_from_json tool');
