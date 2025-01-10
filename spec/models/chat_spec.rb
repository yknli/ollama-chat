require 'rails_helper'

RSpec.describe Chat, type: :model do
  context "when a chat is created" do
    before(:each) do
      @chat = Chat.new
    end

    describe "validations" do
      it { should validate_presence_of(:hash_id) }
    end

    describe "unsaved_messages" do
      subject { @chat.send(:unsaved_messages) }
      it "returns an empty array if there are no unsaved messages" do
        expect(subject).to eq([])
      end
    end

    describe "add_system_message" do
      it "adds a system message to unsaved messages" do
        @chat.add_system_message("system message")
        expect(@chat.send(:unsaved_messages)).to eq([ { "role" => "system", "content" => "system message" } ])
      end
    end

    describe "add_user_message" do
      it "adds a user message to unsaved messages" do
        @chat.add_user_message("user message", [])
        expect(@chat.send(:unsaved_messages)).to eq([ { "role" => "user", "content" => "user message" } ])
      end

      it "adds images to the user message" do
        @chat.add_user_message("user message", [ "image" ])
        expect(@chat.send(:unsaved_messages)).to eq([ { "role" => "user", "content" => "user message", "images" => [ "image" ] } ])
      end
    end

    describe "add_assistant_message" do
      it "adds a assistant message to unsaved messages" do
        @chat.add_assistant_message({ "role" => "assistant", "content" => "assistant message" })
        expect(@chat.send(:unsaved_messages)).to eq([ { "role" => "assistant", "content" => "assistant message" } ])
      end
    end

    describe "all_messages" do
      let(:assistant_message) { { "role" => "assistant", "content" => "assistant message" } }
      it "returns the saved and unsaved messages" do
        @chat.messages = [ { role: "system", content: "system message" } ].to_json
        @chat.add_user_message("user message", [ "image" ])
        @chat.add_assistant_message(assistant_message)
        expect(@chat.all_messages).to eq([
          { "role" => "system", "content" => "system message" },
          { "role" => "user", "content" => "user message", "images" => [ "image" ] },
          { "role" => "assistant", "content" => "assistant message" }
        ])
      end
    end

    describe "parse_all_messages" do
      it "parses the all messages to json" do
        @chat.add_user_message("user message", [])
        @chat.send(:parse_all_messages)
        expect(@chat.messages).to eq([ { "role" => "user", "content" => "user message" } ].to_json)
      end
    end
  end
end
