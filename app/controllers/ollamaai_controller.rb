class OllamaaiController < ApplicationController
  before_action :create_client
  before_action :list_models

  def index
    @hash_id = SecureRandom.hex(10)
  end

  def submit_message
    message = { role: "user", content: permit_params[:prompt] }
    message[:images] = [ image_base64 ] if image_base64.present?

    messages = []
    messages = JSON.parse(chat.messages) if chat.messages.present?
    messages << JSON.parse(message.to_json)

    @result = @client.chat({
      model: model_name,
      messages: messages,
      stream: false
    })
    messages << @result[0]["message"] if @result.present?

    chat.messages = messages.to_json
    chat.save!

    render json: @result, status: 200
  rescue => e
    render json: { error: e.message }, status: 500
  end

  def generate
    @result = @client.generate(
    { model: "llama3.2-vision",
      prompt: "Hello from Ruby on Rails!" }
    )
    render template: "ollamaai/index"
  end

  def embeddings
    @result = @client.embeddings(
      { model: "llama3.2-vision",
        prompt: "Hello!" }
    )
    render template: "ollamaai/index"
  end

  private

  def chat_hash_id
    @chat_hash_id ||= permit_params[:hash_id]
  end

  def chat
    @chat ||= Chat.find_or_create_by(hash_id: chat_hash_id)
  end

  def model_name
    @model_options[permit_params[:model].to_i][0]
  end

  def image_base64
    image = permit_params[:image]
    @image_base64 ||= image.nil? ? "" : Base64.strict_encode64(image.read)
  end

  def create_client
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
  rescue => e
    Rails.logger.error e.message
    flash[:alert] = "Connection to Ollama failed."
  end

  def permit_params
    params.permit(:hash_id, :model, :prompt, :image)
  end
end
