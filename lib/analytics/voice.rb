require_relative "../master_word_list"

module VoiceAnalysis

  #the actual analysis function
  def self.analysis(text, regex_1, regex_2)
    text.downcase.scan(regex_1).flatten.length + text.downcase.scan(regex_2).flatten.length
  end

  #constructing the object response
  def self.analysis_constructor(content, content_word_count)
  #finds the percentatge of words that relate to the regex/word list and returns a percentage of the unique words in the content it is analysising.
  paragraphs = []
  content.each_with_index do |para, index|
    paragraphs.push("#{index + 1}": {
      "strength": analysis(para, self.strength_regex, self.strength_regex_plurals),
      "weakness": analysis(para, self.weakness_regex, self.weakness_regex_plurals),
      "passive": analysis(para, self.passive_regex, self.passive_regex_plurals),
      "active": analysis(para, self.active_regex, self.active_regex_plurals)
    })
  end
    paragraphs
  end

  #creating the regexes - will refactor into better ones once I learn regex better
  def self.strength_regex
   /\b(?:#{MasterWordList.Voice.strong.join("|")})\b/
  end
  def self.strength_regex_plurals
   /\b(?:|#{MasterWordList.Voice.strong.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
  def self.weakness_regex
   /\b(?:#{MasterWordList.Voice.weak.join("|")})\b/
  end
  def self.weakness_regex_plurals
   /\b(?:|#{MasterWordList.Voice.weak.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
  def self.passive_regex
   /\b(?:#{MasterWordList.Voice.passive.join("|")})\b/
  end
  def self.passive_regex_plurals
   /\b(?:|#{MasterWordList.Voice.passive.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
  def self.active_regex
   /\b(?:#{MasterWordList.AbstractionAnalysis.active.join("|")})\b/
  end
  def self.active_regex_plurals
   /\b(?:|#{MasterWordList.AbstractionAnalysis.active.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
end
