require "spec_helper"


RSpec.describe SnapshotAssociation do
  describe 'the test objects that we set up to persist' do
    describe Thing do
      it 'persists a Thing to the DB' do
        @thing = Thing.create(name: 'a thing', email: 'thing@thinghing.com')
        expect(Thing.where(name: 'a thing').first.id).to eq @thing.id
      end
    end

    describe ThingEvent do
      before do
        @thing = Thing.create(name: 'a thing', email: 'thing@thinghing.com')
        @thing_event = ThingEvent.create(name: 'a thing event', description: 'asdf', thing: @thing)
      end

      it 'persists a ThingEvent to the DB' do
        expect(ThingEvent.where(name: 'a thing event').first.id).to eq @thing_event.id
      end

      it 'recognizes a ThingEvent.thing association' do
        expect(@thing_event.thing).to be @thing
      end
    end
  end

  describe 'adding a snapshot association to a class' do
    it 'sets and persists snapshot fields on a base model' do
      class ThingEvent < ActiveRecord::Base
        extend ::SnapshotAssociation::SnapshotMethods
        snapshot :thing
      end

      t = Thing.create(name: 'asfdas', email: 'asdfas@asdlf.com', renamed_email: 'asfas@askdfjh.com')
      te = ThingEvent.new(name: 'asfas', description: 'asdfas', thing: t)

      [:thing_name, :thing_email].each do |attr|
        expect(te.send(attr)).to be nil
      end

      te.save

      [:thing_name, :thing_email].each do |attr|
        expect(te.send(attr)).to eq t.send(attr.to_s.sub('thing_', ''))
      end
    end

    it 'sets and persists snapshot fields with custom column mappings' do
      class ThingEvent < ActiveRecord::Base
        extend ::SnapshotAssociation::SnapshotMethods
        snapshot :thing, column_mapping: {renamed_email: 'thing_email'}
      end

      t = Thing.create(name: 'asfdas', email: 'asdfas@asdlf.com', renamed_email: 'asfas@askdfjh.com')
      te = ThingEvent.new(name: 'asfas', description: 'asdfas', thing: t)

      expect(te.thing_email).to be nil
      te.save
      expect(te.thing_email).to eq t.renamed_email
    end
  end
end
