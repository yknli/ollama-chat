class OllamaClient
  # Ollama.new only sets up the configured options.
  # It connects to the Ollama server only when API methods are called. (ex: tags, chat, generate... etc.)
  # * Reference: https://github.com/gbaptista/ollama-ai/blob/main/controllers/client.rb
  def initialize
    @client = Ollama.new(
      credentials: { address: ENV["OLLAMA_HOST"] },
      options: {
        server_sent_events: true,
        connection: { request: { timeout: 120, read_timeout: 120 } }
      }
    )
  end

  def list_models
    tags = @client.tags
    models_hash = tags[0] if tags.present?
    models = models_hash.try(:[], "models") || []

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
