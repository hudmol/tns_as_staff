Sequel.migration do
  up do
    # self.transaction do
    #   # Migrate pre 3.0 name form authority IDs, sources and dates into Record IDs
    #   [:person, :family, :corporate_entity, :software].each do |agent_type|
    #     self[:"name_#{agent_type}"].
    #   end
    #
    #
    #
    #   source_id = self[:enumeration].join(:enumeration_value,
    #                                       Sequel.qualify(:enumeration, :id) => Sequel.qualify(:enumeration_value, :enumeration_id))
    #                 .filter(Sequel.qualify(:enumeration, :name) => 'name_source')
    #                 .filter(Sequel.qualify(:enumeration_value, :value) => 'local')
    #                 .get(Sequel.qualify(:enumeration_value, :id))
    #
    #   identifier_type_id = self[:enumeration].join(:enumeration_value,
    #                                                Sequel.qualify(:enumeration, :id) => Sequel.qualify(:enumeration_value, :enumeration_id))
    #                          .filter(Sequel.qualify(:enumeration, :name) => 'identifier_type')
    #                          .filter(Sequel.qualify(:enumeration_value, :value) => 'local')
    #                          .get(Sequel.qualify(:enumeration_value, :id))
    #
    #
    #   next_sequence = 1
    #
    #   [:agent_person, :agent_family, :agent_corporate_entity, :agent_software].each do |agent_tbl|
    #     ids_needing_generation = self[agent_tbl]
    #                                .left_join(:agent_record_identifier, Sequel.qualify(agent_tbl, :id) => Sequel.qualify(:agent_record_identifier, :"#{agent_tbl}_id"))
    #                                .filter(Sequel.qualify(:agent_record_identifier, :id) => nil)
    #                                .select(Sequel.qualify(agent_tbl, :id))
    #                                .map(:id)
    #                                .sort
    #
    #     now = Time.now
    #
    #     ids_needing_generation.each do |id|
    #       self[:agent_record_identifier].insert(
    #         :identifier_type_id => identifier_type_id,
    #         :source_id => source_id,
    #         :primary_identifier => 1,
    #         :record_identifier => sprintf(AppConfig[:agent_local_identifier_format], next_sequence),
    #         :"#{agent_tbl}_id" => id,
    #         :created_by => 'admin',
    #         :last_modified_by => 'admin',
    #         :create_time => now,
    #         :system_mtime => now,
    #         :user_mtime => now,
    #         :lock_version => 0,
    #       )
    #
    #       self[agent_tbl].filter(:id => id).update(:system_mtime => now)
    #
    #       next_sequence += 1
    #     end
    #   end
    #
    #   self[:sequence].insert(:sequence_name => "TNS_LOCAL_AGENT_ID",
    #                          :value => next_sequence - 1)
    # end
  end
end
