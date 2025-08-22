import ComposableArchitecture
import SwiftUI

struct IdleView: View {
  let store: StoreOf<LightningFeature>
  @State private var iconRotation = false
  @State private var sparkTrigger = 0
  @State private var iconScale: CGFloat = 1.0
  @State private var showingInfo = false

  var body: some View {
    ZStack {
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

            ElectricSparkEffect(trigger: sparkTrigger)

            Image(systemName: "bolt.fill")
              .font(.system(size: 80))
              .foregroundStyle(LinearGradient.donnerLightningGradient)
              .glow(radius: 20)
              .rotationEffect(.degrees(iconRotation ? 5 : -5))
              .scaleEffect(iconScale)
              .animation(
                .easeInOut(duration: 3).repeatForever(autoreverses: true), value: iconRotation
              )
              .onTapGesture {
                playSparkEffect()
              }
          }

          Text("tap_when_see_lightning")
            .multilineTextAlignment(.center)
            .font(.title3.weight(.medium))
            .foregroundStyle(Color.donnerTextPrimary)
        }

        Button {
          startLightningTracking()
        } label: {
          HStack {
            Image(systemName: "bolt.fill")
              .font(.title2)
            Text("i_saw_flash")
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

      VStack {
        HStack {
          Spacer()
          Button {
            showingInfo = true
          } label: {
            Image(systemName: "info.circle.fill")
              .font(.title2)
              .symbolRenderingMode(.hierarchical)
              .foregroundStyle(Color.donnerTextSecondary)
          }
          .padding()
        }
        Spacer()
      }
    }
    .sheet(isPresented: $showingInfo) {
      InfoView(isPresented: $showingInfo)
    }
  }

  private func playSparkEffect() {
    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    impactFeedback.prepare()
    impactFeedback.impactOccurred()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      impactFeedback.impactOccurred()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      let lightFeedback = UIImpactFeedbackGenerator(style: .light)
      lightFeedback.impactOccurred()
    }

    // Visual effects - increment to always trigger onChange
    sparkTrigger += 1

    withAnimation(.easeInOut(duration: 0.1)) {
      iconScale = 1.2
    }

    withAnimation(.easeInOut(duration: 0.1).delay(0.1)) {
      iconScale = 1.0
    }
  }

  private func startLightningTracking() {
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    impactFeedback.prepare()
    impactFeedback.impactOccurred()

    // Send action to store
    store.send(.lightningButtonTapped)
  }
}
