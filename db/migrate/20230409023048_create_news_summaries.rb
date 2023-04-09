class CreateNewsSummaries < ActiveRecord::Migration[7.0]
  def change
    create_table :news_summaries do |t|
      t.string :summary
      t.string :image_url

      t.timestamps
    end
  end
end
