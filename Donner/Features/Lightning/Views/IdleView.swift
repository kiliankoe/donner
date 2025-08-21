import ComposableArchitecture
import SwiftUI

struct IdleView: View {
  let store: StoreOf<LightningFeature>
  @State private var iconRotation = false

  var body: some View {
    VStack(spacing: 32) {
      VStack(spacing: 20) {
        ZStack {
          Circle()
            .fill(
              RadialGradient(
                colors: [
                  Color.donnerLightningGlow.opacity(0.3),
                  Color.donnerLightningGlow.opacity(0.1),
                  Color.clear,
                ],
                center: .center,
                startRadius: 20,
                endRadius: 80
              )
            )
            .frame(width: 160, height: 160)
            .blur(radius: 10)

          Image(systemName: "bolt.fill")
            .font(.system(size: 80))
            .foregroundStyle(LinearGradient.donnerLightningGradient)
            .glow(radius: 20)
            .rotationEffect(.degrees(iconRotation ? 5 : -5))
            .animation(
              .easeInOut(duration: 3).repeatForever(autoreverses: true), value: iconRotation)
        }

        Text("Tap when you see lightning")
          .font(.title3.weight(.medium))
          .foregroundStyle(Color.donnerTextPrimary)
      }

      Button {
        store.send(.lightningButtonTapped)
      } label: {
        HStack {
          Image(systemName: "bolt.fill")
            .font(.title2)
          Text("Lightning Seen")
            .font(.title3.weight(.semibold))
        }
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(LinearGradient.donnerButtonGradient)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .glow(color: .donnerLightningGlow, radius: 10)
      }
    }
    .padding(.horizontal, 24)
    .onAppear {
      iconRotation = true
    }
  }
}
