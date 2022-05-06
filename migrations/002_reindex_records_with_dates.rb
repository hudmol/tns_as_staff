Sequel.migration do
  up do
    [:accession, :resource, :archival_object, :digital_object, :digital_object_component].each do |record_type|
      self[record_type].update(:system_mtime => Time.now)
    end
  end
end
