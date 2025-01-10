class Chat < ApplicationRecord
  before_save :parse_all_messages

  validates :hash_id, presence: true

  def add_system_message(system_message)
    self.unsaved_messages << { "role" => "system",  "content" => system_message }
  end

  def add_user_message(user_message, images=[])
    msg = { "role" => "user", "content" => user_message }
    msg["images"] = images if images.present?
    self.unsaved_messages << msg
  end

  def add_assistant_message(assistant_message)
    self.unsaved_messages << assistant_message
  end

  def all_messages
    self.saved_messages + self.unsaved_messages
  end

  private

  def saved_messages
    return [] if self.messages.nil?
    JSON.parse(self.messages)
  end

  def unsaved_messages
    @unsaved_messages = [] if @unsaved_messages.nil?
    @unsaved_messages
  end

  def parse_all_messages
    self.messages = all_messages.to_json
  end
end
