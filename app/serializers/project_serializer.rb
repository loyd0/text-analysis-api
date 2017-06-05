class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :subject, :theme, :summary, :keywords
  has_one :user
end
