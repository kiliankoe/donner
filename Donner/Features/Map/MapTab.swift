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
            item.strike.lightningTime.formatted(
              .dateTime.month(.abbreviated).day().hour().minute()),
            coordinate: item.coordinate
          ) {
            ZStack {
              Circle()
                .fill(
                  Color(
                    red: item.storm.color.red,
                    green: item.storm.color.green,
                    blue: item.storm.color.blue
                  ).opacity(item.storm.opacity)
                )
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
