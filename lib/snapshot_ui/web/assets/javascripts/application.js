import { Application } from "@hotwired/stimulus"
import "@hotwired/turbo"
import "channels"

import RefreshController from "controllers/refresh_controller"

window.Stimulus = Application.start()
Stimulus.register("refresh", RefreshController)
