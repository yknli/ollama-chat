class OllamaClient
  def initialize
    @client = Ollama.new(
      credentials: { address: ENV["OLLAMA_HOST"] },
      options: {
        server_sent_events: true,
        connection: { request: { timeout: 120, read_timeout: 120 } }
      }
    )
  rescue => e
    Rails.logger.error e.message
  end

  def list_models
    @model_options = []

    tags = @client.tags
    models = tags[0]["models"] if tags.present?

    @model_options = models.each_with_index.map { |model, i| [ model["name"], i ] }
  end

  def chat(model_name, messages, stream: false)
    @client.chat({
      model: model_name,
      messages: messages,
      stream: stream
    })
  end
end
