class CreateChannels < ActiveRecord::Migration
  def self.up
    create_table :channels do |t|
      t.integer :number
      t.string :title
      t.string :callsign
      t.string :source_url

      t.timestamps
    end
    
    Channel.create(:number => 100, :title => 'OR-10: Endo Cam', :callsign => 'haiDVI-hi', :source_url => 'uuid:0001737c-0000-0000-0000-000000000000')
    Channel.create(:number => 102, :title => 'OR-11: Room Cam', :callsign => 'haiSDI-hi', :source_url => 'uuid:0001737e-0000-0000-0000-000000000000')
    Channel.create(:number => 101, :title => 'OR-10: Endo Cam', :callsign => 'haiDVI-low', :source_url => 'uuid:0001737d-0000-0000-0000-000000000000')
    Channel.create(:number => 103, :title => 'OR-11: Room Cam', :callsign => 'haiSDI-low', :source_url => 'uuid:0001737f-0000-0000-0000-000000000000')
  end

  def self.down
    drop_table :channels
  end
end
