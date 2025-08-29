import ComposableArchitecture
import CoreLocation
import MapKit
import SwiftUI

struct MapTab: View {
  let store: StoreOf<LightningFeature>
  @State private var position = MapCameraPosition.automatic
  @State private var selectedStrike: Strike?

  var body: some View {
    ZStack {
      Map(position: $position, selection: $selectedStrike) {
        ForEach(allAnnotations) { item in
          Annotation(
            item.strike.lightningTime.formatted(.dateTime.hour().minute()),
            coordinate: item.coordinate
          ) {
            ZStack {
              Circle()
                .fill(Color(
                  red: item.storm.color.red,
                  green: item.storm.color.green,
                  blue: item.storm.color.blue
                ).opacity(item.storm.opacity))
                .frame(width: 30, height: 30)
              
              Image(systemName: "bolt.fill")
                .font(.system(size: 16))
                .foregroundStyle(.white)
            }
            .onTapGesture {
              withAnimation {
                selectedStrike = item.strike
              }
            }
          }
          .tag(item.strike)
        }
      }
      .mapStyle(.standard(elevation: .realistic))
      .mapControls {
        MapUserLocationButton()
        MapCompass()
        MapScaleView()
      }
      .onAppear {
        setupInitialRegion()
      }

      VStack {
        HStack {
          StormLegend()
            .padding()

          Spacer()
        }

        Spacer()
        
        if let selected = selectedStrike {
          StrikeDetailCallout(strike: selected) {
            withAnimation {
              selectedStrike = nil
            }
          }
          .padding()
          .transition(.move(edge: .bottom).combined(with: .opacity))
        }
      }

      if store.strikes.isEmpty {
        VStack(spacing: 16) {
          RoundedRectangle(cornerRadius: 16)
            .fill(Color.donnerCardBackground)
            .frame(width: 280, height: 140)
            .overlay(
              VStack(spacing: 12) {
                Image(systemName: "map.fill")
                  .font(.largeTitle)
                  .foregroundStyle(Color.donnerTextSecondary.opacity(0.5))

                Text("no_storms_recorded")
                  .font(.headline)
                  .foregroundStyle(Color.donnerTextSecondary)

                Text("record_strikes_to_see_map")
                  .font(.caption)
                  .foregroundStyle(Color.donnerTextSecondary.opacity(0.7))
                  .multilineTextAlignment(.center)
              }
              .padding()
            )
        }
      }
    }
    .preferredColorScheme(.dark)
  }

  private struct AnnotationItem: Identifiable {
    let id = UUID()
    let strike: Strike
    let storm: MapFeature.State.Storm
    var coordinate: CLLocationCoordinate2D {
      guard let location = strike.estimatedStrikeLocation else {
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
      }
      return location.coordinate
    }
  }

  private var allAnnotations: [AnnotationItem] {
    let mapState = MapFeature.State(strikes: store.strikes)
    var items: [AnnotationItem] = []

    for storm in mapState.storms {
      for strike in storm.strikes {
        if strike.estimatedStrikeLocation != nil {
          items.append(AnnotationItem(strike: strike, storm: storm))
        }
      }
    }

    return items
  }

  private func setupInitialRegion() {
    // If we have strikes with locations, center the map on them
    let strikesWithLocation = store.strikes.filter { $0.estimatedStrikeLocation != nil }

    if !strikesWithLocation.isEmpty {
      let locations = strikesWithLocation.compactMap { $0.estimatedStrikeLocation }

      var minLat = locations[0].coordinate.latitude
      var maxLat = locations[0].coordinate.latitude
      var minLon = locations[0].coordinate.longitude
      var maxLon = locations[0].coordinate.longitude

      for location in locations {
        minLat = min(minLat, location.coordinate.latitude)
        maxLat = max(maxLat, location.coordinate.latitude)
        minLon = min(minLon, location.coordinate.longitude)
        maxLon = max(maxLon, location.coordinate.longitude)
      }

      let center = CLLocationCoordinate2D(
        latitude: (minLat + maxLat) / 2,
        longitude: (minLon + maxLon) / 2
      )

      let span = MKCoordinateSpan(
        latitudeDelta: max(0.01, (maxLat - minLat) * 1.5),
        longitudeDelta: max(0.01, (maxLon - minLon) * 1.5)
      )

      position = .region(MKCoordinateRegion(center: center, span: span))
    } else {
      position = .userLocation(fallback: .automatic)
    }
  }
}

