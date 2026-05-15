/// Copyright 2012-2025 (C) Butterfly Network, Inc.

import ButterflyImagingKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var model: Model
    @State private var availablePresets: [ImagingPreset] = []
    @State private var depthBounds = Measurement.centimeters(0)...Measurement.centimeters(0)
    @State private var controlDepth = 10.0
    @State private var controlGain = 50.0
    @State private var controlColorGain = 0.0
    @State private var controlPreset: ImagingPreset?
    @State private var controlMode: UltrasoundMode = .bMode
    @State private var statusPanelIndex: String?
    @State private var controlPlanePosition: Float = 0
    @State private var isDraggingPlane = false
    @State private var controlMModeAngle: Float = 0
    @State private var isDraggingMModeAngle = false

    let imaging = ButterflyImaging.shared

    var body: some View {
        ZStack {
            switch model.stage {
            case .startingUp:
                Text("Initializing...")

            case .ready:
                VStack(spacing: 10) {
                    if model.inProgress {
                        ProgressView()
                    } else if model.probe?.state == .hardwareIncompatible {
                        Text("Probe incompatible.")
                    } else if model.probe?.state == .disconnected {
                        Button("Connect a simulated probe") {
                            Task {
                                await model.connectSimulatedProbe()
                            }
                        }
                    } else if !model.availablePresets.isEmpty {
                        if model.probe?.isSimulated == true {
                            Button("Disconnect simulated probe") {
                                Task {
                                    await model.disconnectSimulatedProbe()
                                    controlPreset = nil
                                }
                            }
                        }

                        HStack {
                            PresetPicker(controlPreset: $controlPreset, availablePresets: $availablePresets)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onChange(of: controlPreset, initial: true) { _, preset in
                                    guard let preset else { return }
                                    controlDepth = preset.defaultDepth.value
                                    depthBounds = preset.depthBounds
                                }
                            Button("Start imaging!") {
                                // Probe (real or simulated) needs to be connected before tapping this.
                                model.startImaging(preset: controlPreset, depth: controlDepth)
                            }
                            .fixedSize()
                        }

                        if controlPreset != nil {
                            BoundsSlider(title: "Depth", control: $controlDepth, bounds: $depthBounds)
                        }
                    } else {
                        ProgressView()
                    }
                    Spacer()
                }
                .padding()

            case .updateNeeded:
                UpdateFirmwareView()
                    .environmentObject(model)

            case .startingImaging:
                ProgressView()

            case .imaging:
                if model.mode == .biplane {
                    HStack(spacing: 0) {
                        if let image = model.image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .overlay {
                                    if let params = model.biplaneParameters {
                                        PerpPlaneLineOverlay(
                                            isLinearPreset: controlPreset?.isLinearPreset ?? false,
                                            controlPlanePosition: controlPlanePosition,
                                            imageRealWorldRect: model.imageRealWorldRect,
                                            params: params
                                        )
                                    }
                                }
                        }
                        if let secondary = model.secondaryImage {
                            Image(uiImage: secondary)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .ignoresSafeArea()
                } else if let image = model.image {
                    HStack(spacing: 0) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .overlay {
                                if model.mode == .mMode {
                                    MModeLineOverlay(controlAngle: controlMModeAngle)
                                }
                            }
                        if let secondary = model.secondaryImage {
                            Image(uiImage: secondary)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .ignoresSafeArea()
                }
            }

            if model.stage == .imaging {
                VStack(spacing: 4) {
                    HStack {
                        PresetPicker(controlPreset: $controlPreset, availablePresets: $availablePresets)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onChange(of: controlPreset, initial: true) { _, preset in
                                guard let preset else { return }
                                imaging.setPreset(preset, parameters: nil)
                                self.controlMode = .bMode
                            }
                        Button("Stop imaging") {
                            model.stopImaging()
                            controlPreset = nil
                        }
                        .fixedSize()
                    }

                    Picker("Select a mode", selection: $controlMode) {
                        if let supportedModes = model.preset?.supportedModes {
                            ForEach(supportedModes) {
                                Text($0.description)
                            }
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: controlMode, initial: true) { _, value in
                        imaging.setMode(value)
                    }

                    BoundsSlider(title: "Depth", control: $controlDepth, bounds: $model.depthBounds) { editing in
                        guard !editing else { return }
                        imaging.setDepth(Measurement.centimeters(controlDepth))
                    }
                    .disabled(model.mode == .multiSlice)

                    HStack {
                        Text("Gain:")
                        Slider(
                            value: Binding(get: {
                                controlGain
                            }, set: { newVal in
                                controlGain = newVal
                                imaging.setGain(Int(controlGain))
                            }),
                            in: 0...100
                        ) {
                            Text("Gain:")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("100")
                        }
                    }
                    .disabled(model.mode == .multiSlice)

                    if model.mode == .colorDoppler {
                        HStack {
                            Text("Color Gain:")
                            Slider(
                                value: Binding(get: {
                                    controlColorGain
                                }, set: { newVal in
                                    controlColorGain = newVal
                                    imaging.setColorGain(Int(controlColorGain))
                                }),
                                in: 0...100
                            ) {
                                Text("Color Gain:")
                            } minimumValueLabel: {
                                Text("0")
                            } maximumValueLabel: {
                                Text("100")
                            }
                        }
                    }

                    if
                        model.mode == .multiSlice,
                        let meta = model.imageMetadata,
                        let index = meta.sweepFrameIndex,
                        let total = meta.sweepTotalFrames
                    {
                        Text("Frame \(index + 1) of \(total)")
                            .font(.caption)
                    }

                    if model.mode == .biplane, let params = model.biplaneParameters {
                        if controlPreset?.isLinearPreset == true {
                            let maxX = params.maxXMeters.value
                            HStack {
                                Text("Plane Position:")
                                Slider(
                                    value: Binding(
                                        get: { Double(controlPlanePosition) },
                                        set: { controlPlanePosition = Float($0) }
                                    ),
                                    in: -maxX...maxX,
                                    onEditingChanged: { editing in
                                        isDraggingPlane = editing
                                        if !editing {
                                            imaging.setPlaneLocation(
                                                .linear(positionMeters: Measurement(
                                                    value: Double(controlPlanePosition),
                                                    unit: .meters
                                                ))
                                            )
                                        }
                                    }
                                )
                            }
                        } else {
                            let maxAngle = params.maxAngleDegrees.value
                            HStack {
                                Text("Plane Angle:")
                                Slider(
                                    value: Binding(
                                        get: { Double(controlPlanePosition) },
                                        set: { controlPlanePosition = Float($0) }
                                    ),
                                    in: -maxAngle...maxAngle,
                                    onEditingChanged: { editing in
                                        isDraggingPlane = editing
                                        if !editing {
                                            imaging.setPlaneLocation(
                                                .sector(angleDegrees: Measurement(
                                                    value: Double(controlPlanePosition),
                                                    unit: .degrees
                                                ))
                                            )
                                        }
                                    }
                                )
                            }
                        }
                    }

                    if model.mode == .mMode {
                        let maxAngle = model.mModeAngleMax.converted(to: .degrees).value
                        HStack {
                            Text("M-Mode Angle:")
                            Slider(
                                value: Binding(
                                    get: { Double(controlMModeAngle) },
                                    set: { controlMModeAngle = Float($0) }
                                ),
                                in: -maxAngle...maxAngle,
                                onEditingChanged: { editing in
                                    isDraggingMModeAngle = editing
                                    if !editing {
                                        imaging.setMModeAngle(Measurement(
                                            value: Double(controlMModeAngle), unit: .degrees
                                        ))
                                    }
                                }
                            )
                        }
                    }
                    Spacer()
                }
                .padding(.top, 4)
                .padding(.horizontal, 20)
                .padding(.bottom)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }

            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    if let probeDataList = model.probe?.probeDataList {
                        ForEach(probeDataList) { probeData in
                            Text("\(probeData.id): \(probeData.value)")
                                .opacity(0.5)
                                .font(.system(size: 12))
                        }
                    }

                    Text(statusPanelIndex ?? "-")
                        .opacity(0.5)
                        .font(.system(size: 12))

                    Text("license: \(String(describing: model.licenseState))")
                        .opacity(0.5)
                        .font(.system(size: 12))
                }
                Spacer()
            }
            .padding()
        }
        .onAppear {
            imaging.states = { state, imagingStateChanges in

                // Check for state changes.

                if model.preset != state.preset {
                    controlPreset = state.preset
                }

                if model.depth != state.depth {
                    controlDepth = state.depth.value
                }

                if model.gain != state.gain {
                    controlGain = Double(state.gain)
                }

                if model.colorGain != state.colorGain {
                    controlColorGain = Double(state.colorGain)
                }

                statusPanelIndex = state.formttedStatusPanelIndex

                if !isDraggingPlane, let params = state.biplaneParameters {
                    let isLinear = state.preset?.isLinearPreset ?? false
                    controlPlanePosition = isLinear
                        ? params.xPositionMeters
                        : params.perpendicularPlaneAngleDegrees
                }

                if !isDraggingMModeAngle {
                    controlMModeAngle = Float(state.mModeAngle.converted(to: .degrees).value)
                }

                // Set the new state.
                model.setState(state, imagingStateChanges: imagingStateChanges)
                availablePresets = state.availablePresets
            }

            Task { try? await model.startup(clientKey: clientKey) }
        }
        .alert(
            "Error",
            isPresented: $model.showingAlert,
            presenting: model.alertError,
            actions: { _ in Button("OK", role: .cancel) { model.clearError() } },
            message: { detail in Text("Error: \(String(describing: detail))") }
        )
        .sheet(isPresented: $model.showingSweepModal, onDismiss: {
            Task { @MainActor in
                imaging.setMode(.bMode)
                model.startImaging(
                    preset: controlPreset,
                    depth: controlDepth,
                    gain: Int(controlGain),
                    colorGain: Int(controlColorGain)
                )
                controlMode = .bMode
                model.sweepFrames = []
            }
        }) {
            SweepFramesView(frames: model.sweepFrames)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: Model.shared)
            .preferredColorScheme(.dark)
    }
}

