Sequel.migration do
  up do
    self[:digital_object].update(:system_mtime => Time.now)
  end
end
