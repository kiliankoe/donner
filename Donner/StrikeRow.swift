import SwiftUI
import CoreLocation
import MapKit
import ComposableArchitecture
import TipKit

struct StrikeRow: View {
    let strike: Strike
    let store: StoreOf<LightningFeature>
    
    private let directionTip = DirectionRecordingTip()
    
    @State private var distanceFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter
    }()
    
    @State private var shortDistanceFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
    
    private var primaryDistanceText: String {
        guard let distance = strike.distance else { return "-" }
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        
        let locale = Locale.current
        if locale.measurementSystem == .metric {
            return distanceFormatter.string(from: measurement.converted(to: .kilometers))
        } else {
            return distanceFormatter.string(from: measurement.converted(to: .miles))
        }
    }
    
    private var secondaryDistanceText: String {
        guard let distance = strike.distance else { return "-" }
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        
        let locale = Locale.current
        if locale.measurementSystem == .metric {
            return shortDistanceFormatter.string(from: measurement)
        } else {
            return shortDistanceFormatter.string(from: measurement.converted(to: .yards))
        }
    }
    
    private var durationText: String {
        guard let duration = strike.duration else { return "-" }
        return String(format: "%.1f s", duration)
    }
    
    private var hasLocation: Bool {
        strike.estimatedStrikeLocation != nil
    }
    
    private var isRecentStrike: Bool {
        Date().timeIntervalSince(strike.lightningTime) < 300
    }

    var body: some View {
        ZStack {
            if let strikeLocation = strike.estimatedStrikeLocation,
               let userLocation = strike.userLocation {
                StrikeMapBackground(
                    strikeLocation: strikeLocation,
                    userLocation: userLocation
                )
                .opacity(0.3)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.caption)
                            .foregroundStyle(LinearGradient.donnerLightningGradient)
                        
                        Text(strike.lightningTime, format: .dateTime.hour().minute().second())
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(Color.donnerTextPrimary)
                        
                        if hasLocation {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.donnerAccent)
                        }
                    }

                    if strike.distance != nil {
                        HStack(spacing: 8) {
                            Text(primaryDistanceText)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.donnerAccent)

                            Text("·")
                                .foregroundStyle(Color.donnerTextSecondary)

                            Text(durationText)
                                .font(.subheadline)
                                .foregroundStyle(Color.donnerTextSecondary)
                        }
                    }
                }

                Spacer()
                
                HStack(spacing: 12) {
                    if !hasLocation && strike.distance != nil {
                        Button {
                            store.send(.recordHeadingForStrike(strike.id))
                            directionTip.invalidate(reason: .actionPerformed)
                        } label: {
                            Image(systemName: "location.north.line.fill")
                                .font(.title3)
                                .foregroundStyle(LinearGradient.donnerLightningGradient)
                                .padding(8)
                                .background(Color.donnerCardBackground.opacity(0.5))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.donnerLightningGlow.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .popoverTip(directionTip, arrowEdge: .trailing)
                    }
                    
                    if strike.distance != nil {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(secondaryDistanceText.components(separatedBy: " ").first ?? "-")
                                .font(.title2.monospacedDigit().weight(.bold))
                                .foregroundStyle(LinearGradient.donnerLightningGradient)
                            Text(secondaryDistanceText.components(separatedBy: " ").last ?? "")
                                .font(.caption2)
                                .foregroundStyle(Color.donnerTextSecondary)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(hasLocation ? Color.donnerCardBackground.opacity(0.9) : Color.donnerCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(hasLocation ? Color.donnerLightningGlow.opacity(0.3) : Color.donnerLightningGlow.opacity(0.1), lineWidth: 1)
        )
    }
}

struct StrikeMapBackground: View {
    let strikeLocation: CLLocation
    let userLocation: CLLocation
    
    @State private var region: MKCoordinateRegion
    
    init(strikeLocation: CLLocation, userLocation: CLLocation) {
        self.strikeLocation = strikeLocation
        self.userLocation = userLocation
        
        // Calculate region to show both points
        let midLat = (strikeLocation.coordinate.latitude + userLocation.coordinate.latitude) / 2
        let midLon = (strikeLocation.coordinate.longitude + userLocation.coordinate.longitude) / 2
        let latDelta = abs(strikeLocation.coordinate.latitude - userLocation.coordinate.latitude) * 2.5
        let lonDelta = abs(strikeLocation.coordinate.longitude - userLocation.coordinate.longitude) * 2.5
        
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: midLat, longitude: midLon),
            span: MKCoordinateSpan(
                latitudeDelta: max(latDelta, 0.01),
                longitudeDelta: max(lonDelta, 0.01)
            )
        ))
    }
    
    var body: some View {
        Map(coordinateRegion: .constant(region), annotationItems: [
            MapAnnotation(coordinate: strikeLocation.coordinate, type: .strike),
            MapAnnotation(coordinate: userLocation.coordinate, type: .user)
        ]) { item in
            MapMarker(coordinate: item.coordinate, tint: item.type == .strike ? .yellow : .blue)
        }
        .allowsHitTesting(false)
        .colorScheme(.dark)
    }
}

struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let type: AnnotationType
    
    enum AnnotationType {
        case strike
        case user
    }
}
