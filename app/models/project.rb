class Project < ApplicationRecord
  belongs_to :user

  attr_accessor :basic_analysis, :text, :word_extraction, :sentiment_analysis, :readability_analysis, :generate_summary, :full_content_analysis, :para_content_analysis

  before_create do
    create_regexs
    fill_feilds
  end

  after_find do
    create_regexs
    basic_analysis
    # post_test
    # word_count
  end

  private

  # Regex's

  def create_regexs
    @inline_references_regex = Regexp.new("\(((?:[A-Z][A-Za-z'`-]+)(?:,? (?:(?:and |& )?(?:[A-Z][A-Za-z'`-]+)|(?:et al.?)))*)(?:, *(?:19|20)[0-9][0-9](?:, p.? [0-9]+)?| *\((?:19|20)[0-9][0-9](?:, p.? [0-9]+)?\))\)")
    #Need to change so that it is representative of the amount of unique words that are entered.
    @frequency_regex = /#{word_frequency[0..10].join("|")}/
  end

  #Pre-Hook Saves
  def fill_feilds
    summary_full
    self.subject = find_subject
    self.theme = [find_themes]
    self.keywords = find_keywords
    self.summary = summary_5
  end

  def find_subject
    ["test"]
  end

  def find_themes
    require_relative "../../lib/analytics/themes.rb"
    ThemeAnalysis.theme_analysed(self.content)
  end

  def find_keywords
    require 'rake_text'
    @rake = RakeText.new
    keywords = @rake.analyse self.content, RakeText.SMART
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
  def  text
    self.text = {
      "cleaned": cleaned,
      "processed": processed
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
      "named_people": named_people,
      "inline_references": inline_references,
      "bib_references": bibliographical_references,
      "phone_nums": phone_nums,
      "emails": email,
      "url_links": url_links,
      "addresses": addresses
    }
  end

  def generate_summary
    self.generate_summary = {
      "summary_full": summary_full,
      "summary_5": summary_5
    }
  end

  def para_content_analysis
    require_relative "../../lib/analytics/for_against"
    self.para_content_analysis = {
      "for_against": ForOrAgainst.analysis_constructor(@processed, num_unique_words)
    }
  end

  def full_content_analysis
    require_relative "../../lib/analytics/condemnation_praise"
    require_relative "../../lib/analytics/person_context"
    self.full_content_analysis = {
      "condemnation_vs_Praise": CondemnationAndPraiseAnalysis.analysis_constructor(self.content, num_unique_words),
      "person_voice_context": PersonContext.analysis_constructor(self.content, num_unique_words),
      "for_against": para_content_aggregator(para_content_analysis[:for_against])
    }
  end

  #Text Analysis
  def cleaned
    # Add cleaning filters
    @cleaned = self.content
    "Need to add cleaning procedures"
  end

  def processed
    #Splitting on double lines/may have to change for single lines or standardise
    processed = self.content.split(/\n\n/)
    @processed = processed.reject { |para| para.empty? }
  end

  #Basic Analysis
  def num_words
    @num_words = self.content.split(/\W+/).length
  end

  def num_sentences
    @num_sentences = self.content.split(/(?<!\be\.g|\bi\.e|\bvs|\bMr|\bMrs|\bDr)(?:\.|\?|\!)(?= |$)/).length
  end

  def num_paragraphs
    @num_paragraphs = self.content.split(/\n\n/).length
  end

  def avg_word_len
    total_characters = 0
    text = self.content.split(/\W+/)
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
    self.content.split(/\W+/).each do |word|
      #scan for vowels, scan for silent vowels (end of word), scan for dipthongs
      word_score = word.scan(/[aeiou]/).length - word.scan(/[aeiou]\b/).length -            word.scan(/[aeiou]{2}/).length
      syllables += word_score
    end
    @avg_syllables_word = syllables.to_f/@num_words
    @avg_syllables_word.round(2)
  end

  def num_unique_words
    #needs to be on clean text
    @num_unique_words = self.content.split(/\W+/).uniq.length
  end

  def word_frequency
    frequencies = Hash.new(0)
    self.content.downcase.split(/\W+/).each { |word| frequencies[word] += 1 }
    frequencies = frequencies.sort_by {|a, b| b }
    frequencies.reverse!.flatten!
    frequencies = frequencies.join(" ").split(/[^\[a-z]+(?:\s+)/)
    @word_frequencies = frequencies
    @word_frequencies[0..10]
  end

  #readability_analysis
  def complex_words_total
    complex_words = 0
    self.content.split(/\W+/).each do |word|
      if (word.length >= 5)
        word_score = word.scan(/[aeiou]/).length - word.scan(/[aeiou]\b/).length -            word.scan(/[aeiou]{2}/).length
      end
      complex_words += 1  if (word_score.to_i > 2)
    end
    @complex_words_total = complex_words
  end

  def complex_words_distribution
    complex_words_distribution = []
    @processed.each_with_index do |para, index|
      para_complex_words = 0
      para.split(/\W+/).each do |word|
        if (word.length >= 5)
          word_score = word.scan(/[aeiou]/).length - word.scan(/[aeiou]\b/).length -            word.scan(/[aeiou]{2}/).length
        end
        para_complex_words += 1  if (word_score.to_i > 2)
      end
      complex_words_distribution.push({ index+1 => para_complex_words })
    end
    @complex_words_distribution = complex_words_distribution
  end

  def flesch_score
    @flesch_score = (206.835 - (1.015 * @avg_sent_length.to_f) - (84.6*@avg_syllables_word.to_f)).round(2)
  end

  def gunning_score
    @gunning_score = 0.45 * ((@num_words/@num_sentences) + (100 * (@complex_words_total/@num_words)))
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
  def named_people
  end

  def inline_references
    inline_references = []
    self.content.scan(@inline_references_regex).each do |ref|
      #removes the supurpulous information
      inline_references.push(ref[0])
    end
    @inline_references = inline_references
  end

  def bibliographical_references
  end
  def phone_nums
  end
  def email
  end
  def url_links
  end
  def addresses
  end

  def summary_full
    # frequency_regex = /#{@word_frequencies[0..10].join("|")}/

    def sentence_rank()
      #Splits the full text into sentences (ignoring common fullstops)
      #Needs to be done on CLEANED TEXT
      sentences = self.content.split(/(?<!\be\.g|\bi\.e|\bvs|\bMr|\bMrs|\bDr)(?:\.|\?|\!)(?= |$)/)
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
  def para_content_aggregator(paragraph_object)
    total_for = 0
    total_against = 0
    paragraph_object[:for].each do |score|
      score.each {|key, value| total_for += value }
    end
    paragraph_object[:against].each do |score|
      score.each {|key, value| total_against += value }
    end

    total = {"total_for": total_for, "total_against": total_against}
    total
  end

end
