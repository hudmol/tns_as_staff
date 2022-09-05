Sequel.migration do
  up do
    self.transaction do
      local_source_id = self[:enumeration].join(:enumeration_value,
                                          Sequel.qualify(:enumeration, :id) => Sequel.qualify(:enumeration_value, :enumeration_id))
                    .filter(Sequel.qualify(:enumeration, :name) => 'name_source')
                    .filter(Sequel.qualify(:enumeration_value, :value) => 'local')
                    .get(Sequel.qualify(:enumeration_value, :id))

      identifier_type_id = self[:enumeration].join(:enumeration_value,
                                                   Sequel.qualify(:enumeration, :id) => Sequel.qualify(:enumeration_value, :enumeration_id))
                             .filter(Sequel.qualify(:enumeration, :name) => 'identifier_type')
                             .filter(Sequel.qualify(:enumeration_value, :value) => 'local')
                             .get(Sequel.qualify(:enumeration_value, :id))

      usage_dates_id = self[:enumeration].join(:enumeration_value,
                                               Sequel.qualify(:enumeration, :id) => Sequel.qualify(:enumeration_value, :enumeration_id))
                         .filter(Sequel.qualify(:enumeration, :name) => 'date_label')
                         .filter(Sequel.qualify(:enumeration_value, :value) => 'usage')
                         .get(Sequel.qualify(:enumeration_value, :id))

      existence_dates_id = self[:enumeration].join(:enumeration_value,
                                               Sequel.qualify(:enumeration, :id) => Sequel.qualify(:enumeration_value, :enumeration_id))
                         .filter(Sequel.qualify(:enumeration, :name) => 'date_label')
                         .filter(Sequel.qualify(:enumeration_value, :value) => 'existence')
                         .get(Sequel.qualify(:enumeration_value, :id))


      # Migrate all existing authority IDs into record identifiers, and any existing
      # dates of name usage into existence dates.
      [:person, :family, :corporate_entity, :software].each do |agent_type|
        agent_table = :"agent_#{agent_type}"
        name_table = :"name_#{agent_type}"

        ids_needing_generation = self[agent_table]
                                   .left_join(:agent_record_identifier, Sequel.qualify(agent_table, :id) => Sequel.qualify(:agent_record_identifier, :"#{agent_table}_id"))
                                   .filter(Sequel.qualify(:agent_record_identifier, :id) => nil)
                                   .select(Sequel.qualify(agent_table, :id))
                                   .map(:id)
                                   .sort

        now = Time.now

        ids_needing_generation.each do |id|
          name_to_promote = self[name_table].filter(:"agent_#{agent_type}_id" => id, :is_display_name => 1).first
          name_to_promote ||= self[name_table].filter(:"agent_#{agent_type}_id" => id, :authorized => 1).first
          name_to_promote ||= self[name_table].filter(:"agent_#{agent_type}_id" => id).order(:id).first

          if name_to_promote &&
             (source_id = name_to_promote.fetch(:source_id, nil)) &&
             (authority_id = self[:name_authority_id].filter(:"name_#{agent_type}_id" => name_to_promote.fetch(:id)).first)

            unless self[:agent_record_identifier].filter(:source_id => source_id,
                                                         :primary_identifier => 1,
                                                         :record_identifier => authority_id.fetch(:authority_id),
                                                         :"#{agent_table}_id" => id).count > 0

              self[:agent_record_identifier].insert(
                :source_id => source_id,
                :primary_identifier => 1,
                :record_identifier => authority_id.fetch(:authority_id),
                :"#{agent_table}_id" => id,
                :created_by => 'admin',
                :last_modified_by => 'admin',
                :create_time => now,
                :system_mtime => now,
                :user_mtime => now,
                :lock_version => 0,
              )
            end

            unless self[:structured_date_label]
                     .filter(:date_label_id => existence_dates_id,
                             :"agent_#{agent_type}_id" => id)
                     .count > 0

              # Look for dates of name use and promote to dates of existence
              date_label_id = self[:structured_date_label]
                                .filter(:name_person_id => name_to_promote.fetch(:id),
                                        :date_label_id => usage_dates_id)
                                .get(:id)

              if date_label_id
                begin_expr = nil
                end_expr = nil

                if (range = self[:structured_date_range].filter(:structured_date_label_id => date_label_id).first)
                  begin_expr = range.fetch(:begin_date_expression)
                  end_expr = range.fetch(:end_date_expression)
                elsif (single = self[:structured_date_single].filter(:structured_date_label_id => date_label_id).first)
                  begin_expr = single.fetch(:date_expression)
                  end_expr = nil
                end

                if begin_expr
                  label_id = self[:structured_date_label].insert(:date_label_id => existence_dates_id,
                                                                 :"agent_#{agent_type}_id" => id,
                                                                 :created_by => 'admin',
                                                                 :last_modified_by => 'admin',
                                                                 :create_time => now,
                                                                 :system_mtime => now,
                                                                 :user_mtime => now,
                                                                 :lock_version => 0)

                  row = {
                    :structured_date_label_id => label_id,
                    :begin_date_expression => begin_expr,
                    :end_date_expression => end_expr,
                    :created_by => 'admin',
                    :last_modified_by => 'admin',
                    :create_time => now,
                    :system_mtime => now,
                    :user_mtime => now,
                    :lock_version => 0
                  }

                  self[:structured_date_range].insert(:structured_date_label_id => label_id,
                                                      :begin_date_expression => begin_expr,
                                                      :end_date_expression => end_expr,
                                                      :created_by => 'admin',
                                                      :last_modified_by => 'admin',
                                                      :create_time => now,
                                                      :system_mtime => now,
                                                      :user_mtime => now,
                                                      :lock_version => 0)
                end
              end
            end

            # Reindex the agent
            self[agent_table].filter(:id => id).update(:system_mtime => now)
          end
        end
      end

      # Now any agents that don't have IDs need local identifiers assigned.
      next_sequence = 1
      [:person, :family, :corporate_entity, :software].each do |agent_type|
        agent_table = :"agent_#{agent_type}"
        name_table = :"name_#{agent_type}"

        ids_needing_generation = self[agent_table]
                                   .left_join(:agent_record_identifier, Sequel.qualify(agent_table, :id) => Sequel.qualify(:agent_record_identifier, :"#{agent_table}_id"))
                                   .filter(Sequel.qualify(:agent_record_identifier, :id) => nil)
                                   .select(Sequel.qualify(agent_table, :id))
                                   .map(:id)
                                   .sort

        now = Time.now

        ids_needing_generation.each do |id|
          self[:agent_record_identifier].insert(
            :identifier_type_id => identifier_type_id,
            :source_id => local_source_id,
            :primary_identifier => 1,
            :record_identifier => sprintf(AppConfig[:agent_local_identifier_format], next_sequence),
            :"#{agent_table}_id" => id,
            :created_by => 'admin',
            :last_modified_by => 'admin',
            :create_time => now,
            :system_mtime => now,
            :user_mtime => now,
            :lock_version => 0,
          )

          self[agent_table].filter(:id => id).update(:system_mtime => now)

          next_sequence += 1
        end
      end

      self[:sequence].insert(:sequence_name => "TNS_LOCAL_AGENT_ID",
                             :value => next_sequence - 1)
    end
  end
end
