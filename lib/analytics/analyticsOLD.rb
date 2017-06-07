require_relative "../master_word_list"

module AnalyticalAnalysisOld

  #the actual analysis function
  def self.analysis(text, regex_1, regex_2)
    paragraphs = []
    text.each_with_index do |para, index|
      paragraphs.push("#{index+1}" => para.downcase.scan(regex_1).flatten.length +  para.downcase.scan(regex_2).flatten.length)
    end
    paragraphs
  end

  #constructing the object response
  def self.analysis_constructor(content, content_word_count)
  #finds the percentatge of words that relate to the regex/word list and returns a percentage of the unique words in the content it is analysising.
    analysis_constructed = {
      "analytical_levels": analysis(content, self.analytics_regex, self.analytics_regex_plurals)
    }
    analysis_constructed
  end

  #creating the regexes - will refactor into better ones once I learn regex better
  def self.analytics_regex
   /\b(?:#{MasterWordList.AnalyticalLevels.analysis.join("|")})\b/
  end
  def self.analytics_regex_plurals
   /\b(?:|#{MasterWordList.AnalyticalLevels.analysis.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
end
