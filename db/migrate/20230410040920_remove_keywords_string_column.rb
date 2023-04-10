class RemoveKeywordsStringColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :world_summaries, :keywords
    remove_column :world_summaries, :top_keywords
  end
end
