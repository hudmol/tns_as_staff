module GenerateLocalAgentIdentifier

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def create_from_json(json, opts = {})
      # If identifiers are missing and we're creating this agency ourselves (i.e. not via import)
      if ASUtils.wrap(json.agent_record_identifiers).empty? && high_priority?
        json.agent_record_identifiers = [
          {
            'jsonmodel_type' => 'agent_record_identifier',
            'primary_identifier' => true,
            'record_identifier' => sprintf(AppConfig[:agent_local_identifier_format], Sequence.get("TNS_LOCAL_AGENT_ID")),
            'source' => 'local',
            'identifier_type' => 'local',
          }
        ]
      end

      super
    end
  end

end
