## TEXT MINING API


## Intent

To create an API that when sent a strng of text it will return an object which has all the analysis 

## Returned Object

```
{ text : { 
	original: "",
	cleaned: "",
	processed: [""]
	},
  word_extraction: {
  		keywords: ["",""],
  		references: ["",""],
  		names: ["",""]
  		extra: {
		bib_refs: [{
			author: "",
			year: "",
			title: "",
			publisher: ""}],
		phone_nums: [""],
		emails: [""],
		links: [""],
		addresses: [""]
		}
	},
  basic_analysis: {
  		num_words: integer,
  		num_paragraphs: integer,
  		average_word_length: integer,
  		average_para_length: integer,
  		word_frequency: {
  			all: ["",""], 
  			top_5: ["",""],
  			bottom_5: ["",""]},
  sentiment_analysis: {
  		tone: {
  			happy: integer,
  			sad: integer,
  			angry: integer,
  			calm: integer },
  		para_analysis: [ 1, -1],
  		overall_analysis: [[%, "positive/negative"]]},
  readability_analysis: {
  		flesch: integer,
  		gunning: integer,
  		complex_words: {
  			total: integer,
  			para_distribution: [integer, integer]},
  		coleman: integer},
  	content_analysis: {
  		subject_analysis: ["",""],
  		theme_analysis: ["",""],
  		summary_generator: ["",""]
  		}
  	}
```	


## User Input
The text is submitted through text area on a HTML form and sent to the API. (May have to limit the number of words sent).

### Proccessing 
##### Paragraphing (Front end)
Paragraphing is accomplished on the front end. Splitting the text on the line breaks and then sending the array of paragraphy strings back on the POST request. 

```
var enteredText = document.getElementById("textArea").value;
var numberOfParagraphs = (enteredText.match(/\n/g)||[]).length;
enteredText = enteredText.split("\n"); 
```

##### Wording
This is accomplished on the backend and will be done after the text has been cleaned if it is being cleaned but will be done immediately on retrevial if being left uncleaned. 

```
enteredText = enteredText.forEach(paragraph => {
	paragraph = paragraph.split(' ');
}
```

### Uncleaned
The uncleaned text, in its split paragraph form shall be processed by the word extraction in order to remove the important words and items.

### Cleaned
The cleaning process removes any unwanted text from the original, removing things that could throw the rest of the analysis.


##### Blank or Almost Blank Space Removal
Following running these function to clean the text, it shall then loop through the arrays to remove any that contain supufulous data. 

```
def removeBlankish (textArray) 
	textArray.reject { |para| para.empty? }.length
end
```

##### Word Splitting 
Completed on the backend in order to allow further analysis. Maybe want to include a sentence split version so that the readibility analysis can be done.

```
def para_to_words (textArray) 
	textArray.each do |para| 
	para.split!(" ") 
end
```

## Word Extraction

### Keywords
Rake Analysis is the best form. Installing a package from `https://github.com/nok/rake-text-ruby`

Further information about this implementation can be found here... 
`https://books.google.de/books?id=u-SrKyUrafsC&lpg=PP1&hl=de&pg=PA1#v=onepage&q&f=false`

### References
##### Inline References
Same as above. 

```
author = "(?:[A-Z][A-Za-z'`-]+)"
etal = "(?:et al.?)"
additional = "(?:,? (?:(?:and |& )?" + author + "|" + etal + "))"
year_num = "(?:19|20)[0-9][0-9]"
page_num = "(?:, p.? [0-9]+)?"  # Always optional
year = "(?:, *"+year_num+page_num+"| *\("+year_num+page_num+"\))"
regex = "(" + author + additional+"*" + year + ")"

