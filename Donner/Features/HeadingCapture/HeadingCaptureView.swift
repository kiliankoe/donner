import SwiftUI
import ComposableArchitecture
import CoreLocation

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
                    Image(systemName: "location.north.line.fill")
                        .font(.largeTitle)
                        .foregroundStyle(LinearGradient.donnerLightningGradient)
                        .glow()

                    Text("Point Toward Lightning")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.donnerTextPrimary)

                    Text("Hold your device steady and aim it in the direction where you saw the lightning strike")
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
                    Circle()
                        .fill(LinearGradient.donnerLightningGradient)
                        .frame(width: 20, height: 20)
                        .offset(y: -110)
                        .rotationEffect(.degrees(store.currentHeading))
                        #if targetEnvironment(simulator)
                        .opacity(0.8)
                        #endif
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: store.currentHeading)

                    // Center compass
                    VStack(spacing: 8) {
                        Text("\(Int(store.currentHeading))°")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundStyle(LinearGradient.donnerLightningGradient)

                        Text(compassDirection(from: store.currentHeading))
                            .font(.headline)
                            .foregroundStyle(Color.donnerTextSecondary)
                    }

                    // Cardinal directions
                    ForEach(["N", "E", "S", "W"], id: \.self) { direction in
                        Text(direction)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(direction == "N" ? Color.donnerLightning : Color.donnerTextSecondary)
                            .offset(y: direction == "N" || direction == "S" ? (direction == "N" ? -140 : 140) : 0)
                            .offset(x: direction == "E" || direction == "W" ? (direction == "E" ? 140 : -140) : 0)
                    }
                }

                // Strike info
                VStack(spacing: 8) {
                    if let distance = store.strike.distanceInKilometers {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundStyle(Color.donnerLightning)
                            Text(String(format: "%.1f km away", distance))
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
                        Text("Cancel")
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
                            Text("Record")
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
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((degrees + 22.5) / 45.0) % 8
        return directions[index]
    }
}
