class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :subject, :theme, :summary, :keywords, :basic_analysis, :text, :word_extraction, :readability_analysis, :generate_summary, :full_content_analysis, :para_content_analysis, :entity

  has_one :user
end
