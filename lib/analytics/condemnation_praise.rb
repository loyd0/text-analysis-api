require_relative "../master_word_list"

module CondemnationAndPraiseAnalysis
#the actual analysis function
  def self.analysis(text, regex)
    text.downcase.scan(regex).flatten.length
  end
#constructing the object response
  def self.analysis_constructor(content, content_word_count)
#finds the percentatge of words that relate to the regex/word list and returns a percentage of the unique words in the content it is analysising.
    analysis_constructed = {
      "condemnation": ((analysis(content, self.condemnation_regex) + analysis(content, self.condemnation_regex_plurals)).to_f/content_word_count * 100).round(2),
      "praise": ((analysis(content, self.praise_regex) + analysis(content, self.praise_regex_plurals)).to_f/content_word_count * 100).round(2)
    }
    analysis_constructed
  end

  #creating the regexes - will refactor into better ones once I learn regex better
  def self.condemnation_regex
   /\b(?:#{MasterWordList.CondemnationAndPraise.vice.join("|")})\b/
  end
  def self.condemnation_regex_plurals
   /\b(?:|#{MasterWordList.CondemnationAndPraise.vice.join("|")})(y|ies|s|ing|ed|er)\b/
  end
  def self.praise_regex
    /\b(?:#{MasterWordList.CondemnationAndPraise.virtue.join("|")})\b/
  end
  def self.praise_regex_plurals
    /\b(?:|#{MasterWordList.CondemnationAndPraise.virtue.join("|")})(y|ies|s|ing|ed|er)\b/
  end
end
