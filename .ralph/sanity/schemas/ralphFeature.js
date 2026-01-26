// Sanity schema for Ralph Feature objects
// This schema matches the feature structure in .ralph/prd.json

export default {
  name: 'ralphFeature',
  title: 'Ralph Feature',
  type: 'object',
  fields: [
    {
      name: 'id',
      title: 'Feature ID',
      type: 'string',
      description: 'Unique identifier for the feature (e.g., "001", "002", "013")',
      validation: (Rule) => Rule.required().regex(/^[0-9]{3}[a-z]?$/, {
        name: 'feature-id',
        invert: false
      }).error('Must be a 3-digit number optionally followed by a letter (e.g., "001", "000a")')
    },
    {
      name: 'type',
      title: 'Type',
      type: 'string',
      description: 'Type of work',
      options: {
        list: [
          { title: 'Feature', value: 'feature' },
          { title: 'Bug', value: 'bug' },
          { title: 'Refactor', value: 'refactor' },
          { title: 'Test', value: 'test' },
          { title: 'Spike', value: 'spike' }
        ],
        layout: 'radio'
      },
      validation: (Rule) => Rule.required()
    },
    {
      name: 'category',
      title: 'Category',
      type: 'string',
      description: 'Feature category',
      options: {
        list: [
          { title: 'Setup', value: 'setup' },
          { title: 'Infrastructure', value: 'infrastructure' },
          { title: 'Functional', value: 'functional' },
          { title: 'Testing', value: 'testing' },
          { title: 'Quality', value: 'quality' },
          { title: 'Documentation', value: 'documentation' }
        ]
      },
      validation: (Rule) => Rule.required()
    },
    {
      name: 'priority',
      title: 'Priority',
      type: 'string',
      description: 'Feature priority',
      options: {
        list: [
          { title: 'Critical', value: 'critical' },
          { title: 'High', value: 'high' },
          { title: 'Medium', value: 'medium' },
          { title: 'Low', value: 'low' }
        ],
        layout: 'radio'
      },
      validation: (Rule) => Rule.required()
    },
    {
      name: 'description',
      title: 'Description',
      type: 'text',
      description: 'Brief description of the feature',
      rows: 3,
      validation: (Rule) => Rule.required().min(10).max(200)
    },
    {
      name: 'steps',
      title: 'Implementation Steps',
      type: 'array',
      description: 'Ordered list of implementation steps',
      of: [
        {
          type: 'string'
        }
      ],
      validation: (Rule) => Rule.required().min(1)
    },
    {
      name: 'estimated_complexity',
      title: 'Estimated Complexity',
      type: 'string',
      description: 'Estimated size of the feature',
      options: {
        list: [
          { title: 'Small (< 1hr)', value: 'small' },
          { title: 'Medium (1-3hrs)', value: 'medium' },
          { title: 'Large (> 3hrs)', value: 'large' }
        ],
        layout: 'radio'
      },
      validation: (Rule) => Rule.required()
    },
    {
      name: 'depends_on',
      title: 'Depends On',
      type: 'array',
      description: 'Feature IDs that must be completed before this one',
      of: [
        {
          type: 'string'
        }
      ]
    },
    {
      name: 'passes',
      title: 'Passes',
      type: 'boolean',
      description: 'True when fully implemented and verified',
      initialValue: false,
      validation: (Rule) => Rule.required()
    },
    {
      name: 'iterations_taken',
      title: 'Iterations Taken',
      type: 'number',
      description: 'Number of Ralph iterations needed to complete',
      initialValue: 0,
      validation: (Rule) => Rule.required().min(0).integer()
    },
    {
      name: 'blocked_reason',
      title: 'Blocked Reason',
      type: 'text',
      description: 'If blocked, explain why (null if not blocked)',
      rows: 3
    }
  ]
}
