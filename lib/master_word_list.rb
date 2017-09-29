require_relative "word_lists/abstraction"
require_relative "word_lists/active"
require_relative "word_lists/analysis"
require_relative "word_lists/buildings"
require_relative "word_lists/economics"
require_relative "word_lists/human"
require_relative "word_lists/law"
require_relative "word_lists/media"
require_relative "word_lists/negative_words"
require_relative "word_lists/passive"
require_relative "word_lists/politics"
require_relative "word_lists/positive_words"
require_relative "word_lists/pronouns"
require_relative "word_lists/relationship_abstract"
require_relative "word_lists/religeous"
require_relative "word_lists/social"
require_relative "word_lists/strong"
require_relative "word_lists/vice"
require_relative "word_lists/virtue"
require_relative "word_lists/weak"

module MasterWordList
  def self.AbstractionAnalysis
    extend Abstraction
  end


  def self.Voice
    extend Active
    extend Passive
    extend Strong
    extend Weak
    extend Pronouns
  end

  def self.AnalyticalLevels
    extend Analysis
  end

  def self.ForAndAgainst
    extend NegativeWords
    extend PositiveWords
  end

  def self.Comparision
    extend RelationshipAbstraction
  end

  def self.Themes
    extend Buildings
    extend Economics
    extend Law
    extend Human
    extend Media
    extend Politics
    extend Religious
    extend Social
  end

  def self.Ethics
    MasterWordList.CondemnationAndPraise.vice.push(MasterWordList.CondemnationAndPraise.virtue).flatten.uniq
  end
  def self.Pronouns
    #includes you & our & self
    extend Pronouns
  end

  def self.CondemnationAndPraise
    extend Vice
    extend Virtue
  end

  def self.write
    testing = File.open('/Users/Sam/Desktop/word_lists.txt', 'w')
    testing.puts "VIRTUE"
    testing.puts MasterWordList.CondemnationAndPraise.virtue
  end
end


# MasterWordList.write
