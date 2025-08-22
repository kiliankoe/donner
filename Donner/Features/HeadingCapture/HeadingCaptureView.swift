import ComposableArchitecture
import CoreLocation
import SwiftUI

struct HeadingCaptureView: View {
  @Bindable var store: StoreOf<HeadingCaptureFeature>
  let onRecordHeading: (Double, CLLocation) -> Void
  let onCancel: () -> Void

  private var canRecord: Bool {
    #if targetEnvironment(simulator)
      // In simulator, only need location
      return store.userLocation != nil
    #else
      // On device, need both location and calibration
      return store.userLocation != nil && store.isCalibrated
    #endif
  }

  var body: some View {
    ZStack {
      LinearGradient.donnerBackgroundGradient
        .ignoresSafeArea()

      VStack(spacing: 32) {
        VStack(spacing: 12) {
          Text("point_toward_lightning")
            .font(.title2.weight(.semibold))
            .foregroundStyle(Color.donnerTextPrimary)

          Text("heading_capture_instruction")
            .font(.subheadline)
            .foregroundStyle(Color.donnerTextSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }

        // Compass
        ZStack {
          // Outer ring
          Circle()
            .stroke(Color.donnerCardBackground, lineWidth: 2)
            .frame(width: 240, height: 240)

          // Direction indicator
          Image(systemName: "location.north.fill")
            .foregroundStyle(LinearGradient.donnerLightningGradient)
            .glow()
            .font(.system(size: 30))
            .offset(y: -95)

          // Center heading label
          VStack(spacing: 8) {
            Text("\(Int(store.currentHeading))°")
              .font(.system(size: 48, weight: .bold, design: .monospaced))
              .foregroundStyle(LinearGradient.donnerLightningGradient)

            Text(compassDirection(from: store.currentHeading))
              .font(.headline)
              .foregroundStyle(Color.donnerTextSecondary)
          }

          // Cardinal directions
          ForEach(
            [
              ("compass_n", "N", 0, -140),
              ("compass_e", "E", 140, 0),
              ("compass_s", "S", 0, 140),
              ("compass_w", "W", -140, 0),
            ], id: \.1
          ) { key, defaultValue, xOffset, yOffset in
            Text(NSLocalizedString(key, comment: defaultValue))
              .font(.headline.weight(.bold))
              .foregroundStyle(
                defaultValue == "N" ? Color.donnerLightning : Color.donnerTextSecondary
              )
              .rotationEffect(.degrees(-store.currentHeading))
              .offset(x: xOffset, y: yOffset)
          }
          .rotationEffect(.degrees(store.currentHeading))
          .animation(.spring(response: 0.5, dampingFraction: 0.8), value: store.currentHeading)
        }

        // Strike info
        VStack(spacing: 8) {
          if let distance = store.strike.distanceInKilometers {
            HStack {
              Image(systemName: "bolt.fill")
                .foregroundStyle(Color.donnerLightning)
              Text(
                String(
                  format: NSLocalizedString("km_away", comment: "Distance format"),
                  distance)
              )
              .font(.subheadline)
              .foregroundStyle(Color.donnerTextSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.donnerCardBackground)
            .clipShape(Capsule())
          }
        }

        // Action buttons
        HStack(spacing: 16) {
          Button {
            store.send(.cancelButtonTapped)
            onCancel()
          } label: {
            Text("cancel")
              .font(.headline)
              .foregroundStyle(Color.donnerTextPrimary)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.donnerCardBackground)
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }

          Button {
            if let location = store.userLocation {
              onRecordHeading(store.currentHeading, location)
              store.send(.recordButtonTapped)
            }
          } label: {
            HStack {
              Image(systemName: "checkmark.circle.fill")
              Text("record")
            }
            .font(.headline)
            .foregroundStyle(Color.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(LinearGradient.donnerButtonGradient)
            .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          .disabled(!canRecord)
          .opacity(canRecord ? 1.0 : 0.5)
        }
        .padding(.horizontal)
      }
      .padding()
    }
    .onAppear {
      store.send(.onAppear)
    }
    .onDisappear {
      store.send(.onDisappear)
    }
  }

  private func compassDirection(from degrees: Double) -> String {
    let directions = [
      NSLocalizedString("compass_n", comment: "North"),
      NSLocalizedString("compass_ne", comment: "Northeast"),
      NSLocalizedString("compass_e", comment: "East"),
      NSLocalizedString("compass_se", comment: "Southeast"),
      NSLocalizedString("compass_s", comment: "South"),
      NSLocalizedString("compass_sw", comment: "Southwest"),
      NSLocalizedString("compass_w", comment: "West"),
      NSLocalizedString("compass_nw", comment: "Northwest"),
    ]
    let index = Int((degrees + 22.5) / 45.0) % 8
    return directions[index]
  }
}
