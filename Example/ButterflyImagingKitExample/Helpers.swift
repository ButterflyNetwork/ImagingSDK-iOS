/// Copyright 2012-2025 (C) Butterfly Network, Inc.

import ButterflyImagingKit
import Foundation

struct ProbeData: Identifiable {
    let id: String
    let value: String
}

extension Probe {
    var probeDataList: [ProbeData] {
        return [
        ProbeData(id: "type", value: String(describing: type)),
        ProbeData(id: "practiceType", value: String(describing: practiceType)),
        ProbeData(id: "serialNumber", value: String(describing: serialNumber)),
        ProbeData(id: "state", value: String(describing: state)),
        ProbeData(id: "batteryPercentage", value: String(Int((batteryPercentage * 100)
            .rounded(.awayFromZero))) + "%"),
        ProbeData(id: "batteryState", value: String(describing: batteryState)),
        ProbeData(id: "estimatedTemperature", value: String(estimatedTemperature)),
        ProbeData(id: "unitRelativeTemperature", value: String(unitRelativeTemperature)),
        ProbeData(id: "temperatureState", value: String(describing: temperatureState)),
        ProbeData(id: "buttonPressedCountMain", value: String(buttonPressedCountMain)),
        ProbeData(id: "buttonPressedCountUp", value: String(buttonPressedCountUp)),
        ProbeData(id: "buttonPressedCountDown", value: String(buttonPressedCountDown)),
        ProbeData(id: "tla", value: tla),
        ProbeData(id: "udiDi", value: udiDi),
        ProbeData(id: "udiPi", value: udiPi)]
    }
}

extension ImagingPreset: Identifiable, Hashable {
    public var id: String { self.uuid }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public static func == (lhs: ImagingPreset, rhs: ImagingPreset) -> Bool {
        return lhs.id == rhs.id
    }
}

extension UltrasoundMode: Identifiable {
    public var id: UltrasoundMode { self }
    public var description: String {
        switch self {
        case .bMode: return "B-Mode"
        case .mMode: return "M-Mode"
        case .colorDoppler: return "Color Doppler"
        @unknown default: return ""
        }
    }
}

let wholeNumberFormatter: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitStyle = .medium
    formatter.unitOptions = [.providedUnit]
    formatter.numberFormatter.maximumFractionDigits = 0
    return formatter
}()

extension Measurement where UnitType == UnitLength {
    var label: String {
        wholeNumberFormatter.string(from: self)
    }
}

extension Measurement {
    static func centimeters(_ value: Double) -> Measurement<UnitLength> {
        Measurement<UnitLength>(value: value, unit: .centimeters)
    }
}
