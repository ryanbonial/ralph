// Sanity schema for Ralph Project (PRD)
// This schema represents the complete Product Requirements Document

export default {
  name: 'ralphProject',
  title: 'Ralph Project',
  type: 'document',
  fields: [
    {
      name: 'project',
      title: 'Project Name',
      type: 'string',
      description: 'Name of the project',
      validation: (Rule) => Rule.required().min(3).max(100)
    },
    {
      name: 'description',
      title: 'Description',
      type: 'text',
      description: 'Brief description of the project',
      rows: 4,
      validation: (Rule) => Rule.required().min(10)
    },
    {
      name: 'schema_version',
      title: 'Schema Version',
      type: 'string',
      description: 'PRD schema version (e.g., "2.0")',
      initialValue: '2.0',
      validation: (Rule) => Rule.required()
    },
    {
      name: 'features',
      title: 'Features',
      type: 'array',
      description: 'List of features to implement',
      of: [
        {
          type: 'ralphFeature'
        }
      ],
      validation: (Rule) => Rule.required().min(1)
    },
    {
      name: 'notes',
      title: 'Notes',
      type: 'array',
      description: 'Project notes and guidance',
      of: [
        {
          type: 'text',
          rows: 3
        }
      ]
    },
    {
      name: 'field_definitions',
      title: 'Field Definitions',
      type: 'object',
      description: 'Documentation for field meanings',
      fields: [
        {
          name: 'type',
          title: 'Type Definition',
          type: 'text',
          rows: 2
        },
        {
          name: 'category',
          title: 'Category Definition',
          type: 'text',
          rows: 2
        },
        {
          name: 'priority',
          title: 'Priority Definition',
          type: 'text',
          rows: 2
        },
        {
          name: 'estimated_complexity',
          title: 'Complexity Definition',
          type: 'text',
          rows: 2
        },
        {
          name: 'depends_on',
          title: 'Dependencies Definition',
          type: 'text',
          rows: 2
        },
        {
          name: 'passes',
          title: 'Passes Definition',
          type: 'text',
          rows: 2
        },
        {
          name: 'iterations_taken',
          title: 'Iterations Taken Definition',
          type: 'text',
          rows: 2
        },
        {
          name: 'blocked_reason',
          title: 'Blocked Reason Definition',
          type: 'text',
          rows: 2
        }
      ]
    }
  ],
  preview: {
    select: {
      title: 'project',
      subtitle: 'description'
    }
  }
}
