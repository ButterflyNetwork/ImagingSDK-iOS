/// Copyright 2012-2024 (C) Butterfly Network, Inc.

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
    @Published var licenseState: ButterflyImaging.LicenseState = .invalid
    @Published var mode = UltrasoundMode.bMode
    @Published var preset: ImagingPreset?
    @Published var probe: Probe?
    @Published var stage = Stage.startingUp
    @Published var inProgress = false
    @Published var updating = false
    @Published var updateProgress: TimedProgress?

    private let imaging = ButterflyImaging.shared

    static var shared: Model = Model()
    private init() {
        imaging.licenseStates = { [weak self] in
            self?.licenseState = $0
        }
    }

    func setState(_ state: ImagingState, imagingStateChanges: ImagingStateChanges) {
        availablePresets = state.availablePresets
        colorGain = state.colorGain
        depth = state.depth
        depthBounds = state.depthBounds
        gain = state.gain
        mode = state.mode
        preset = state.preset
        probe = state.probe

        switch mode {
        case .bMode, .colorDoppler:
            if imagingStateChanges.bModeImageChanged,
               let img = state.bModeImage?.image {
                image = img
            }
        case .mMode:
            if imagingStateChanges.mModeImageChanged,
               let img = state.mModeImage?.image {
                image = img
            }
        @unknown default:
            break
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
            if image != nil {
                stage = .imaging
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

    func startImaging(preset: ImagingPreset? = nil, depth: Double? = nil) {
        stage = .startingImaging
        var parameters: PresetParameters? = nil

        // Send custom initial depth if it represents a change from the default one.
        if let preset,
           let depth,
           preset.defaultDepth.converted(to: .centimeters).value != depth {
            parameters = PresetParameters(depth: .centimeters(depth))
        }
        Task { try? await imaging.startImaging(preset: preset, parameters: parameters) }
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

    func stopImaging() {
        stage = .ready
        imaging.stopImaging()
        image = nil
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
}