struct PresetPicker: View {
    @Binding var controlPreset: ImagingPreset?
    @Binding var availablePresets: [ImagingPreset]

    var body: some View {
        HStack(spacing: 0) {
            Text("Preset:")
            Picker("Preset", selection: $controlPreset) {
                if controlPreset == nil {
                    Text("---").tag(nil as ImagingPreset?)
                }
                ForEach(availablePresets, id: \.self) {
                    Text($0.displayName).tag($0 as ImagingPreset?)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private extension ImagingPreset {
    var displayName: String {
        let suffix = isVeterinary ? " (Vet)" : ""
        return name + suffix
    }
}

struct BoundsSlider: View {
    var title: String
    @Binding var control: Double
    @Binding var bounds: ClosedRange<Measurement<UnitLength>>
    var onEditingChanged: ((Bool) -> Void) = { _ in }

    var body: some View {
        HStack {
            Text("\(title):")
            Slider(
                value: $control,
                in: bounds.lowerBound.value...bounds.upperBound.value,
                label: {
                    Text("\(title):")
                },
                minimumValueLabel: {
                    Text(bounds.lowerBound.label)
                },
                maximumValueLabel: {
                    Text(bounds.upperBound.label)
                },
                onEditingChanged: onEditingChanged
            )
        }
    }
}

struct PerpPlaneLineOverlay: View {
    let isLinearPreset: Bool
    let controlPlanePosition: Float
    let imageRealWorldRect: Rect
    let params: BiplaneParameters

    var body: some View {
        Canvas { context, size in
            let lineColor = Color.cyan.opacity(0.8)
            if isLinearPreset {
                let scalingFactor = size.width / imageRealWorldRect.width
                let x = 0.5 * size.width + Double(controlPlanePosition) * scalingFactor

                var line = Path()
                line.move(to: CGPoint(x: x, y: 0))
                line.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(line, with: .color(lineColor), lineWidth: 2)
            } else {
                let angleRad = Measurement(value: Double(controlPlanePosition), unit: UnitAngle.degrees)
                    .converted(to: .radians)
                    .value
                let centerX = size.width / 2
                let length = max(size.width, size.height)

                var line = Path()
                line.move(to: CGPoint(x: centerX, y: 0))
                line.addLine(to: CGPoint(x: centerX + length * sin(angleRad), y: length * cos(angleRad)))
                context.stroke(line, with: .color(lineColor), lineWidth: 2)
            }
        }
    }
}

// MARK: - MModeLineOverlay

/// Draws the M-mode scanline angle on the B-mode image.
struct MModeLineOverlay: View {
    let controlAngle: Float

    var body: some View {
        Canvas { context, size in
            let lineColor = Color.cyan.opacity(0.8)
            let angleRad = Double(controlAngle) * .pi / 180
            let centerX = size.width / 2
            let length = max(size.width, size.height)
            var line = Path()
            line.move(to: CGPoint(x: centerX, y: 0))
            line.addLine(to: CGPoint(x: centerX + length * sin(angleRad), y: length * cos(angleRad)))
            context.stroke(line, with: .color(lineColor), lineWidth: 2)
        }
    }
}

struct SweepFramesView: View {
    let frames: [UIImage]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 8) {
                    ForEach(frames.indices, id: \.self) { index in
                        VStack(spacing: 4) {
                            Image(uiImage: frames[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            Text("Frame \(index + 1)")
                                .font(.caption2)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Sweep Frames (\(frames.count))")
        }
    }
}

struct UpdateFirmwareView: View {
    @EnvironmentObject var model: Model

    var body: some View {
        VStack {
            Text("⚠️")
                .font(.title)
            Text("Probe firmware is out-of-date")
            if !model.updating {
                Button("Update firmware") {
                    Task {
                        await model.updateFirmware()
                    }
                }
            } else {
                Text("Updating firmware...")
                Text("Please keep the app open and iQ plugged in.")
                    .fontWeight(.bold)
                if let progress = model.updateProgress {
                    Text("\(Int(progress.timeRemaining)) seconds remaining")
                    Text("\(Int(progress.fractionCompleted * 100))%")
                }
                ProgressView()
            }
        }
    }
}
