class SubjectClassifier



  def self.get_subject(text)
    require 'aylien_text_api'
    textapi = AylienTextApi::Client.new(app_id: "c8d4beea", app_key: "c6869d082d789dcd711e746afa1040a3")
    response = textapi.classify_by_taxonomy text: text, taxonomy: "iptc-subjectcode"
    response[:categories].map {|c| c[:label]}.join(', ')
  end
end
