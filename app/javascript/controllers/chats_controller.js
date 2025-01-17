import { Controller } from "@hotwired/stimulus"
import Rails from '@rails/ujs';

export default class extends Controller {

  static targets = [ "hashId", "chatBody", "prompt", "selectedModel", "images" ]

  send(event) {
    event.preventDefault();
    let hashId = this.hashIdTarget.value;
    let model = this.selectedModelTarget.value;

    let prompt = this.promptTarget.value;
    if (prompt.trim().length === 0) {
      return;
    }

    // Append the message to the chat
    this.appendMessage(prompt);

    // Show loading icon while waiting for response
    this.appendLoadingIcon();

    const formData = new FormData();
    formData.append("hash_id", hashId);
    formData.append("model", model);
    formData.append("prompt", prompt);

    let images = null;
    if (this.imagesTarget.files.length > 0) {
      // images is a Object
      images = this.imagesTarget.files;
      for(let i = 0; i < images.length; i++) {
        formData.append(`images[]`, images[i]);
      }
    }

    // Clear the form
    this.clear();

    // Send the prompt to the server
    Rails.ajax({
      url: '/submit_message.json',
      type: 'POST',
      data: formData,
      success: resp => {
        if (resp.content) {
          // Display the response
          let modelResponse = resp.content;

          // Append data sources from internet
          if (resp.data_sources && resp.data_sources.length > 0) {
            let formattedDataSources = this.formatDataSources(resp.data_sources);
            modelResponse += `${formattedDataSources}`;
          }

          // Set chat hash id for keeping chat context
          if (this.hashIdTarget.value === "" &&resp.hash_id) {
            this.hashIdTarget.value = resp.hash_id;
          }

          this.responseMessage(modelResponse);

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

  appendMessage(message) {
    this.chatBodyTarget.innerHTML+= '' +
    '<div class="chat-message message-sent">' +
      '<div class="bg-primary text-white p-3 rounded d-inline-block message-body">' +
      message +
      '</div>' +
    '</div>';

    this.scrollToBottom();
  }

  formatDataSources(dataSources) {
    let formatted = [];
    dataSources.forEach((dataSource, index) => {
      formatted.push(`${index + 1}. <a href="${dataSource}">${dataSource}</a>`);
    });

    let formattedDataSources = `<br/><br/>資料來源:<br/>`;
    formattedDataSources += formatted.join('<br/>');
    return formattedDataSources;
  }

  appendLoadingIcon() {
    this.chatBodyTarget.innerHTML+= '<div class="loading">' +
      '<div class="spinner-grow text-primary loading-dot" role="status"></div>' +
      '<div class="spinner-grow text-success loading-dot" role="status"></div>' +
      '<div class="spinner-grow text-danger loading-dot" role="status"></div>' +
      '<div class="spinner-grow text-warning loading-dot" role="status"></div>' +
    '</div>'

    this.scrollToBottom();
  }

  responseMessage(message) {
    // Remove the loading icon
    this.removeLoadingIcon();

    this.chatBodyTarget.innerHTML+= '' +
    '<div class="chat-message message-received">' +
      '<div class="bg-warning p-3 rounded d-inline-block message-body">' +
      message +
      '</div>' +
    '</div>';

    this.scrollToBottom();
  }

  // Display the error message
  responseError(err) {
    // Remove the loading icon
    this.removeLoadingIcon();

    this.chatBodyTarget.innerHTML+= '' +
    '<div class="chat-message message-received">' +
      '<div class="bg-danger p-3 rounded d-inline-block message-body error">' +
      'Sorry, Something went wrong. Please try again later.' +
      '</div>' +
    '</div>';

    this.scrollToBottom();
  }

  scrollToBottom() {
    this.chatBodyTarget.scrollTo(0, this.chatBodyTarget.scrollHeight);
  }

  removeLoadingIcon() {
    document.querySelector('.loading').remove();
  }

  clear() {
    this.element.reset();
  }
}
