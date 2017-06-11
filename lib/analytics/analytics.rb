require_relative "../master_word_list"

module AnalyticalAnalysis

  #the actual analysis function
  def self.analysis(text, regex_1, regex_2)
    text.downcase.scan(regex_1).flatten.length + text.downcase.scan(regex_2).flatten.length
  end

  #constructing the object response
  def self.analysis_constructor(content, content_word_count)
  #finds the percentatge of words that relate to the regex/word list and returns a percentage of the unique words in the content it is analysising.
  paragraphs = []
  content.each_with_index do |para, index|
    paragraphs.push({
      "analytical_levels": analysis(para, self.analytics_regex, self.analytics_regex_plurals),
      "comparative_language": analysis(para, self.comparisons_regex, self.comparisons_regex_plurals),
      "abstraction": analysis(para, self.abstraction_regex, self.abstraction_regex_plurals),
      "for": analysis(para, self.for_regex, self.for_regex_plurals),
      "against": analysis(para, self.against_regex, self.against_regex_plurals)
    })
  end
    paragraphs
  end

  #creating the regexes - will refactor into better ones once I learn regex better
  def self.analytics_regex
   /\b(?:#{MasterWordList.AnalyticalLevels.analysis.join("|")})\b/
  end
  def self.analytics_regex_plurals
   /\b(?:|#{MasterWordList.AnalyticalLevels.analysis.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
  def self.comparisons_regex
   /\b(?:#{MasterWordList.Comparision.relationship_abstract.join("|")})\b/
  end
  def self.comparisons_regex_plurals
   /\b(?:|#{MasterWordList.Comparision.relationship_abstract.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
  def self.abstraction_regex
   /\b(?:#{MasterWordList.AbstractionAnalysis.abstract.join("|")})\b/
  end
  def self.abstraction_regex_plurals
   /\b(?:|#{MasterWordList.AbstractionAnalysis.abstract.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
  def self.for_regex
   /\b(?:#{MasterWordList.ForAndAgainst.positive_words.join("|")})\b/
  end
  def self.for_regex_plurals
   /\b(?:|#{MasterWordList.ForAndAgainst.positive_words.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
  def self.against_regex
    /\b(?:#{MasterWordList.ForAndAgainst.negative_words.join("|")})\b/
  end
  def self.against_regex_plurals
    /\b(?:|#{MasterWordList.ForAndAgainst.negative_words.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
end
