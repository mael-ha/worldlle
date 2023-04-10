class AddArrayColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :world_summaries, :headlines, :string, array: true, default: []
    add_column :world_summaries, :keywords, :string, array: true, default: []
    add_column :world_summaries, :country_codes, :string, array: true, default: []
  end
end
