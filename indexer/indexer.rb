class IndexerCommon

  add_attribute_to_resolve('linked_instances')

  add_indexer_initialize_hook do |indexer|
    indexer.add_document_prepare_hook do |doc, record|
      record = record.fetch('record')

      next unless record['jsonmodel_type'] == 'digital_object'
      next unless record['linked_instances']

      record.fetch('linked_instances', []).each do |ref|
        linked_record = ref.fetch('_resolved')

        resource_uri = if linked_record.fetch('jsonmodel_type') == 'archival_object'
                         linked_record.fetch('resource').fetch('ref')
                       elsif linked_record.fetch('jsonmodel_type') == 'resource'
                         linked_record.fetch('uri').fetch('ref')
                       else
                         # This shouldn't happen in vanilla ArchivesSpace, but I guess someone might have
                         # extended instances to link to other record types.  We'll avoid meddling.
                       end

        if resource_uri
          doc['tns_as_staff_digital_object_linked_resource_u_sstr'] ||= []
          doc['tns_as_staff_digital_object_linked_resource_u_sstr'] << resource_uri
        end
      end
    end

    indexer.add_document_prepare_hook do |doc, record|
      if doc.has_key?('years') && !doc['years'].empty?
        doc['decades_u_uint'] = doc['years'].map{|year| year.to_i - year.to_i % 10}.uniq
      end
    end
  end

end
