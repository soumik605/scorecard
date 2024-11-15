// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Import and register all TailwindCSS Components or just the ones you need
import { Tabs } from "tailwindcss-stimulus-components"
application.register('tabs', Tabs)
