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

  # Heavy handed facet display string overrides!
  SearchResultData.class_eval do
    alias_method :facet_label_string_pre_tns_as_staff, :facet_label_string
    def facet_label_string(facet_group, facet)
      # • Classification
      if facet_group == 'classification_paths'
        path = ASUtils.json_parse(facet)
        "#{path.map{|c| c.fetch('identifier')}.join('/')} #{path.last.fetch('title')}"
      else
        facet_label_string_pre_tns_as_staff(facet_group, facet)
      end
    end
  end
end