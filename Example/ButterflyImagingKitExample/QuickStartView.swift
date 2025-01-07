/// Copyright 2012-2025 (C) Butterfly Network, Inc.

import ButterflyImagingKit
import SwiftUI

private let imagingSDK = ButterflyImaging.shared
private var didStart = false

struct QuickStartView: View {
    @State var image: UIImage
    var body: some View {
        Image(uiImage: image)
            .onAppear {
                Task { await quickStart() }
            }
    }

    func quickStart() async {
        // 1. Set up callback closure to handle state changes.
        imagingSDK.states = { state, stateChanges in
            Task {
                guard !didStart else { return }
                didStart = true

                // 3. Connect the simulated probe.
                await imagingSDK.connectSimulatedProbe()

                // 4. Start imaging.
                try? await imagingSDK.startImaging()
            }

            // 5. Present image.
            guard stateChanges.bModeImageChanged, let bModeImage = state.bModeImage?.image else { return }
            image = bModeImage
        }

        // 2. Start the SDK with your client key.
        try? await imagingSDK.startup(clientKey: clientKey)
    }
}

#Preview {
    QuickStartView(image: .remove)
}
