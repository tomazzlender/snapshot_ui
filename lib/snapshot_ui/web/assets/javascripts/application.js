// Turbo and Stimulus are bundled with the gem (see vendor/), so the UI works
// without internet access. Their versions are noted in the headers of the
// vendored files.
import "@hotwired/turbo"
import { Application } from "@hotwired/stimulus"

import RefreshController from "controllers/refresh_controller"
import SourceLocationController from "controllers/source_location_controller"

window.Stimulus = Application.start()
Stimulus.register("refresh", RefreshController)
Stimulus.register("source-location", SourceLocationController)
