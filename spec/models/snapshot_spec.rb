require 'spec_helper'

# t = Thing.new(name: 'asdfas', email: 'asdfas@adslfk.com')
# te = ThingEvent.new(name: 'asdfasf', description: 'adsfasdf', thing_name: 'asdfasdfasd', thing_email: 'asdfas')
# s = SnapshotAssociation::Snapshot.new(te.class, t.class, {})

RSpec.describe 'SnapshotAssociation::Snapshot' do
  describe '#initialize' do
    it 'sets ivars on initialization' do
      s = SnapshotAssociation::Snapshot.new(ThingEvent, Thing, {})
      expect(s.base_klass).to eq ThingEvent
      expect(s.snapshot_klass).to eq Thing
      expect(s.old_column_mapping).to eq({})
    end

    it 'sets old_column_mapping to an empty hash by default' do
      s = SnapshotAssociation::Snapshot.new(ThingEvent, Thing)
      expect(s.old_column_mapping).to eq({})
    end
  end

  describe '#register_callback' do
    it 'defines a before_create callback if no argument given' do
      s = SnapshotAssociation::Snapshot.new(ThingEvent, Thing)
      s.register_callback
      all_callbacks = ThingEvent.send("_save_callbacks").to_a
      all_callbacks.push *ThingEvent.send("_create_callbacks")
      expect(all_callbacks.detect{ |c| (c.name == :create && c.kind == :before) && (c.filter == :snapshot_thing_fields) }).to_not be nil
    end

    it 'defines a custom callback if argument given' do
      s = SnapshotAssociation::Snapshot.new(ThingEvent, Thing)
      s.register_callback(callback_name: :before_save)
      all_callbacks = ThingEvent.send("_save_callbacks").to_a
      all_callbacks.push *ThingEvent.send("_create_callbacks")
      expect(all_callbacks.detect{ |c| (c.name == :save && c.kind == :before) && (c.filter == :snapshot_thing_fields) }).to_not be nil
    end

    it 'raises if callback is not a save or create callback' do
      s = SnapshotAssociation::Snapshot.new(ThingEvent, Thing)
      expect{s.register_callback(callback_name: :after_destroy)}.to raise_error 'Snapshot associations only valid on create or save callbacks.'
    end

    it 'raises if callback type is nonsense' do
      s = SnapshotAssociation::Snapshot.new(ThingEvent, Thing)
      expect{s.register_callback(callback_name: :before_bedtime)}.to raise_error 'Must define a valid ActiveRecord::Callback on a snapshot association'
    end
  end
end
