class NamedEntity

  def self.get_entities(text)
    require 'aylien_text_api'
    textapi = AylienTextApi::Client.new(app_id: "c8d4beea", app_key: "c6869d082d789dcd711e746afa1040a3")
    extracted_entities = []
    response = textapi.entities text: text
    response[:entities].each do |type, values|
      extracted_entities.push("#{type}" => values) if  "#{type}" != "keyword"
    end
    extracted_entities
  end
end
