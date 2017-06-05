class Project < ApplicationRecord
  belongs_to :user

  before_create do
    find_subject
    find_themes
  end

  after_find do
    post_test
  end

  private
  #Pre-Hook Saves
  def find_subject
    self.subject = ["test"]
  end

  def find_themes
    self.theme = ["test1", "test2"]
  end

  def post_test
    self.something = "NOT TEST"
    puts self.something
  end

end