struct StrikeMarker: View {
  let strike: Strike
  let storm: MapFeature.State.Storm
  let isSelected: Bool

  var body: some View {
    ZStack {
      // Connection line to previous strike in same storm
      if let previousStrike = previousStrikeInStorm {
        ConnectionLine(
          from: strike.estimatedStrikeLocation!,
          to: previousStrike.estimatedStrikeLocation!,
          opacity: storm.opacity
        )
      }

      // Strike marker
      Circle()
        .fill(
          Color(
            red: storm.color.red,
            green: storm.color.green,
            blue: storm.color.blue
          ).opacity(storm.opacity)
        )
        .frame(width: 20, height: 20)
        .overlay(
          Image(systemName: "bolt.fill")
            .font(.caption2)
            .foregroundStyle(.black.opacity(0.7))
        )
        .overlay(
          Circle()
            .stroke(Color.white.opacity(storm.opacity * 0.8), lineWidth: 2)
        )
    }
  }

  private var previousStrikeInStorm: Strike? {
    guard let index = storm.strikes.firstIndex(where: { $0.id == strike.id }),
      index > 0
    else { return nil }

    // Find the previous strike with location data
    for i in (0..<index).reversed() {
      if storm.strikes[i].estimatedStrikeLocation != nil {
        return storm.strikes[i]
      }
    }

    return nil
  }
}

struct ConnectionLine: View {
  let from: CLLocation
  let to: CLLocation
  let opacity: Double

  var body: some View {
    GeometryReader { geometry in
      Path { path in
        // This is a simplified representation
        // In a real implementation, you'd need to convert coordinates properly
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 10, y: 10))
      }
      .stroke(
        Color.donnerLightning.opacity(opacity * 0.5),
        style: StrokeStyle(lineWidth: 1, dash: [5, 3])
      )
    }
  }
}

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

struct StrikeDetailCallout: View {
  let strike: Strike
  let onDismiss: () -> Void
  
  var body: some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Image(systemName: "bolt.fill")
            .font(.title2)
            .foregroundStyle(Color.donnerLightning)
          
          VStack(alignment: .leading) {
            Text(strike.lightningTime.formatted(.dateTime.weekday(.wide).month().day()))
              .font(.headline)
              .foregroundStyle(Color.donnerTextPrimary)
            
            Text(strike.lightningTime.formatted(.dateTime.hour().minute().second()))
              .font(.subheadline)
              .foregroundStyle(Color.donnerTextSecondary)
          }
        }
        
        if let distance = strike.distance {
          HStack(spacing: 4) {
            Image(systemName: "location.circle.fill")
              .font(.caption)
              .foregroundStyle(Color.donnerTextSecondary)
            
            let measurement = Measurement(value: distance, unit: UnitLength.meters)
            Text("\(MeasurementFormatter.distance.string(from: measurement)) \(Text("strike_distance_away", bundle: .main))")
              .font(.caption.monospacedDigit())
              .foregroundStyle(Color.donnerTextPrimary)
          }
        }
        
        if let duration = strike.duration {
          HStack(spacing: 4) {
            Image(systemName: "timer")
              .font(.caption)
              .foregroundStyle(Color.donnerTextSecondary)
            
            let measurement = Measurement(value: duration, unit: UnitDuration.seconds)
            Text(MeasurementFormatter.duration.string(from: measurement))
              .font(.caption.monospacedDigit())
              .foregroundStyle(Color.donnerTextPrimary)
          }
        }
      }
      
      Spacer()
      
      Button(action: onDismiss) {
        Image(systemName: "xmark.circle.fill")
          .font(.title2)
          .foregroundStyle(Color.donnerTextSecondary)
      }
    }
    .padding()
    .background(Color.donnerCardBackground.opacity(0.95))
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(radius: 10)
  }
}
