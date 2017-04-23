module SnapshotAssociation
 class Snapshot
   attr_reader :base_klass, :snapshot_klass, :old_column_mapping
   def initialize(scope, snapshot_klass, column_mapping={})
     @base_klass = scope
     @snapshot_klass = snapshot_klass
     @old_column_mapping = column_mapping
   end

   def register_callback(snapshot_klass, old_column_mapping={}, callback_name: nil)
     @base_klass.class_eval do
       method_name = "snapshot_#{snapshot_klass.to_s.downcase}_fields".to_sym
       define_method method_name do
        SnapshotAssociation::Snapshot.snapshot_fields(self, self.class, snapshot_klass, old_column_mapping)
       end

       callback_name = :before_create if callback_name.nil?
       raise 'Must define a valid ActiveRecord::Callback on a snapshot association' unless ActiveRecord::Callbacks::CALLBACKS.include? callback_name.to_sym

       callback_type = callback_name.to_s.split('_')[1]
       raise 'Snapshot associations only valid on create or save callbacks.' unless ['save', 'create'].include? callback_type

       send(callback_name, method_name)
     end
   end

   def self.snapshot_fields(scope, base_klass, snapshot_klass, old_column_mapping)
     shared_columns = shared_columns(base_klass, snapshot_klass)
     association_name = snapshot_klass.to_s.downcase

     shared_columns.each do |name|
       scope.write_attribute(name, scope.send(association_name).send(name.sub("#{association_name}_", "")))
     end

     old_columns = base_klass.columns.map(&:name).grep(Regexp.new association_name) - shared_columns

     old_columns.each do |name|
       old_column_key = name.gsub("#{association_name}_", '').to_sym
       if old_column_mapping.key? old_column_key
         new_column_on_snapshot_klass = old_column_mapping[old_column_key]
         scope.write_attribute(name, scope.send(association_name).send(new_column_on_snapshot_klass))
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