full regex 
((?:[A-Z][A-Za-z'`-]+)(?:,? (?:(?:and |& )?(?:[A-Z][A-Za-z'`-]+)|(?:et al.?)))*)(?:, *(?:19|20)[0-9][0-9](?:, p.? [0-9]+)?| *\((?:19|20)[0-9][0-9](?:, p.? [0-9]+)?\))

full regex (includes brackets)
\(((?:[A-Z][A-Za-z'`-]+)(?:,? (?:(?:and |& )?(?:[A-Z][A-Za-z'`-]+)|(?:et al.?)))*)(?:, *(?:19|20)[0-9][0-9](?:, p.? [0-9]+)?| *\((?:19|20)[0-9][0-9](?:, p.? [0-9]+)?\))\)
matches = re.findall(regex, text)

```

##### References Bibliography

Same as above.

```
def extractRefs (text) 
	text.match(^(?<author>[A-Z](?:(?!$)[A-Za-z\s&.,'’])+)\((?<year>\d{4})\)\.?\s*(?<title>[^()]+?[?.!])\s*(?:(?:(?<jurnal>(?:(?!^[A-Z])[^.]+?)),\s*(?<issue>\d+)[^,.]*(?=,\s*\d+|.\s*Ret))|(?:In\s*(?<editors>[^()]+))\(Eds?\.\),\s*(?<book>[^().]+)|(?:[^():]+:[^().]+\.)|(?:Retrieved|Paper presented)))
end

```

The one that returns the data in almost an object
```
regex =  /^(?<author>[A-Z](?:(?!$)[A-Za-z\s&.,'’])+)\((?<year>\d{4})\)\.?\s*(?<title>[^()]+?[?.!])\s.*?(?=\s{2})/
```

Global matches, push the last match to an array. Solves the half return.

```
references.gsub(regex) { |m| array.push([$~]) }
```

##### Inline References
This was written in python to begin with, so may have to adapt quite a lot to get it working in ruby. 

It identifies in line citations. Combine this with anthor API to link the resource that it is indeitifying? 

```
author = "(?:[A-Z][A-Za-z'`-]+)"
etal = "(?:et al.?)"
additional = "(?:,? (?:(?:and |& )?" + author + "|" + etal + "))"
year_num = "(?:19|20)[0-9][0-9]"
page_num = "(?:, p.? [0-9]+)?"  # Always optional
year = "(?:, *"+year_num+page_num+"| *\("+year_num+page_num+"\))"
regex = "(" + author + additional+"*" + year + ")"

matches = re.findall(regex, text)

```

##### References Bibliography
Using the following regex to strip the text of its citations and send them back to the front end. These shall then be entered into the returned analysis object as references. 

```
def extractRefs (text) 
	text.match(^(?<author>[A-Z](?:(?!$)[A-Za-z\s&.,'’])+)\((?<year>\d{4})\)\.?\s*(?<title>[^()]+?[?.!])\s*(?:(?:(?<jurnal>(?:(?!^[A-Z])[^.]+?)),\s*(?<issue>\d+)[^,.]*(?=,\s*\d+|.\s*Ret))|(?:In\s*(?<editors>[^()]+))\(Eds?\.\),\s*(?<book>[^().]+)|(?:[^():]+:[^().]+\.)|(?:Retrieved|Paper presented)))
end

```

##### URLs + Images
This shall charcterise the URLS again returned in the analysis object.

```
def extractURLs (text) 
	text.match(/(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])/igm)
end

```

##### Emails

```
def extractEmails ( text )
    text.match(/([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)/gi);
end
```

##### Phone Numbers

```
def extractPhone (text) 
	text.match(/^[\.-)( ]*([0-9]{3})[\.-)( ]*([0-9]{3})[\.-)( ]*([0-9]{4})$/)
end
```
	
##### Addresses
This regex works for U.S. addresses so will require reworking for the UK.

```
def extractAddresses (text) 
	text.match(\d+.+(?=AL|AK|AS|AZ|AR|CA|CO|CT|DE|DC|FM|FL|GA|GU|HI|ID|IL|IN|IA|KS|KY|LA|ME|MH|MD|MA|MI|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|MP|OH|OK|OR|PW|PA|PR|RI|SC|SD|TN|TX|UT|VT|VI|VA|WA|WV|WI|WY)[A-Z]{2}[, ]+\d{5}(?:-\d{4})?)
end
```


### Named Entities (People)

Implemented a NER system that will identify names and then use googles.freeBase verifcation system to verify that thing it is sent is actually a name. 

`https://gist.github.com/shlomibabluki/6333170`

## Basic Analysis
These are the basic analysis functions they will run on the cleaned text. 

### Number of Words (total)
Run on the word split arrays.

```
def word_count (textArray)
    textArray.split(/\W+/).length
end
```
### Number of Sentences

```
def sent_count (textArray)
    textArray.split(/(?<!\be\.g|\bi\.e|\bvs|\bMr|\bMrs|\bDr)(?:\.|\?|\!)(?= |$)/).length
end
```

### Number of Paragraphs

```
def para_count (textArray) 
	paragraph_count = textArray.split(/\n\n/).length
end
```

### Avergage Words Length

```
def word_avg (textArray, word_count) 
	total_characters = 0
	textArray.flatten.split(" ")!
	textArray.each do |word| 
	total_character ++ word.length 
	end
	total_characters/word_count
end
```

### Average Paragraph Length 

Taking the words in the paragraph and determining their length.

```
def para_avg (textArray, word_count) 
	word_count/textArray.length
end
```

### Average Sentence Length
Taking the sentences and determining their average length.

```
def sent_avg (textArray, word_count) 
	textArray.flatten.split(".")!
	word_count/textArray
end
```
### Word Frequency 
Finding the most common words used in the text.


Perhaps putting the amount of frequent words used in the summary a % of the amount of words in the word count.

```
def word_frequency_array(textArray)
   frequencies = Hash.new(0)
   textArray.downcase.split(" ").each { |word| frequencies[word] += 1 }
   frequencies = frequencies.sort_by {|a, b| b }
   frequencies.reverse!.flatten!
   frequencies = frequencies.join(" ").split(/[^\[a-z]+(?:\s+)/)
   frequencies[0..10]
end
```
##### Top 5
Could be done on the front end. Otherwise could be limited through. 

```
def word_frequencies_top5 frequencies 
frequencies[0..4]
end
```

##### Bottom 5
Could be done on the front end. Otherwise could be limited through. 

```
def word_frequencies_top5 frequencies 
fl = frequencies.length 
frequencies[fl-5..fl]
end
```

## Sentiment Analysis
Probably going to run loops and iterate through the textArrays.

### Tone of Piece (happy/sad/angry/calm)
This needs to compile to this object.


```
tone: {
  		happy: integer,
  		sad: integer,
  		angry: integer,
  		calm: integer 
  		}
```
 
 Where the integers all are percentages adding up to 100.
 
##### Loop Function

This will take the whole flattened array and compare each word to  a series of word lists. 

Each word is a point in the categories. (They need to have the same number of words) Edit word lists. 200 words? 

Alternative Regex for word endings

`\bitem(er|ing|ed|s)?\b`

```
def tone_analysis textArray, word_list, tone
	tone = 0
	textArray.flatten! 
		word_list.each do |item|
			tone = tone + textArray.match(/\bitem([a-zA-Z])+/g).length
			#trying to match the word and its derivatives e.g. 
			#stop as the base word and stopping as another
		end
	end
end

```

##### Word Lists 
These will be stored in a seperate file. And limited to a certain number for tone. 

* Anger
* Sadness
* Happiness
* Neutral/Calm
* Positive
* Negative

### Paragraph Analysis (for/against)
This is similar to tonal analysis except that it will be used to determine the nature of the paragraph and whether it is for or against. _Maybe include a small over view (font-size 3px) of the entire document where the paragraphs are highlighted green or red. Vary the opacity of the color based on the strength of the for/against._

```
def paragraph_analysis textArray, word_list
	para_breakdown = []
		textArray.each_with_index do |para, index|
			para_length = para.split(" ").length
			positive = 0	
			negative = 0
			word_list.each_with_index do |item, index|
				positive = positive + para.match(/\bitem([a-zA-Z])+/g).length
				negative = negative + para.match(/\bitem([a-zA-Z])+/g).length
		end
		negative = (negative/para_length)*100
		positive = (positive/para_length)*100
		para_breakdown.push([textArray[index], positive, negative])
	end
	para_breakdown
end

```

### Overall Analysis (for/against)
Takes the individual analysis and determines a score for the whole document. 

```
def overall_analysis (para_breakdown)
	overall = 0
	para_breakdown.each do |para| 
		overall = overall + para[1]
		overall = overall - para[2]
	end
	overall
end

```
Returns an overall score. 
	
## Readability Analysis
Readability analysis is in two forms the Gunning For algorithm and the Coleman Index. 

Gunning requies complexity analysis to be completed first. 

### Gunning Analyis
The core algorithm is as follows: 

``` 
def readability_score (word_count, sent_count, complex_words)
	return 0.45 * ((word_count/sent_count) + (100 * (complex_words/word_count)))
end

readability_score(word_count(textArray), sent_count(textArray), complex_word_count(textArray))
```

##### Complex Word Analysis
Complex words have to be assesed using the following algorithm.

```
def complex_word_count (textArray)
  complex_words = 0
  textArray.split(/\W+/).each do |word|
    if (word.length >= 5)
      word_score = word.scan(/[aeiou]/).length - word.scan(/[aeiou]\b/).length - 			word.scan(/[aeiou]{2}/).length
    end
    if (word_score.to_i > 2)
      complex_words += 1
    end
  end
  puts complex_words
end
```

### Complex Word Analysis (total)

Same as above returning a value for the total number of complex words.

```
def complex_word_count (textArray) 
	complex_words = 0
	textArray.flatten.split(" ").each do |word| 
		if word.length >= 5
			word = word.scan(/[aeiou]/).length - word.scan([aeiou]\b).length - 			word.scan(([aeiou]{2})).length
		end
		if word >= 3 complex_words ++ 
	end
	complex_words
end
```


### Coleman Index Analysis 

```
def coleman_analysis (letters, sentences)
	((0.0588*letters) - (0.2965*sentences)) - 15.8
end
```

##### Average number of letters per 100 words

```
def letters(textArray, word_count)
   textArray.split(/\W+/).join("").length.to_f / word_count * 100
end
```

##### Average number of sentences per 100 words

```
def sentences(sent_count, word_count)
  (sent_count.to_f/ word_count.to_f) * 100
end
```

## Content Analysis

### Subject Analysis 
Two methods; first using a package or external API to determine the subject. Word list analysis if word lists can be found.


`https://developer.aylien.com/plans`

### Theme Analysis
Two methods; first exteranal api. Or using word lists to analyse their occurance. 

Reformat the word list to take the following structure. 

[[theme, word], [theme,word]]

```
// split all text
// compare all words in the list
// change scores
// return theme theory

def theme_analysis(textArray, wordlist)
	wordlist_arrays = []
	textArray.flatten!.split(" ")
		wordlists.each_by_index do |item, index|
		textArray.each do |word| 
			if	word == /\bitem[1](er|ing|ed|s)?\b/ wordlistt_arrays.push(item[0]) 
			end
		end
	wordlist_arrays.collapse into hash 
end
```

#### The Flesch Reading Ease Readability Formula 

The specific mathematical formula is: 

RE = Readability Ease
`RE = 206.835 – (1.015 x ASL) – (84.6 x ASW) `

```
def readability_ease (sent_count, word_count, syllables_count)
  avg_sent_length = word_count.to_f/sent_count
  avg_syll_word = syllables_count.to_f/word_count
  (206.835 - (1.015 * avg_sent_length) - (84.6 * avg_syll_word)).round(2)
end

readability_ease(sent_count(textArray), word_count(textArray), syllables_count(textArray))
```

ASL = Average Sentence Length (i.e., the number of words divided by the number of sentences)

ASW = Average number of syllables per word (i.e., the number of syllables divided by the number of words) 

```
def syllables_count (textArray)
  syllables = 0
  textArray.split(/\W+/).each do |word|
    #scan for vowels, scan for silent vowels (end of word), scan for dipthongs
      word_score = word.scan(/[aeiou]/).length - word.scan(/[aeiou]\b/).length - 			word.scan(/[aeiou]{2}/).length
      syllables += word_score
    end
  syllables
end
```


The output, i.e., RE is a number ranging from 0 to 100. The higher the number, the easier the text is to read. 

• Scores between 90.0 and 100.0 are considered easily understandable by an average 5th grader.

• Scores between 60.0 and 70.0 are considered easily understood by 8th and 9th graders.

• Scores between 0.0 and 30.0 are considered easily understood by college graduates. 


### Summary Generator 
#### Ruby 
Automatic summarization of text works by first calculating the word frequencies for the entire text document. Then, the 100 most common words are stored and sorted. Each sentence is then scored based on how many high frequency words it contains, with higher frequency words being worth more. Finally, the top X sentences are then taken, and sorted based on their position in the original text.

```
textArray = "This is a series of sentences. The first is a question? The second is an exclamation! And the third contains \- weird \: attempts to fool it."

def word_frequency_array(textArray)
  frequencies = Hash.new(0)
  textArray.downcase.split(" ").each { |word| frequencies[word] += 1 }
  frequencies = frequencies.sort_by {|a, b| b }
  frequencies.reverse!.flatten!
  frequencies = frequencies.join(" ").split(/[^\[a-z]+(?:\s+)/)
  frequencies[0..10]
end

frequency_regex = /#{word_frequency_array(textArray).join("|")}/

def sentence_rank(frequency_regex, textArray)
  #Splits the full text into sentences (ignoring common fullstops)
	sentences = textArray.split(/(?<!\be\.g|\bi\.e|\bvs|\bMr|\bMrs|\bDr)(?:\.|\?|\!)(?= |$)/)
  # An array to hold the ranking
	sentences_frequency = []
	sentences.each_with_index do |sentence, index|
		score = sentence.scan(frequency_regex).length
		sentences_frequency.push(Hash[sentence, [score, index+1]])
	end
	sentence_rank_sort(sentences_frequency)
end

def sentence_rank_sort(sentence_rank)
  sentences_ranked = sentence_rank.sort_by {|x| x.values[0] }
  summary_reorder(sentences_ranked.reverse!)
end

def summary_reorder(sentences_ranked, summary_size=3)
  sentences_ordered = sentences_ranked[0..summary_size]
  sentences_ordered = sentences_ordered.sort_by {|x| x.values[1] }
  summary_assemble(sentences_ordered.reverse!)
end

def summary_assemble(sentences)
  summary = []
  sentences.each { |sentence| summary.push(sentence.keys) }
  print summary.flatten.join(".") + "."
end

sentence_rank(frequency_regex, textArray)
```		

#### Python Implementation
##### Sentence Rank
##### Sentence Comparison 
##### Page Rank Implementation
##### Output

