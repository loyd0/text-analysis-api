class Project < ApplicationRecord
  belongs_to :user

  attr_accessor :basic_analysis, :text, :word_extraction, :readability_analysis, :generate_summary, :full_content_analysis, :para_content_analysis

  before_create do
    create_regexs
    cleaned
    create_freq_regexs
    fill_feilds
  end

  after_find do
    create_regexs
    cleaned
    create_freq_regexs
    basic_analysis
  end

  private

  # Regex's

  def create_regexs
    # @bibliographical_regex = /^(?<author>[A-Z](?:(?!$)[A-Za-z\s&.,'’])+)\((?<year>\d{4})\)\.?\s*(?<title>[^()]+?[?.!])+\s*/
    @bibliographical_regex = /^(?<author>[A-Z](?:(?!$)[A-Za-z\s&.,'’])+)\((?<year>\d{4})\)\.?\s*(?<title>[^()]+?[?.!]+)+\s.*/

    @inline_references_regex = Regexp.new("\(((?:[A-Z][A-Za-z'`-]+)(?:,? (?:(?:and |& )?(?:[A-Z][A-Za-z'`-]+)|(?:et al.?)))*)(?:, *(?:19|20)[0-9][0-9](?:, p.? [0-9]+)?| *\((?:19|20)[0-9][0-9](?:, p.? [0-9]+)?\))\)")
    #Need to change so that it is representative of the amount of unique words that are entered.
    @phone_nums_regex =  /\b\d{3}[-.]?\d{3}[-.]?\d{4}\b/
  end

  # Have to create the frequency regex after the text has been cleaned and the other regexs have been created
  def create_freq_regexs
    @frequency_regex = /#{word_frequency[0..10].join("|")}/
  end

  #Pre-Hook Saves
  def fill_feilds
    summary_full
    self.subject = [find_subject]
    self.theme = [find_themes]
    self.keywords = find_keywords
    self.summary = summary_5
    self.entity = entity_extraction
  end

  def find_subject
    require_relative "../../lib/subject_classifier.rb"
    SubjectClassifier.get_subject(@cleaned.flatten.to_s).capitalize
  end

  def find_themes
    require_relative "../../lib/analytics/themes.rb"
    ThemeAnalysis.theme_analysed(@cleaned.flatten.to_s)
  end

  def find_keywords
    require 'rake_text'
    @rake = RakeText.new
    keywords = @rake.analyse @cleaned.flatten.to_s, RakeText.SMART
    #sort the
    keywords = keywords.sort_by {|a, b| b }
    # Eliminate low ranking keywords
    keywords = keywords.reject {|a, b| b <= 1.4 }
    # Reject phrases with over 4 words
    keywords = keywords.reject {|a, b| a.split(/\W+/).length > 4 }
    @keywords = keywords.reverse!
  end


  #Post Find Manipulations
  #Aggregators
  def text
    self.text = {
      "processed": processed,
      "cleaned": cleaned
    }
  end

  def basic_analysis
    self.basic_analysis = {
      "num_words": num_words,
      "num_sentences": num_sentences,
      "num_paragraphs": num_paragraphs,
      "avg_word_len": avg_word_len,
      "avg_sent_len": avg_sent_len,
      "avg_para_len": avg_para_len,
      "avg_syllables_word": avg_syllables_word,
      "num_unique_words": num_unique_words,
      "word_frequency": word_frequency,
    }
  end

  def readability_analysis
    self.readability_analysis = {
      "complex_words": {
        "total": complex_words_total,
        "distribution": complex_words_distribution
      },
      "flesch_score": flesch_score,
      "gunning_score": gunning_score,
      "coleman_score": coleman_score
    }
  end

  def word_extraction
    self.word_extraction = {
      # "entity_extraction": entity_extraction,
      "entity_extraction": ["see entity"],
      "inline_references": inline_references,
      # "bib_references": bibliographical_references(extreme_processed)
      "bib_references":  remove_dupliates(bibliographical_references(extreme_processed), bib_extraction_post_bibliography(@processed))
    }
  end

  def generate_summary
    self.generate_summary = {
      "summary_full": summary_full,
      "summary_5": summary_5
    }
  end

  def para_content_analysis
    require_relative "../../lib/analytics/analytics"
    require_relative "../../lib/analytics/voice"
    self.para_content_analysis = {
      "analytics": AnalyticalAnalysis.analysis_constructor(@cleaned, num_unique_words),
      "voice": VoiceAnalysis.analysis_constructor(@cleaned, num_unique_words)
    }
  end

  def full_content_analysis
    require_relative "../../lib/analytics/condemnation_praise"
    require_relative "../../lib/analytics/person_context"
    require_relative "../../lib/analytics/for_against"
    self.full_content_analysis = {
      "condemnation_vs_praise": CondemnationAndPraiseAnalysis.analysis_constructor(@cleaned.flatten.to_s, num_unique_words),
      "person_voice_context": PersonContext.analysis_constructor(@cleaned.flatten.to_s, num_unique_words),
      "for_against": ForOrAgainst.analysis_constructor(@cleaned.flatten.to_s, num_unique_words)
    }
  end

  #Text Analysis
  def cleaned
    full_text = []
    cleaning = self.content.split(/\n\n/)
    cleaning.reject { |para| para.empty? }
    cleaning.each do |para|
      para.split(/\n/).each do |sent|
        paragraph = []
        # Removing section titles
        if sent.downcase.match(/bibliography|references|reference|bib|resources/)
          break
        elsif sent.split(/\W/).length < 5 && para.index(sent) == 0
          next
        elsif sent.match(@bibliographical_regex)
          next
        else paragraph.push(sent)
        end
        full_text.push(paragraph.flatten)
      end
    end
    @cleaned =  full_text.flatten
  end

  def processed
    #Splitting on double lines/may have to change for single lines or standardise
    processed = self.content.split(/\n\n/)
    @processed = processed.reject { |para| para.empty? }
  end
  def extreme_processed
    #Splitting on double lines/may have to change for single lines or standardise
    self.content.split(/\n/)
  end

  #Basic Analysis
  def num_words
    @num_words = @cleaned.flatten.to_s.split(/\W+/).length
  end

  def num_sentences
    @num_sentences = @cleaned.flatten.to_s.split(/(?<!\be\.g|\bi\.e|\bvs|\bMr|\bMrs|\bDr)(?:\.|\?|\!)(?= |$)/).length
  end

  def num_paragraphs
    @num_paragraphs = @cleaned.length
  end

  def avg_word_len
    total_characters = 0
    text = @cleaned.flatten.to_s.split(/\W+/)
    text.each do |word|
      total_characters += word.length
    end
    @avg_word_len = total_characters/text.length
  end

  def avg_sent_len
    @num_words/@num_sentences
  end

  def avg_para_len
    @num_words/@num_paragraphs
  end

  def avg_syllables_word
    syllables = 0
    @cleaned.flatten.to_s.split(/\W+/).each do |word|
      #scan for vowels, scan for silent vowels (end of word), scan for dipthongs
      word_score = word.scan(/[aeiou]/).length - word.scan(/[aeiou]\b/).length -            word.scan(/[aeiou]{2}/).length
      syllables += word_score
    end
    @avg_syllables_word = syllables.to_f/@num_words
    @avg_syllables_word.round(2)
  end

  def num_unique_words
    #needs to be on clean text
    @num_unique_words = @cleaned.flatten.to_s.split(/\W+/).uniq.length
  end

  def word_frequency
    frequencies = Hash.new(0)
    @cleaned.flatten.to_s.downcase.split(/\W+/).each { |word| frequencies[word] += 1 }
    frequencies = frequencies.sort_by {|a, b| b }
    # frequencies.reverse!.flatten!
    frequencies.reverse!
    # frequencies = frequencies.join(" ").split(/[^\[a-z]+(?:\s+)/)
    # @word_frequencies = frequencies
    # @word_frequencies[0..10]
  end

  #readability_analysis
  def complex_words_total
    complex_words = 0
    @cleaned.flatten.to_s.split(/\W+/).each do |word|
      if (word.length >= 5)
        word_score = word.scan(/[aeiou]/).length - word.scan(/[aeiou]\b/).length -            word.scan(/[aeiou]{2}/).length
      end
      complex_words += 1  if (word_score.to_i > 2)
    end
    @complex_words_total = complex_words
  end

  def complex_words_distribution
    complex_words_distribution = []
    @cleaned.each_with_index do |para, index|
      para_complex_words = 0
      para.split(/\W+/).each do |word|
        if (word.length >= 5)
          word_score = word.scan(/[aeiou]/).length - word.scan(/[aeiou]\b/).length -            word.scan(/[aeiou]{2}/).length
        end
        para_complex_words += 1  if (word_score.to_i > 2)
      end
      complex_words_distribution.push([index+1, para_complex_words ])
    end
    @complex_words_distribution = complex_words_distribution
  end

  def flesch_score
    @flesch_score = (206.835 - (1.015 * @avg_sent_length.to_f) - (84.6*@avg_syllables_word.to_f)).round(2)
  end

  def gunning_score
    @gunning_score = (0.45 * ((@num_words/@num_sentences) + (100 * (@complex_words_total/@num_words)))).round(2)
  end

  def coleman_score
    def avg_letters_100_words
      self.content.split(/\W+/).join("").length.to_f / @num_words * 100
    end

    def avg_sent_100_words
      (@num_sentences.to_f/ @num_words.to_f) * 100
    end
    @coleman_score = ((0.0588*avg_letters_100_words) - (0.2965*avg_sent_100_words)) - 15.8
    @coleman_score.round(2)
  end


  #word_extraction
  def entity_extraction
    require_relative "../../lib/named_entity.rb"
    NamedEntity.get_entities(@cleaned.flatten.to_s)
  end

  def inline_references
    inline_references = []
    @cleaned.flatten.to_s.scan(@inline_references_regex).each do |ref|
      #removes the supurpulous information
      inline_references.push(ref[0])
    end
    @inline_references = inline_references
  end

  def bibliographical_references(text)
    matchdata = []
    full_match = []
    text.each { |para|
      matchdata.push(para.match(@bibliographical_regex))
    }
    bibref = matchdata.reject  { |sent| sent.class != MatchData }
    full_match = []
    bibref.each { |ref| full_match.push("#{ref}")}
    full_match
  end

  def bib_extraction_post_bibliography(text)
    array = []
    text.each_with_index do |para|
      para.split(/\n/).each_with_index do |sent, index|
        # print sent, "|**|"
        if  sent.downcase.match(/bibliography|references|reference|bib|resources/)
          array.push(para.split(/\n/)[index..para.length-1])
          # text2 = "para[index+1..para.length-1]"
          # puts sent
          # next
        end
      end
    end
    if array.length == 0
      return array
    elsif array.length > 0
      array.flatten!
      # print array.shift
      return array
    end
  end
  def remove_dupliates(array1, array2)
    array3 = []
    # print array1, "&&&&&&&&&&&&&&&", array2
    array1.each do |ref|
      if !array2.index(ref)
        ref_length = 0
        ref.split(". ").each do |sent|
          ref_length += sent.split(/\W/).length
        end
        if ref_length.to_f/(ref.split(". ").length) < 12
          puts ref_length/(ref.split(". ").length)
          array3.push(ref)
        end
      end
    end
    array2.each do |ref|
      ref_length = 0
      ref.split(". ").each do |sent|
        ref_length += sent.split(/\W/).length
      end
      if ref_length.to_f/(ref.split(". ").length) < 12
        puts ref_length/(ref.split(". ").length)
        array3.push(ref)
      end
    end
    array3.shift
    array3
  end

  def summary_full
    def sentence_rank()
      #Splits the full text into sentences (ignoring common fullstops)
      #Needs to be done on CLEANED TEXT
      sentences = @cleaned.flatten.to_s.split(/(?<!\be\.g|\bi\.e|\bvs|\bMr|\bMrs|\bDr)(?:\.|\?|\!)(?= |$)/)
      # An array to hold the ranking
      sentences_frequency = []
      sentences.each_with_index do |sentence, index|
        score = sentence.scan(@frequency_regex).length
        sentences_frequency.push(Hash[sentence, [score, index+1]])
      end
      sentence_rank_sort(sentences_frequency)
    end

    def sentence_rank_sort(sentence_rank)
      sentences_ranked = sentence_rank.sort_by {|sent| sent.values[0] }
      summary_reorder(sentences_ranked.reverse!)
    end

    def summary_reorder(sentences_ranked)
      sentences_ordered = sentences_ranked.sort_by {|sent| sent.values[1] }
      summary_assemble(sentences_ordered.reverse!)
    end

    def summary_assemble(sentences)
      summary = []
      sentences.each { |sentence| summary.push(sentence.keys) }
      @summary_array = summary
      summary.flatten.join(".") + "."
    end
    @summary_full = sentence_rank
  end

  def summary_5
    @summary_array[0..5].flatten.join(".") + "."
  end

  # Content Analysis

end
