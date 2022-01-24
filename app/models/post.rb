class Post < ApplicationRecord
	after_create_commit { broadcast_prepend_to "posts" }
	after_destroy_commit { broadcast_remove_to "posts" }
	after_update_commit { broadcast_replace_to "posts" }
	has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  	end
  	validates :title, presence: true
  	validates :image, attached: true, content_type: ['image/png', 'image/jpg', 'image/jpeg']
	include PgSearch::Model
  	pg_search_scope :global_search, against: [:title], using: { tsearch: { prefix: true } }
end
