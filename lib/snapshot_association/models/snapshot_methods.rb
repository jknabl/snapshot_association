module SnapshotAssociation
  module SnapshotMethods
    def snapshot(snapshot_klass_name, column_mapping: {})
      snapshot_klass = snapshot_klass_name.to_s.classify.constantize
      s = ::SnapshotAssociation::Snapshot.new(self, snapshot_klass, column_mapping)
      s.register_callback
    end
  end
end