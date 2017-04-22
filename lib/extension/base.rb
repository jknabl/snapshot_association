module ActiveRecord
  class Base
    class << self
      def snapshot(snapshot_klass_name, column_mapping: nil)
        snapshot_klass = snapshot_klass_name.to_s.classify.constantize
        s = ::SnapshotAssociation::Snapshot.new(self, snapshot_klass, column_mapping)
      end
    end
  end
end
