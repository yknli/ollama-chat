class ChatsController < ApplicationController
  before_action :create_client
  before_action :list_models

  def index
    @hash_id = SecureRandom.hex(10)
    # preload model
    # Reference: https://github.com/ollama/ollama/blob/main/docs/faq.md#how-can-i-preload-a-model-into-ollama-to-get-faster-response-times
    @client.chat({ model: model_name })
  end

  def submit_message
    user_message = permit_params[:prompt]

    system_message = "你是一位 AI 助理。除了回答你原本就知道答案的問題，也會根據用戶提供的網路資料歸納出問題答案。"
    if chat.all_messages.blank?
      chat.add_system_message(system_message)
    end

    data_sources = []
    # Search on google first to get related informations
    if user_message.starts_with?(cmds[:web_search])
      query = user_message.gsub("#{cmds[:web_search]} ", "")
      results = GoogleApi.search_web(query)
      if results.present?
        prepend_user_message = "以下為網路上所查到的資訊: \n"
        results.each_with_index do |result, index|
          prepend_user_message += "第 #{index + 1} 則資訊: \n"
          prepend_user_message += "標題: #{result[:title]}\n"
          prepend_user_message += "描述: #{result[:description]}\n"
          prepend_user_message += "資料來源: #{result[:link]}\n\n"

          data_sources << result[:link] if index < 3
        end
        prepend_user_message += "請根據上述的資訊回答問題。並且在回應的開頭以「根據網路上的資訊」作為開頭。"
        chat.add_user_message(prepend_user_message)
      end
    end

    images = [ image_base64 ] if image_base64.present?
    chat.add_user_message(user_message, images)

    @result = @client.chat({
      model: model_name,
      messages: chat.all_messages,
      stream: false
      # format: "json" # make assistant respond in json format
    })
    chat.add_assistant_message(@result[0]["message"]) if @result.present?
    chat.save!

    result_content = ""
    if @result.present?
      result_message = @result[0]["message"]
      result_content = result_message["content"] if result_message.present?
    end

    response_data = { content: result_content }
    response_data[:data_sources] = data_sources if data_sources.length > 0
    render json: response_data, status: 200
  rescue => e
    render json: { error: e.message }, status: 500
  end

  private

  def cmds
    {
      web_search: "/web"
    }
  end

  def chat_hash_id
    @chat_hash_id ||= permit_params[:hash_id]
  end

  def chat
    # Chat instance should be created only when the chat actually started (at least a message been sent)
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
