/// Copyright 2012-2024 (C) Butterfly Network, Inc.

import SwiftUI

// Replace with your client key.
let clientKey = "CLIENT KEY"

@main
struct ButterflyImagingKitExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(model: Model.shared)
                .preferredColorScheme(.dark)
        }
    }
}
