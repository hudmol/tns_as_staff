class IndexerCommon

  add_attribute_to_resolve('linked_instances::resource')

  add_indexer_initialize_hook do |indexer|
    indexer.add_document_prepare_hook do |doc, record|
      record = record.fetch('record')

      next unless record['jsonmodel_type'] == 'digital_object'
      next unless record['linked_instances']

      resources = []

      record.fetch('linked_instances', []).each do |ref|
        linked_record = ref.fetch('_resolved')

        resource = if linked_record.fetch('jsonmodel_type') == 'archival_object'
                     linked_record.fetch('resource').fetch('_resolved')
                   elsif linked_record.fetch('jsonmodel_type') == 'resource'
                     linked_record
                   else
                     # This shouldn't happen in vanilla ArchivesSpace, but I guess someone might have
                     # extended instances to link to other record types.  We'll avoid meddling.
                   end

        if resource
          resources << resource
        end
      end

      doc['tns_as_staff_digital_object_linked_resource_u_sstr'] = resources.map{|res| res.fetch('uri')}

      doc['tns_as_staff_digital_object_linked_resource_u_ssort'] = resources.map{|res| (0..3).map{|ix| res["id_#{ix}"]}.compact.join('.')}.sort.join(' ')
    end

    indexer.add_document_prepare_hook do |doc, record|
      if doc.has_key?('years') && !doc['years'].empty?
        doc['decades_u_uint'] = doc['years'].map{|year| year.to_i - year.to_i % 10}.uniq
      end
    end
  end


  def self.build_date_field(dates)
    # sort records without dates to the end
    return 'ZZZZZZZZZZ' unless dates && dates.is_a?(Array) && !dates.empty?

    # just return the earliest date mentioned
    dates.map{|d|
      out = d['begin'] || d.fetch('expression', '').sub(/^\D*/, '')
      out.empty? ? 'ZZZZZZZZZZ' : out
    }.min
  end


  def self.build_extent_field(extents)
    # sort records without extents to the end
    return 'ZZZZZZZZZZ' unless extents && extents.is_a?(Array) && !extents.empty?

    (whole, fract) = extents[0]['number'].split('.')
    [whole.rjust(12, '0'), fract].join
  end


  add_indexer_initialize_hook do |indexer|
    indexer.add_document_prepare_hook {|doc, record|
      if doc['primary_type'] == 'accession'
        if cm = record['record']['collection_management']
          doc['processing_status_u_ssort'] = cm['processing_status']
        end
      end
    }

    indexer.add_document_prepare_hook {|doc, record|
      if doc['primary_type'] == 'resource' && !record['record']['extents'].empty?
        doc['extent_sort_type_u_sstr'] = record['record']['extents'][0]['extent_type']
      end
    }

    indexer.add_document_prepare_hook {|doc, record|
      doc['extents_u_ssort'] = self.build_extent_field(record['record']['extents'])
      doc['dates_u_ssort'] = self.build_date_field(record['record']['dates'])
    }

    indexer.add_document_prepare_hook {|doc, record|
      if doc['primary_type'] == 'event'
        doc['agents_u_ssort'] = doc['agents'].join('::')
        doc['linked_records_u_ssort'] = (record['record']['linked_records'].first || {}).fetch('_resolved', {})['title']
      end
    }

    indexer.add_document_prepare_hook {|doc, record|
      if ['resource', 'archival_object'].include?(doc['primary_type'])
        if record['record']['repository_processing_note'].to_s.length > 500
          doc['repository_processing_note_u_ssort'] = record['record']['repository_processing_note'].to_s[0..500] + '...'
        else
          doc['repository_processing_note_u_ssort'] = record['record']['repository_processing_note']
        end
      end
    }
  end

end
