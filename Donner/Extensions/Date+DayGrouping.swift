import Foundation

extension Date {
  /// Returns the start of the "day" with 4am as the cutoff
  /// Everything before 4am belongs to the previous day
  var dayGroupingDate: Date {
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: self)

    if hour < 4 {
      // Before 4am, belongs to previous day
      let previousDay = calendar.date(byAdding: .day, value: -1, to: self) ?? self
      return calendar.startOfDay(for: previousDay)
    } else {
      // After 4am, belongs to current day
      return calendar.startOfDay(for: self)
    }
  }

  /// Check if two dates belong to the same day group (with 4am cutoff)
  func belongsToSameDayGroup(as otherDate: Date) -> Bool {
    dayGroupingDate == otherDate.dayGroupingDate
  }

  /// Returns a relative day string like "Today", "Yesterday", "Monday", or absolute date
  func relativeDayString(from referenceDate: Date = Date()) -> String {
    let calendar = Calendar.current
    let thisDayGroup = dayGroupingDate
    let referenceDayGroup = referenceDate.dayGroupingDate

    let dayDifference =
      calendar.dateComponents([.day], from: thisDayGroup, to: referenceDayGroup).day ?? 0

    switch dayDifference {
    case 0:
      return "Today"
    case 1:
      return "Yesterday"
    case 2...6:
      // Show weekday name for recent days
      let formatter = DateFormatter()
      formatter.dateFormat = "EEEE"
      return formatter.string(from: thisDayGroup)
    default:
      // Show absolute date for older days
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .none
      return formatter.string(from: thisDayGroup)
    }
  }
}
