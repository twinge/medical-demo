class CreateDecoders < ActiveRecord::Migration
  def self.up
    create_table :decoders do |t|
      t.string :address, :title
      t.timestamps
    end
    Decoder.create(:address => '10.1.50.54', :title => 'Preview Room')
  end

  def self.down
    drop_table :decoders
  end
end
