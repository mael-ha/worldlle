class WorldSummary < ApplicationRecord
    scope :today, -> { where(created_at: Time.current.beginning_of_day..Time.current.end_of_day) }

    def reset_image
        update!(story: nil, image_prompt: nil, image_url: nil)
    end
end
