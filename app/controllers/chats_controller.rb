class ChatsController < ApplicationController
  include ImagesAttachable

  before_action :set_ollama_client
  before_action :list_models

  def index
    # Preload model, Reference: https://github.com/ollama/ollama/blob/main/docs/faq.md#how-can-i-preload-a-model-into-ollama-to-get-faster-response-times
    @ollama_client.chat(model_name, []) if model_name.present?
  end

  def submit_message
    user_message = permit_params[:prompt]

    system_message = "你是一位 AI 助理。除了回答你原本就知道答案的問題，也會根據用戶提供的網路資料歸納出問題答案。"
    chat.add_system_message(system_message)

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

    chat.add_user_message(user_message, attached_images_base64)

    @result = @ollama_client.chat(model_name, chat.all_messages, stream: false)
    chat.add_assistant_message(@result[0]["message"]) if @result.present?
    chat.save!

    result_content = ""
    if @result.present?
      result_message = @result[0]["message"]
      result_content = result_message["content"] if result_message.present?
    end

    response_data = { content: result_content }
    response_data[:data_sources] = data_sources if data_sources.length > 0
    response_data[:hash_id] = chat.hash_id
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

  def chat
    @chat ||= if permit_params[:hash_id].present?
      Chat.find_by(hash_id: permit_params[:hash_id])
    else
      Chat.new
    end
  end

  def model_name
    return "" if @model_options.blank?
    @model_options[permit_params[:model].to_i][0]
  end

  def set_ollama_client
    @ollama_client = OllamaClient.new
  end

  def list_models
    @model_options = []
    @model_options = @ollama_client.list_models
  rescue => e
    Rails.logger.error e.message
    flash[:alert] = "Connection to Ollama failed."
  end

  def permit_params
    params.permit(:hash_id, :model, :prompt, images: [])
  end
end
