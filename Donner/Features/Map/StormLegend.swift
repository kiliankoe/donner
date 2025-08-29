import SwiftUI

struct StormLegend: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("storms_legend_title")
        .font(.caption.weight(.semibold))
        .foregroundStyle(Color.donnerTextPrimary)

      HStack(spacing: 8) {
        Circle()
          .fill(Color.donnerLightning)
          .frame(width: 12, height: 12)
        Text("storm_age_recent")
          .font(.caption2)
          .foregroundStyle(Color.donnerTextSecondary)
      }

      HStack(spacing: 8) {
        Circle()
          .fill(Color.donnerLightning.opacity(0.5))
          .frame(width: 12, height: 12)
        Text("storm_age_hours")
          .font(.caption2)
          .foregroundStyle(Color.donnerTextSecondary)
      }

      HStack(spacing: 8) {
        Circle()
          .fill(Color.gray.opacity(0.5))
          .frame(width: 12, height: 12)
        Text("storm_age_old")
          .font(.caption2)
          .foregroundStyle(Color.donnerTextSecondary)
      }
    }
    .padding(12)
    .background(Color.donnerCardBackground.opacity(0.9))
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}
