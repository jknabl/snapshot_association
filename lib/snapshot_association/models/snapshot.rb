module SnapshotAssociation
 class Snapshot

   def initialize(scope, snapshot_klass, column_mapping)
     @base_klass = scope
     @snapshot_klass = snapshot_klass
     @old_column_mapping = column_mapping || {}

     register_callback(@base_klass, @snapshot_klass, @old_column_mapping)
   end

   def register_callback(scope, snapshot_klass, old_column_mapping)
     scope.class_eval do
       method_name = "snapshot_#{snapshot_klass.to_s.downcase}_fields".to_sym
       define_method method_name do
        SnapshotAssociation::Snapshot.snapshot_fields(self, scope, snapshot_klass, old_column_mapping)
       end
       send(:before_create, method_name)
     end
   end

   def self.snapshot_fields(scope, base_klass, snapshot_klass, old_column_mapping)
     shared_columns = shared_columns(base_klass, snapshot_klass)
     shared_columns.each do |name|
       scope.write_attribute(name, scope.send(snapshot_klass.to_s.downcase).send(name.sub("#{snapshot_klass.to_s.downcase}_", "")))
     end

     old_columns = base_klass.columns.map(&:name).grep(Regexp.new snapshot_klass.to_s.downcase) - shared_columns

     old_columns.each do |name|
       old_column_key = name.gsub("#{snapshot_klass.to_s.downcase}_", '').to_sym
       if old_column_mapping.key? old_column_key
         new_column_on_snapshot_klass = old_column_mapping[old_column_key]
         scope.write_attribute(name, scope.send(snapshot_klass.to_s.downcase).send(new_column_on_snapshot_klass))
       end
     end
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
 end
end
