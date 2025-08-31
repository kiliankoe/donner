import SwiftUI

struct StormLegend: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("storms_legend_title")
        .font(.caption.weight(.semibold))
        .foregroundStyle(Color.donnerTextPrimary)

      HStack(spacing: 8) {
        Circle()
          .fill(Color.donnerStrikeToday)
          .frame(width: 12, height: 12)
        Text("storm_age_today")
          .font(.caption2)
          .foregroundStyle(Color.donnerTextSecondary)
      }

      HStack(spacing: 8) {
        Circle()
          .fill(Color.donnerStrikeThisWeek.opacity(0.75))
          .frame(width: 12, height: 12)
        Text("storm_age_this_week")
          .font(.caption2)
          .foregroundStyle(Color.donnerTextSecondary)
      }

      HStack(spacing: 8) {
        Circle()
          .fill(Color.donnerStrikeOlder.opacity(0.6))
          .frame(width: 12, height: 12)
        Text("storm_age_older")
          .font(.caption2)
          .foregroundStyle(Color.donnerTextSecondary)
      }
    }
    .padding(12)
    .background(Color.donnerCardBackground.opacity(0.9))
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}
