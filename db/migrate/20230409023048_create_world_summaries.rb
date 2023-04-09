class CreateWorldSummaries < ActiveRecord::Migration[7.0]
  def change
    create_table :world_summaries do |t|
      t.string :keywords
      t.string :top_keywords
      t.string :story
      t.string :image_prompt
      t.string :image_url
      t.string :last_country_code

      t.timestamps
    end
  end
end
