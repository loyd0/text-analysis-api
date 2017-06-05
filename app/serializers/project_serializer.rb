class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :subject, :theme, :summary, :keywords, :basic_analysis, :text, :word_extraction, :sentiment_analysis, :readability_analysis, :generate_summary

  has_one :user

end
