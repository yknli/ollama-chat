// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"

import ChatsController from "controllers/chats_controller"
application.register("hello", ChatsController)

import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
