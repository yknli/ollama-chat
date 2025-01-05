import { Controller } from "@hotwired/stimulus"
import Rails from '@rails/ujs';

export default class extends Controller {

  static targets = [ "chatBody", "newPrompt", "selectedModel" ]
  static values = {
    loadingIconPath: String
  }

  connect() {
    console.log('connect');
  }

  send(event) {
    event.preventDefault();

    let prompt = this.newPromptTarget.value;

    if (prompt.trim().length === 0) {
      return;
    }

    this.chatBodyTarget.innerHTML+= '' +
    '<div class="chat-message message-sent">' +
      '<div class="bg-primary text-white p-3 rounded d-inline-block message-body">' +
      prompt +
      '</div>' +
    '</div>';

    let data = {
      model: this.selectedModelTarget.value,
      prompt: this.newPromptTarget.value,
    }

    // Clear the promt text box
    this.newPromptTarget.value = '';

    // Show loading icon while waiting for response
    this.chatBodyTarget.innerHTML+= '<div class="loading">' +
      '<div class="spinner-grow text-primary loading-dot" role="status"></div>' +
      '<div class="spinner-grow text-success loading-dot" role="status"></div>' +
      '<div class="spinner-grow text-danger loading-dot" role="status"></div>' +
      '<div class="spinner-grow text-warning loading-dot" role="status"></div>' +
    '</div>'

    // Send the prompt to the server
    Rails.ajax({
      url: '/submit_message.json',
      type: 'POST',
      data: new URLSearchParams(data).toString(),
      success: resp => {
        if (resp.length > 0) {
          // Remove the loading icon
          document.querySelector('.loading').remove();

          // Display the response
          let model_response = resp[0].message.content
          this.chatBodyTarget.innerHTML+= '' +
          '<div class="chat-message message-received">' +
            '<div class="bg-warning p-3 rounded d-inline-block message-body">' +
            model_response +
            '</div>' +
          '</div>';
        } else {
          // Display the error message
          this.responseError();
        }
      },
      error: err => {
        // Display the error message
        this.responseError(err);
      }
    })
  }

  // Display the error message
  responseError(err) {
    if (err) {
      console.log(err);
    }
    // Remove the loading icon
    document.querySelector('.loading').remove();

    this.chatBodyTarget.innerHTML+= '' +
    '<div class="chat-message message-received">' +
      '<div class="bg-danger p-3 rounded d-inline-block message-body error">' +
      'Sorry, Something went wrong. Please try again later.' +
      '</div>' +
    '</div>';
  }
}
