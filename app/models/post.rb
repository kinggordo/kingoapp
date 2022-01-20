class Post < ApplicationRecord
	has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [50, 50]
  	end
  	validates :title, presence: true
  	validates :image, attached: true, content_type: ['image/png', 'image/jpg', 'image/jpeg']
	include PgSearch::Model
  	pg_search_scope :global_search, against: [:title], using: { tsearch: { prefix: true } }
end
