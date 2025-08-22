import SwiftUI

struct HeadingAccuracyIndicator: View {
  let accuracyLevel: HeadingCaptureFeature.HeadingAccuracyLevel

  private var statusIcon: String {
    switch accuracyLevel {
    case .good:
      return "checkmark.circle.fill"
    case .fair:
      return "exclamationmark.circle.fill"
    case .poor, .uncalibrated:
      return "exclamationmark.triangle.fill"
    }
  }

  private var statusColor: Color {
    switch accuracyLevel {
    case .good:
      return .green
    case .fair:
      return .yellow
    case .poor, .uncalibrated:
      return .orange
    }
  }

  private var statusText: String {
    switch accuracyLevel {
    case .good:
      return NSLocalizedString("heading_accuracy_good", comment: "Compass calibrated")
    case .fair:
      return NSLocalizedString("heading_accuracy_fair", comment: "Compass accuracy fair")
    case .poor:
      return NSLocalizedString("heading_accuracy_poor", comment: "Move away from interference")
    case .uncalibrated:
      return NSLocalizedString("heading_accuracy_uncalibrated", comment: "Calibrate compass")
    }
  }

  private var calibrationInstructions: String? {
    switch accuracyLevel {
    case .poor, .uncalibrated:
      return NSLocalizedString(
        "heading_calibration_instructions", comment: "Move device in figure-8 pattern")
    default:
      return nil
    }
  }

  var body: some View {
    VStack(spacing: 4) {
      HStack(spacing: 6) {
        Image(systemName: statusIcon)
          .foregroundStyle(statusColor)

        Text(statusText)
          .font(.caption)
          .foregroundStyle(Color.donnerTextSecondary)
      }

      if let instructions = calibrationInstructions {
        Text(instructions)
          .font(.caption2)
          .foregroundStyle(Color.donnerTextSecondary)
          .multilineTextAlignment(.center)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(Color.donnerCardBackground.opacity(0.8))
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}
