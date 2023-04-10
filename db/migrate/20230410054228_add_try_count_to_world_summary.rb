class AddTryCountToWorldSummary < ActiveRecord::Migration[7.0]
  def change
    add_column :world_summaries, :try_count, :integer, default: 0
  end
end
