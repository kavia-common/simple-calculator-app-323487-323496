import SwiftUI

// SwiftPM executable entry point. We use a minimal App to host SwiftUI content.
@main
struct CalculatorFrontendApp: App {
    var body: some Scene {
        WindowGroup {
            CalculatorView()
        }
    }
}
