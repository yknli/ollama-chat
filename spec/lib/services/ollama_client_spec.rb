require "rails_helper"
require "services/ollama_client"

RSpec.describe OllamaClient do
  describe "#initialize" do
    context "when OLLAMA_HOST is set" do
      before do
        ENV["OLLAMA_HOST"] = "http://localhost:11434"
      end

      it "creates an Ollama client instance" do
        ollama_client = OllamaClient.new
        expect(ollama_client.instance_variable_get(:@client)).to be_a(Ollama::Controllers::Client)
      end
    end

    context "when OLLAMA_HOST is not set" do
      before do
        ENV["OLLAMA_HOST"] = nil
      end

      it "does not raise an error" do
        expect { OllamaClient.new }.not_to raise_error
      end
    end
  end

  describe "#list_models" do
    let(:ollama_client) { OllamaClient.new }
    let(:mock_ollama_client) { instance_double(Ollama::Controllers::Client) }

    before do
      allow(Ollama).to receive(:new).and_return(mock_ollama_client)
    end

    context "when models are present" do
      let(:models_data) { [ { "models" => [ { "name" => "model1" }, { "name" => "model2" } ] } ] }

      before do
        allow(mock_ollama_client).to receive(:tags).and_return(models_data)
      end

      it "returns an array of model names with indices" do
        expect(ollama_client.list_models).to eq([ [ "model1", 0 ], [ "model2", 1 ] ])
      end
    end

    context "when models are not present" do
      before do
        allow(mock_ollama_client).to receive(:tags).and_return([])
      end

      it "returns an empty array" do
        expect(ollama_client.list_models).to eq([])
      end
    end

    context "when tags are nil" do
      before do
        allow(mock_ollama_client).to receive(:tags).and_return(nil)
      end

      it "returns an empty array" do
        expect(ollama_client.list_models).to eq([])
      end
    end
  end

  describe "#chat" do
    let(:ollama_client) { OllamaClient.new }
    let(:mock_ollama_client) { instance_double(Ollama::Controllers::Client) }
    let(:model_name) { "test_model" }
    let(:messages) { [ { "role" => "user", "content" => "hello" } ] }

    before do
      allow(Ollama).to receive(:new).and_return(mock_ollama_client)
    end

    it "calls the chat method on the Ollama client with correct arguments" do
      allow(mock_ollama_client).to receive(:chat)
      ollama_client.chat(model_name, messages)
      expect(mock_ollama_client).to have_received(:chat).with(
        { model: model_name, messages: messages, stream: false }
      )
    end

    it "passes the stream option to the Ollama client" do
      allow(mock_ollama_client).to receive(:chat)
      ollama_client.chat(model_name, messages, stream: true)
      expect(mock_ollama_client).to have_received(:chat).with(
        { model: model_name, messages: messages, stream: true }
      )
    end
  end
end
