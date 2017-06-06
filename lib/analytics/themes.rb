require_relative "../master_word_list"
module ThemeAnalysis

  def self.analysis(text, regex)
    text.downcase.scan(regex).flatten.length
  end

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

  def self.theme_sorting(analysed)
    analysed = analysed.sort_by {|a, b| b }
    sorted_themes = []
    analysed.reverse!.each do |theme|
      sorted_themes.push(theme) if (theme[1].to_i > 3)
    end
    Hash[sorted_themes[0..2].map {|x| [x[0], x[1]]}]
  end

  def self.building_regex
    /\b(#{MasterWordList.Themes.buildings.join("|")})(?:y|ies|s|ing|ed|er)\b/
  end

  def self.economics_regex
    /\b(#{MasterWordList.Themes.economics.join("|")})(?:y|ies|s|ing|ed|er)\b/
  end
  def self.law_regex
    /\b(#{MasterWordList.Themes.law.join("|")})(?:y|ies|s|ing|ed|er)\b/
  end
  def self.human_regex
    /\b(#{MasterWordList.Themes.human.join("|")})(?:y|ies|s|ing|ed|er)\b/
  end
  def self.media_regex
    /\b(#{MasterWordList.Themes.media.join("|")})(?:y|ies|s|ing|ed|er)\b/
  end
  def self.politics_regex
    /\b(#{MasterWordList.Themes.politics.join("|")})(?:y|ies|s|ing|ed|er)\b/
  end
  def self.religious_regex
    /\b(#{MasterWordList.Themes.religious.join("|")})(?:y|ies|s|ing|ed|er)\b/
  end
  def self.social_regex
    /\b(#{MasterWordList.Themes.social.join("|")})(?:y|ies|s|ing|ed|er)\b/
  end
  def self.ethics_regex
    /\b(#{MasterWordList.Ethics.join("|")})(?:y|ies|s|ing|ed|er)\b/
  end
end


print ThemeAnalysis.theme_analysed("This essay will consider whether or not Machiavelli was a teacher of evil, with specific reference to his text The Prince. (Frank et al, 2014) It shall first be shown what it was that Machiavelli taught and how this can only be justified by consequentialism. It shall then be discussed whether consequentialism is a viable ethical theory, in order that it can justify Machiavelli\'s teaching. Arguing that this is not the case, it will be concluded that Machiavelli is a teacher of evil.\n\n To begin, it shall be shown what Machiavelli taught or suggested be adopted in order for a ruler to maintain power. To understand this, it is necessary to understand the political landscape of the period.\n\n The Prince was published posthumously in 1532, and was intended as a guidebook to rulers of principalities. (Nedermane, et al, 2014) Machiavelli was born in Italy and, during that period, there were many wars between the various states which constituted Italy. (Testing, Testing, 4002)These states were either republics (governed by an elected body) or principalities (governed by a monarch or single ruler). The Prince was written and dedicated to Lorenzo de Medici who was in charge of Florence which, though a republic, was autocratic, like a principality. Machiavelli\'s work aimed to give Lorenzo de Medici advice to rule as an autocratic prince. (Nederman, 2014)\n\n This essay will consider whether or not Machiavelli was a teacher of evil, with specific reference to his text The Prince. It shall first be shown what it was that Machiavelli taught and how this can only be justified by consequentialism. It shall then be discussed whether consequentialism is a viable ethical theory, in order that it can justify Machiavelli\'s teaching. (Nedermane, 2014) Arguing that this is not the case, it will be concluded that Machiavelli is a teacher of evil.\n\n To begin, it shall be shown what Machiavelli taught or suggested be adopted in order for a ruler to maintain power. (John, 2004) To understand this, it is necessary to understand the political landscape of the period.\n\n The Prince was published posthumously in 1532, and was intended as a guidebook to rulers of principalities. Machiavelli was born in Italy and, during that period, there were many wars between the various states which constituted Italy. These states were either republics (governed by an elected body) or principalities (governed by a monarch or single ruler). The Prince was written and dedicated to Lorenzo de Medici who was in charge of Florence which, though a republic, was autocratic, like a principality. Machiavelli\'s work aimed to give Lorenzo de Medici advice to rule as an autocratic prince. (Nederman, 2014)")


# print text.downcase.scan(ThemeAnalysis.economics_regex).flatten
