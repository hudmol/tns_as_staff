Rails.application.config.after_initialize do
  # Custom filter listing
  ApplicationHelper.class_eval do
    alias_method :render_aspace_partial_pre_tns_as_staff, :render_aspace_partial
    def render_aspace_partial(args)
      result = render_aspace_partial_pre_tns_as_staff(args)

      if args[:partial] == "search/filter"
        result += javascript_include_tag("#{AppConfig[:frontend_prefix]}assets/tns_filter_listing.js")
      end

      result
    end
  end

  # Custom filters
  # • Classification
  Plugins.add_search_base_facets('classification_paths')
  [:accession, :resource, :digital_object].each do |jsonmodel_type|
    Plugins.add_search_facets(jsonmodel_type, 'classification_paths')
  end

  # • Extent Type
  Plugins.add_search_base_facets('extent_type_enum_s')
  JSONModel.models.each do |jsonmodel_type, model|
    if model.schema["properties"].has_key?('extents')
      Plugins.add_search_facets(jsonmodel_type.intern, 'extent_type_enum_s')
    end
  end
  Plugins.add_facet_group_i18n('extent_type_enum_s', proc{|facet|
    "enumerations.extent_extent_type.#{facet}"
  })

  # • Collection Management • Processing Status
  Plugins.add_search_base_facets('processing_status_enum_s')
  [:accession, :resource, :digital_object].each do |jsonmodel_type|
    Plugins.add_search_facets(jsonmodel_type, 'processing_status_enum_s')
  end
  Plugins.add_facet_group_i18n('processing_status_enum_s', proc{|facet|
    "enumerations.collection_management_processing_status.#{facet}"
  })

  # • Processing Priority
  Plugins.add_search_base_facets('processing_priority_enum_s')
  [:accession, :resource, :digital_object].each do |jsonmodel_type|
    Plugins.add_search_facets(jsonmodel_type, 'processing_priority_enum_s')
  end
  Plugins.add_facet_group_i18n('processing_priority_enum_s', proc{|facet|
    "enumerations.collection_management_processing_priority.#{facet}"
  })

  # • Finding Aid Status
  Plugins.add_search_base_facets('finding_aid_status_enum_s')
  Plugins.add_search_facets(:resource, 'finding_aid_status_enum_s')
  Plugins.add_facet_group_i18n('finding_aid_status_enum_s', proc{|facet|
    "enumerations.resource_finding_aid_status.#{facet}"
  })

  # • Date range by decade
  Plugins.add_search_base_facets('decades_u_uint')
  [:accession, :resource, :archival_object, :digital_object, :digital_object_component].each do |jsonmodel_type|
    Plugins.add_search_facets(jsonmodel_type, 'decades_u_uint')
  end

  # Heavy handed facet overrides!
  SearchResultData.class_eval do
    alias_method :facet_label_string_pre_tns_as_staff, :facet_label_string
    def facet_label_string(facet_group, facet)
      # • Classification display string
      if facet_group == 'classification_paths'
        path = ASUtils.json_parse(facet)
        "#{path.map{|c| c.fetch('identifier')}.join('/')} #{path.last.fetch('title')}"

      # • Date range by decade display string
      elsif facet_group == 'decades_u_uint'
        "#{facet}s"

      else
        facet_label_string_pre_tns_as_staff(facet_group, facet)
      end
    end

    alias_method :sort_facets_pre_tns_as_staff, :sort_facets
    def sort_facets(facet_group, facets)
      # • Date range by decade sorting
      if facet_group == 'decades_u_uint'
        facets.sort { |a, b| b[0].to_i <=> a[0].to_i }.to_h
      else
        sort_facets_pre_tns_as_staff(facet_group, facets)
      end
    end
  end
end