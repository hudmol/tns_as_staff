module SearchAndBrowseColumnPlugin
  def self.config
    {
      'multi' => {
        :add => {
          'extents' => {
            :field => 'extents',
            :sortable => true,
            :sort_by => 'extents_u_ssort',
          },
          'dates' => {
            :field => 'dates',
            :sortable => true,
            :sort_by => 'dates_u_ssort',
          },
        },
      },
      'accession' => {
        :add => {
          'processing_status' => {
            :field => 'processing_status_u_ssort',
            :sortable => true,
            :locale_key => 'enumerations.collection_management_processing_status',
          },
          'extents' => {
            :field => 'extents',
            :sortable => true,
            :sort_by => 'extents_u_ssort',
          },
          'dates' => {
            :field => 'dates',
            :sortable => true,
            :sort_by => 'dates_u_ssort',
          },
        },
      },
      'resource' => {
        :add => {
          'extents' => {
            :field => 'extents',
            :sortable => true,
            :sort_by => 'extents_u_ssort',
          },
          'dates' => {
            :field => 'dates',
            :sortable => true,
            :sort_by => 'dates_u_ssort',
          },
          'repository_processing_note' => {
            :field => 'repository_processing_note_u_ssort',
            :sortable => true,
          },
        },
      },
      'event' => {
        :add => {
          'agents' => {
            :field => 'agents',
            :sortable => true,
            :sort_by => 'agents_u_ssort',
          },
          'linked_records' => {
            :field => 'linked_records',
            :sortable => true,
            :sort_by => 'linked_records_u_ssort',
          },
        },
      },
      'digital_object' => {
        :add => {
          'extents' => {
            :field => 'resource_ids',
            :sortable => true,
            :sort_by => 'extents_u_ssort',
          },
        },
      },
    }
  end
end
