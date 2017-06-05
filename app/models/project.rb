class Project < ApplicationRecord
  belongs_to :user

  attr_accessor :basic_analysis, :text, :word_extraction, :sentiment_analysis, :readability_analysis, :content_analysis

  before_create do
    find_subject
    find_themes
  end

  after_find do
    basic_analysis
    # post_test
    # word_count
  end

  private
  #Pre-Hook Saves
  def find_subject
    self.subject = ["test"]
  end

  def find_themes
    self.theme = ["test1", "test2"]
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
      "keywords": keywords,
      "named_people": named_people,
      "inline_references": inline_references,
      "bib_references": bibliographical_references,
      "phone_nums": phone_nums,
      "emails": email,
      "url_links": url_links,
      "addresses": addresses
    }
  end

  #Text Analysis

  def cleaned
    # self.content.reject { |para| para.empty? }.length
  end

  def processed
    #Splitting on double lines/may have to change for single lines or standardise
    @processed = self.content.split(/\n\n/)
    @processed.reject { |para| para.empty? }
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

  def word_frequency
    frequencies = Hash.new(0)
    self.content.downcase.split(/\W+/).each { |word| frequencies[word] += 1 }
    frequencies = frequencies.sort_by {|a, b| b }
    frequencies.reverse!.flatten!
    frequencies = frequencies.join(" ").split(/[^\[a-z]+(?:\s+)/)
    frequencies[0..10]
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
  def keywords
  end
  def named_people
  end
  def inline_references
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


end
