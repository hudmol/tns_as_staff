Sequel.migration do
  up do
    self[:resource]
      .filter(Sequel.~(:repository_processing_note => nil))
      .update(:system_mtime => Time.now)

    self[:archival_object]
      .filter(Sequel.~(:repository_processing_note => nil))
      .update(:system_mtime => Time.now)
  end
end
