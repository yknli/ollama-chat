class OllamaaiController < ApplicationController
  before_action :create_client
  before_action :list_models

  def list_models
    tags = @client.tags
    models = tags[0]["models"] if tags.present?

    @model_options = models.each_with_index.map { |model, i| [ model["name"], i ] }
  end

  def index
  end

  def submit_message
    model_index = permit_params[:model].to_i
    model_name = @model_options[model_index][0]

    puts "prompt: #{permit_params[:prompt]}"
    @result = @client.chat(
      { model: model_name,
        messages: [
          { role: "user", content: permit_params[:prompt] }
        ],
        stream: false
      }
    )

    render json: @result, status: 200
  end

  def generate
    @result = @client.generate(
    { model: "llama3.2-vision",
      prompt: "Hello from Ruby on Rails!" }
    )
    render template: "ollamaai/index"
  end

  def chat
    @result = @client.chat(
      { model: "llama3.2-vision",
        messages: [
          { role: "user", content: "Hi! My name is Ruby on Rails Developer" }
        ] }
    ) do |event, raw|
        # This outputs to stdout but @result also get's the response events
        puts event
      end
    render template: "ollamaai/index"
  end

  def embeddings
    @result = @client.embeddings(
      { model: "llama3.2-vision",
        prompt: "Hello!" }
    )
    render template: "ollamaai/index"
  end

  def image
    @result = @client.generate(
      {
        model: "mario",
        prompt: "According to the words in the black block at the top of the image, please recommand me some of the best items to buy in this coffee shop.",
        images: [ Base64.strict_encode64(File.read("public/AF1QipNLCCj8_m5QtG9mL4WSQ8GMA9yDCTYkwu8ZlBlg=s508-k-no.jpg")) ],
        stream: false
      }
    )
    render template: "ollamaai/index"
  end

  private

  def create_client
    @client = Ollama.new(
      credentials: { address: "http://localhost:11434" },
      options: {
        server_sent_events: true,
        connection: { request: { timeout: 120, read_timeout: 120 } }
      }
    )
  end

  def permit_params
    params.permit(:authenticity_token, :model, :prompt, :format)
  end
end
