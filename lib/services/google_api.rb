require "google/apis/customsearch_v1"

class GoogleApi
  def self.search_web(query)
    client = Google::Apis::CustomsearchV1::CustomSearchAPIService.new
    client.key = ENV["GOOGLE_CUSTOM_SEARCH_API_KEY"]
    response = client.list_cses(q: query, cx: ENV["GOOGLE_CUSTOM_SEARCH_ENGINE_ID"], num: 5)
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
