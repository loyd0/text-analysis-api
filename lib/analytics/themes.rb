require_relative "../master_word_list"
module ThemeAnalysis


#the actual analysis function
  def self.analysis(text, regex)
    text.downcase.scan(regex).flatten.length
  end
#constructing the object response
  def self.theme_analysed(content)
    theme_analysed = {
      "architecture": analysis(content, self.building_regex),
      "economics": analysis(content, self.economics_regex),
      "law": analysis(content, self.law_regex),
      "socialOrhumanity": analysis(content, self.human_regex),
      "mediaOrcommunication": analysis(content, self.media_regex),
      "political": analysis(content, self.politics_regex),
      "religious": analysis(content, self.religious_regex),
      "social": analysis(content, self.social_regex),
      "ethics": analysis(content, self.ethics_regex)
    }
    theme_sorting(theme_analysed)
  end
#sorting the object response and organising it
  def self.theme_sorting(analysed)
    analysed = analysed.sort_by {|a, b| b }
    sorted_themes = []
    analysed.reverse!.each do |theme|
      sorted_themes.push(theme) if (theme[1].to_i > 3)
    end
    Hash[sorted_themes[0..2].map {|x| [x[0], x[1]]}]
  end

  #creating the regexes
  def self.building_regex
    /\b(#{MasterWordList.Themes.buildings.join("|")})(?:y|ies|s|ing|ed|er|d)\b/
  end

  def self.economics_regex
    /\b(#{MasterWordList.Themes.economics.join("|")})(?:y|ies|s|ing|ed|er|d)\b/
  end
  def self.law_regex
    /\b(#{MasterWordList.Themes.law.join("|")})(?:y|ies|s|ing|ed|er|d)\b/
  end
  def self.human_regex
    /\b(#{MasterWordList.Themes.human.join("|")})(?:y|ies|s|ing|ed|er|d)\b/
  end
  def self.media_regex
    /\b(#{MasterWordList.Themes.media.join("|")})(?:y|ies|s|ing|ed|er|d)\b/
  end
  def self.politics_regex
    /\b(#{MasterWordList.Themes.politics.join("|")})(?:y|ies|s|ing|ed|er|d)\b/
  end
  def self.religious_regex
    /\b(#{MasterWordList.Themes.religious.join("|")})(?:y|ies|s|ing|ed|er|d)\b/
  end
  def self.social_regex
    /\b(#{MasterWordList.Themes.social.join("|")})(?:y|ies|s|ing|ed|er|d)\b/
  end
  def self.ethics_regex
    /\b(#{MasterWordList.Ethics.join("|")})(?:y|ies|s|ing|ed|er|d)\b/
  end
end
