import Foundation

extension MeasurementFormatter {

  static let distance: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .naturalScale
    formatter.numberFormatter.maximumFractionDigits = 1
    formatter.numberFormatter.locale = Locale.current
    return formatter
  }()

  static let preciseDistance: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit
    formatter.unitStyle = .short
    formatter.numberFormatter.minimumFractionDigits = 1
    formatter.numberFormatter.maximumFractionDigits = 2
    formatter.numberFormatter.locale = Locale.current
    return formatter
  }()

  static let duration: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit
    formatter.unitStyle = .short
    formatter.numberFormatter.minimumFractionDigits = 1
    formatter.numberFormatter.maximumFractionDigits = 1
    formatter.numberFormatter.locale = Locale.current
    return formatter
  }()

  static let preciseTime: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit
    formatter.unitStyle = .short
    formatter.numberFormatter.minimumFractionDigits = 2
    formatter.numberFormatter.maximumFractionDigits = 2
    formatter.numberFormatter.locale = Locale.current
    return formatter
  }()
}
