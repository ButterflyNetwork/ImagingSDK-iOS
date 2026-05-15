/// Copyright 2012-2025 (C) Butterfly Network, Inc.

import ButterflyImagingKit
import UIKit

@MainActor
class Model: ObservableObject {
    enum Stage {
        case startingUp, ready, updateNeeded, startingImaging, imaging
    }
    @Published var availablePresets: [ImagingPreset] = []
    @Published var colorGain = 0
    @Published var depth = Measurement.centimeters(0)
    @Published var depthBounds = Measurement.centimeters(0)...Measurement.centimeters(0)
    @Published var gain = 0
    @Published var image: UIImage?
    @Published var imageRealWorldRect: Rect = .zero
    @Published var licenseState: ButterflyImaging.LicenseState = .invalid
    @Published var mode = UltrasoundMode.bMode
    @Published var preset: ImagingPreset?
    @Published var probe: Probe?
    @Published var stage = Stage.startingUp
    @Published var inProgress = false
    @Published var updating = false
    @Published var updateProgress: TimedProgress?

    @Published var alertError: Error? { didSet { showingAlert = (alertError != nil) } }
    @Published var showingAlert: Bool = false

    @Published var secondaryImage: UIImage?
    @Published var biplaneParameters: BiplaneParameters?
    @Published var imageMetadata: ButterflyImage.Metadata?
    @Published var mModeAngle: Measurement<UnitAngle> = .init(value: 0, unit: .degrees)
    @Published var mModeAngleMax: Measurement<UnitAngle> = .init(value: 0, unit: .degrees)
    // Accumulated sweep frames; customers collect these until isLastSweepFrame == true
    @Published var sweepFrames: [UIImage] = []
    @Published var showingSweepModal = false

    private let imaging = ButterflyImaging.shared

    static var shared: Model = Model()
    private init() {
        imaging.licenseStates = { [weak self] in
            self?.licenseState = $0
        }

        // Receive logs from the Butterfly Imaging SDK:
        imaging.clientLoggingCallback = { string, level in
            print("Butterfly SDK (level='\(level)': \(string)")
        }
        imaging.isClientLoggingEnabled = true
    }

    func setState(_ state: ImagingState, imagingStateChanges: ImagingStateChanges) {
        availablePresets = state.availablePresets
        colorGain = state.colorGain
        depth = state.depth
        depthBounds = state.depthBounds
        gain = state.gain
        mode = state.mode
        mModeAngle = state.mModeAngle
        mModeAngleMax = state.mModeAngleMax
        preset = state.preset
        probe = state.probe

        switch mode {
        case .bMode, .colorDoppler:
            if
                imagingStateChanges.bModeImageChanged,
                let bModeImage = state.bModeImage
            {
                image = bModeImage.image
                imageRealWorldRect = bModeImage.realWorldCoordinates
            }
        case .mMode:
            if
                imagingStateChanges.bModeImageChanged,
                let bModeImage = state.bModeImage
            {
                image = bModeImage.image
                imageRealWorldRect = bModeImage.realWorldCoordinates
            }
            if
                imagingStateChanges.mModeImageChanged,
                let img = state.mModeImage?.image
            {
                secondaryImage = img
            }
        case .autofan:
            if
                imagingStateChanges.bModeImageChanged,
                let bModeImage = state.bModeImage
            {
                image = bModeImage.image
                imageRealWorldRect = bModeImage.realWorldCoordinates
            }
        case .multiSlice:
            if
                imagingStateChanges.bModeImageChanged,
                let bModeImage = state.bModeImage
            {
                image = bModeImage.image
                imageRealWorldRect = bModeImage.realWorldCoordinates
                imageMetadata = bModeImage.metadata
                // Only accumulate frames when not already displaying a completed sweep.
                // Without this guard, the next sweep's frames would overwrite the modal contents
                // and sweepFrameIndex == 0 from the new sweep would wipe the displayed frames.
                if !showingSweepModal {
                    if bModeImage.metadata?.sweepFrameIndex == 0 {
                        sweepFrames = []
                    }
                    sweepFrames.append(bModeImage.image)
                    if bModeImage.metadata?.isLastSweepFrame == true {
                        showingSweepModal = true
                        imaging.stopImaging()
                    }
                }
            }
        case .biplane:
            if
                imagingStateChanges.bModeImageChanged,
                let bModeImage = state.bModeImage
            {
                image = bModeImage.image
                imageRealWorldRect = bModeImage.realWorldCoordinates
            }
            if
                imagingStateChanges.biplaneSecondaryImageChanged,
                let img = state.biplaneSecondaryImage?.image
            {
                secondaryImage = img
            }
            biplaneParameters = state.biplaneParameters
        @unknown default:
            break
        }

        if mode != .biplane {
            biplaneParameters = nil
        }
        if mode != .biplane, mode != .mMode {
            secondaryImage = nil
        }
        if mode != .multiSlice {
            imageMetadata = nil
        }

        switch stage {
        case .startingUp:
            stage = .ready
        case .ready:
            break
        case .updateNeeded:
            if state.probe.state != .firmwareIncompatible {
                stage = .ready
            }
        case .startingImaging:
            // If we have an image then we are “imaging”.
            if image != nil {
                stage = .imaging
            }
            // If the user disconnects the probe while we are starting imaging, revert.
            if state.probe.state == .disconnected {
                stopImaging()
            }
        case .imaging:
            if state.probe.state == .disconnected {
                stopImaging()
            }
        }

        if state.probe.state == .firmwareIncompatible {
            stage = .updateNeeded
        }
    }

    func startImaging(
        preset: ImagingPreset? = nil,
        depth: Double? = nil,
        gain: Int? = nil,
        colorGain: Int? = nil
    ) {
        stage = .startingImaging
        var parameters: PresetParameters? = nil

        // Send custom initial depth if it represents a change from the default one.
        if
            let preset,
            let depth,
            preset.defaultDepth.converted(to: .centimeters).value != depth
        {
            parameters = PresetParameters(
                depth: .centimeters(depth),
                gain: gain,
                colorGain: colorGain
            )
        }
        Task {
            do {
                try await imaging.startImaging(preset: preset, parameters: parameters)
            } catch {
                alertError = error
                print("Failed to startImaging, with error: \(error)")
            }
        }
    }

    func connectSimulatedProbe() async {
        inProgress = true
        await imaging.connectSimulatedProbe()
        inProgress = false
    }

    func disconnectSimulatedProbe() async {
        inProgress = true
        await imaging.disconnectSimulatedProbe()
        inProgress = false
    }

    func startup(clientKey: String) async throws {
        do {
            try await imaging.startup(clientKey: clientKey)

            // (Optional) setting up local client logging.
            imaging.isClientLoggingEnabled = true
            imaging.clientLoggingCallback = { message, severity in
                 print("[ButterflyImagingKitExample]: [\(severity)] \(message)")
            }
        } catch {
            alertError = error
            print("Failed to start up backend, with error: \(error)")
        }
    }

    func stopImaging() {
        stage = .ready
        imaging.stopImaging()
        image = nil
        imageRealWorldRect = .zero
        secondaryImage = nil
        biplaneParameters = nil
        imageMetadata = nil
        sweepFrames = []
        showingSweepModal = false
    }

    /// Starts the firmware update process.
    ///
    /// Note to ask user to keep the probe plugged-in during the update.
    func updateFirmware() async {
        updating = true
        do {
            for try await progress in imaging.updateFirmware() {
                updateProgress = progress
            }
            print("Update finished.")
        } catch {
            print("Update error: \(error)")
        }
        updating = false
    }

    func clearError() {
        alertError = nil
    }
}
