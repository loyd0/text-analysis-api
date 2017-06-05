class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :school
  has_many :projects
end
