require "google/apis/customsearch_v1"

class GoogleApi
  def self.search_web(query)
    custom_search_api_credentials = Rails.application.credentials.google.custom_search_api
    api_key = custom_search_api_credentials.api_key
    engine_id = custom_search_api_credentials.engine_id

    client = Google::Apis::CustomsearchV1::CustomSearchAPIService.new
    client.key = api_key
    response = client.list_cses(q: query, cx: engine_id, num: 5)
    results = []
    if response.items.present?
      response.items.each do |result|
        results << {
          title: result.title,
          description: result.html_snippet,
          link: CGI.unescape(result.link)
        }
      end
    end
    results
  end
end
