import ComposableArchitecture
import SwiftUI

struct RecordingButton: View {
  let store: StoreOf<LightningFeature>
  @State private var sparkTrigger = 0
  @State private var pulseAnimation = false
  @State private var lightningButtonTapped = false

  var body: some View {
    GeometryReader { geometry in
      let buttonSize = min(geometry.size.width, geometry.size.height) * 0.65

      Button {
        lightningButtonTapped.toggle()
        store.send(.lightningButtonTapped)
      } label: {
        ZStack {
          Circle()
            .fill(LinearGradient.donnerButtonGradient)
            .frame(width: buttonSize, height: buttonSize)
            .overlay(
              Circle()
                .stroke(
                  LinearGradient.donnerLightningGradient.opacity(0.3),
                  lineWidth: 2
                )
            )
            .glow(color: .donnerLightningGlow, radius: 30)
            .scaleEffect(pulseAnimation ? 1.02 : 1.0)
            .animation(
              .easeInOut(duration: 2).repeatForever(autoreverses: true),
              value: pulseAnimation
            )

          VStack(spacing: 20) {
            Image(systemName: "bolt.fill")
              .font(.system(size: buttonSize * 0.25))
              .foregroundStyle(.black.opacity(0.8))

            Text("i_saw_flash")
              .font(.system(size: buttonSize * 0.08).weight(.bold))
              .foregroundStyle(.black.opacity(0.8))
          }

          ElectricSparkEffect(trigger: sparkTrigger)
            .scaleEffect(2.5)
        }
      }
      .sensoryFeedback(.warning, trigger: lightningButtonTapped)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .onAppear {
        pulseAnimation = true
      }
    }
  }
}
