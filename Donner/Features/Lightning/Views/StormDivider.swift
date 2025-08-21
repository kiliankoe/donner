import SwiftUI

struct StormDivider: View {
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

      HStack(spacing: 4) {
        Image(systemName: "cloud.bolt.fill")
          .font(.caption2)
        Text("New Storm")
          .font(.caption2)
          .fontWeight(.medium)
      }
      .foregroundStyle(Color.donnerTextSecondary.opacity(0.7))

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

      StormDivider()

      Text("Strike 2")
        .foregroundStyle(.white)
    }
    .padding()
  }
  .preferredColorScheme(.dark)
}
