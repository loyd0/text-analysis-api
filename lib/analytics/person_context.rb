require_relative "../master_word_list"

module PersonContext
  #the actual analysis function
  def self.analysis(text, regex)
    text.downcase.scan(regex).flatten.length
    print "^ ", text.downcase.scan(regex).flatten.length, " ^"
  end
  #constructing the object response
  def self.analysis_constructor(content, content_word_count)
  #finds the percentatge of words that relate to the regex/word list and returns a percentage of the unique words in the content it is analysising.
    analysis_constructed = {
      "selfs": (analysis(content, self.selfs_regex).to_f/content_word_count * 100).round(2),
      "our": (analysis(content, self.our_regex).to_f/content_word_count * 100).round(2),
      "you": (analysis(content, self.you_regex).to_f/content_word_count * 100).round(2)
    }
    analysis_constructed
  end

  #creating the regexes - will refactor into better ones once I learn regex better
  def self.selfs_regex
   /\b(?:#{MasterWordList.Pronouns.selfs.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
  def self.our_regex
   /\b(?:|#{MasterWordList.Pronouns.our.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
  def self.you_regex
    /\b(?:#{MasterWordList.Pronouns.you.join("|")})(y|ies|s|ing|ed|er|d)\b/
  end
end
