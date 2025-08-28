import SwiftUI

struct StormDivider: View {
  let date: Date

  init(date: Date = Date()) {
    self.date = date
  }

  private var relativeDate: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: date, relativeTo: Date())
  }

  var body: some View {
    HStack(spacing: 12) {
      Rectangle()
        .fill(
          LinearGradient(
            colors: [
              Color.donnerTextSecondary.opacity(0),
              Color.donnerTextSecondary.opacity(0.3),
            ],
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .frame(height: 1)

      HStack(spacing: 6) {
        Image(systemName: "cloud.bolt.fill")
          .font(.caption2)
        Text(relativeDate)
          .font(.caption2)
          .foregroundStyle(Color.donnerTextSecondary.opacity(0.7))
      }

      Rectangle()
        .fill(
          LinearGradient(
            colors: [
              Color.donnerTextSecondary.opacity(0.3),
              Color.donnerTextSecondary.opacity(0),
            ],
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .frame(height: 1)
    }
    .padding(.horizontal, 8)
  }
}

#Preview {
  ZStack {
    LinearGradient.donnerBackgroundGradient
      .ignoresSafeArea()

    VStack(spacing: 20) {
      Text("Strike 1")
        .foregroundStyle(.white)

      StormDivider(date: Date().addingTimeInterval(-86400))  // Yesterday

      Text("Strike 2")
        .foregroundStyle(.white)

      StormDivider(date: Date().addingTimeInterval(-3600))  // 1 hour ago

      Text("Strike 3")
        .foregroundStyle(.white)
    }
    .padding()
  }
  .preferredColorScheme(.dark)
}
