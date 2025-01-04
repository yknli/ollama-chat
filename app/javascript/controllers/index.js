// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"

import OllamaaiController from "controllers/ollamaai_controller"
application.register("hello", OllamaaiController)

import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
