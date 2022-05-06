Rails.application.config.after_initialize do
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
end