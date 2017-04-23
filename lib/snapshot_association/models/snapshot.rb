module SnapshotAssociation
  class Snapshot
    attr_reader :base_klass, :snapshot_klass, :old_column_mapping
    def initialize(scope, snapshot_klass, column_mapping={})
      @base_klass = scope
      @snapshot_klass = snapshot_klass
      @old_column_mapping = column_mapping
    end

    def register_callback(callback_name: nil)
      @base_klass.class_exec(self) do |scope|
        method_name = "snapshot_#{scope.snapshot_klass.to_s.downcase}_fields".to_sym
        define_method method_name do
          SnapshotAssociation::Snapshot.snapshot_fields(self, scope.snapshot_klass, scope.old_column_mapping)
        end

        callback_name = :before_create if callback_name.nil?
        raise 'Must define a valid ActiveRecord::Callback on a snapshot association' unless ActiveRecord::Callbacks::CALLBACKS.include? callback_name.to_sym

        callback_type = callback_name.to_s.split('_')[1]
        raise 'Snapshot associations only valid on create or save callbacks.' unless ['save', 'create'].include? callback_type

        send(callback_name, method_name)
      end
    end

    def self.snapshot_fields(scope, snapshot_klass, old_column_mapping={})
      shared_columns = shared_columns(scope.class, snapshot_klass)
      shared_columns.reject!{ |name| old_column_mapping.keys.include? "#{snapshot_klass.to_s.downcase}_#{name}".to_sym }
      association_name = snapshot_klass.to_s.downcase
      old_column_mapping.values.each { |v| shared_columns.delete(v) }
      write_columns(scope, shared_columns, old_column_mapping, association_name)
    end

    def self.shared_columns(base_klass, snapshot_klass)
      prefix = "#{snapshot_klass.to_s.downcase}_"
      base_klass_columns = base_klass.columns.map(&:name)
      snapshot_klass_columns = snapshot_klass.columns.map{ |name| "#{prefix}#{name.name}" }
      cols = base_klass_columns & snapshot_klass_columns
    end

    def shared_columns(base_klass, snapshot_klass)
      SnapshotAssociation::Snapshot.shared_columns(base_klass, snapshot_klass)
    end


    def self.write_columns(scope, shared_columns, old_column_mapping, association_name)
      shared_columns.each do |name|
        scope.write_attribute(name, scope.send(association_name).send(name.sub("#{association_name}_", "")))
      end

      old_column_mapping.each do |snapshot_klass_col, base_class_col|
        scope.write_attribute(base_class_col, scope.send(association_name).send(snapshot_klass_col))
      end
    end
  end
end
