require "spec_helper"

RSpec.describe SnapshotAssociation do

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

    it 'snapshots columns on associated Thing before creation' do
      expect(@thing_event.thing_name).to eq(@thing.name)
    end
  end
end
