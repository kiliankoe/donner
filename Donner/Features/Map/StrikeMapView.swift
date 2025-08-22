import CoreLocation
import MapKit
import SwiftUI

struct StrikeMapView: View {
  let strikes: [Strike]
  @Environment(\.dismiss) private var dismiss

  @State private var region: MKCoordinateRegion

  init(strikes: [Strike]) {
    self.strikes = strikes

    // Calculate region to show all strikes
    let strikesWithLocation = strikes.filter { $0.estimatedStrikeLocation != nil }

    if !strikesWithLocation.isEmpty {
      let locations = strikesWithLocation.compactMap { $0.estimatedStrikeLocation }
      let userLocations = strikesWithLocation.compactMap { $0.userLocation }
      let allLocations = locations + userLocations

      let minLat = allLocations.map { $0.coordinate.latitude }.min() ?? 0
      let maxLat = allLocations.map { $0.coordinate.latitude }.max() ?? 0
      let minLon = allLocations.map { $0.coordinate.longitude }.min() ?? 0
      let maxLon = allLocations.map { $0.coordinate.longitude }.max() ?? 0

      let centerLat = (minLat + maxLat) / 2
      let centerLon = (minLon + maxLon) / 2
      let latDelta = (maxLat - minLat) * 1.5
      let lonDelta = (maxLon - minLon) * 1.5

      self._region = State(
        initialValue: MKCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
          span: MKCoordinateSpan(
            latitudeDelta: max(latDelta, 0.05),
            longitudeDelta: max(lonDelta, 0.05)
          )
        ))
    } else {
      // Default region if no strikes with location
      self._region = State(
        initialValue: MKCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
          span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        ))
    }
  }

  private var strikesWithLocation: [Strike] {
    strikes.filter { $0.estimatedStrikeLocation != nil }
      .sorted(by: { $0.lightningTime < $1.lightningTime })
  }

  private var latestStrike: Strike? {
    strikesWithLocation.last
  }

  private var strikeText: String {
    let count = strikesWithLocation.count
    let strikeWord =
      count == 1
      ? NSLocalizedString("strike_singular", comment: "Singular strike")
      : NSLocalizedString("strikes_plural", comment: "Plural strikes")
    let recorded = NSLocalizedString("recorded", comment: "Recorded")

    if let firstStrike = strikesWithLocation.first,
      let lastStrike = strikesWithLocation.last,
      count > 1
    {
      let duration = lastStrike.lightningTime.timeIntervalSince(firstStrike.lightningTime)
      let minutes = Int(duration / 60)
      if minutes > 0 {
        return String(
          format: NSLocalizedString(
            "strikes_with_duration", comment: "Strike count with storm duration"),
          count, strikeWord, minutes
        )
      }
    }

    return "\(count) \(strikeWord) \(recorded)"
  }

  var body: some View {
    ZStack {
      // Using MapKit's UIViewRepresentable for better control
      StrikeMapRepresentable(
        strikes: strikesWithLocation,
        region: region
      )
      .ignoresSafeArea()

      // Header overlay
      VStack {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("storm_track")
              .font(.title2.weight(.bold))
              .foregroundStyle(Color.donnerTextPrimary)

            Text(strikeText)
              .font(.subheadline)
              .foregroundStyle(Color.donnerTextSecondary)
          }

          Spacer()

          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark.circle.fill")
              .font(.largeTitle)
              .foregroundStyle(Color.donnerTextSecondary, Color.donnerCardBackground)
          }
        }
        .padding()
        .background(
          LinearGradient(
            colors: [
              Color.donnerDarkBackground.opacity(0.95),
              Color.donnerDarkBackground.opacity(0),
            ],
            startPoint: .top,
            endPoint: .bottom
          )
        )

        Spacer()

        // Legend
        HStack(spacing: 20) {
          HStack(spacing: 8) {
            Circle()
              .fill(Color.donnerLightning)
              .frame(width: 12, height: 12)
              .glow(color: .donnerLightningGlow, radius: 4)
            Text("latest_strike")
              .font(.caption)
              .foregroundStyle(Color.donnerTextPrimary)
          }

          HStack(spacing: 8) {
            Circle()
              .fill(Color.donnerLightning.opacity(0.6))
              .frame(width: 10, height: 10)
            Text("previous")
              .font(.caption)
              .foregroundStyle(Color.donnerTextPrimary)
          }

          HStack(spacing: 8) {
            Image(systemName: "location.fill")
              .font(.caption)
              .foregroundStyle(Color.blue)
            Text("your_location")
              .font(.caption)
              .foregroundStyle(Color.donnerTextPrimary)
          }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.donnerCardBackground.opacity(0.9))
        .clipShape(Capsule())
        .padding(.bottom, 30)
      }
    }
  }
}

struct StrikeMapRepresentable: UIViewRepresentable {
  let strikes: [Strike]
  let region: MKCoordinateRegion

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.overrideUserInterfaceStyle = .dark
    mapView.delegate = context.coordinator
    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    mapView.setRegion(region, animated: false)

    mapView.removeAnnotations(mapView.annotations)
    mapView.removeOverlays(mapView.overlays)

    // Add strike annotations
    for (index, strike) in strikes.enumerated() {
      if let location = strike.estimatedStrikeLocation {
        let annotation = StrikeAnnotation(
          coordinate: location.coordinate,
          strike: strike,
          isLatest: index == strikes.count - 1
        )
        mapView.addAnnotation(annotation)
      }

      if let userLocation = strike.userLocation {
        let userAnnotation = UserAnnotation(
          coordinate: userLocation.coordinate,
          strike: strike
        )
        mapView.addAnnotation(userAnnotation)
      }
    }

    // Add storm path
    let strikeCoordinates = strikes.compactMap { $0.estimatedStrikeLocation?.coordinate }
    if strikeCoordinates.count > 1 {
      let polyline = MKPolyline(coordinates: strikeCoordinates, count: strikeCoordinates.count)
      mapView.addOverlay(polyline)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  class Coordinator: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      if let strikeAnnotation = annotation as? StrikeAnnotation {
        let identifier = "StrikePin"
        let annotationView =
          mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
          ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)

        // Create custom view for strike
        let pinView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))

        let iconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        iconView.image = UIImage(systemName: "bolt.fill")
        iconView.tintColor =
          strikeAnnotation.isLatest ? .systemYellow : .systemYellow.withAlphaComponent(0.6)
        iconView.contentMode = .scaleAspectFit

        let backgroundView = UIView(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        backgroundView.layer.cornerRadius = 15
        backgroundView.layer.borderWidth = 2
        backgroundView.layer.borderColor =
          strikeAnnotation.isLatest
          ? UIColor.systemYellow.withAlphaComponent(0.8).cgColor
          : UIColor.systemYellow.withAlphaComponent(0.4).cgColor

        pinView.addSubview(backgroundView)
        pinView.addSubview(iconView)

        if strikeAnnotation.isLatest {
          // Add glow effect for latest
          let glowView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
          glowView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)
          glowView.layer.cornerRadius = 20
          glowView.layer.shadowColor = UIColor.systemYellow.cgColor
          glowView.layer.shadowRadius = 10
          glowView.layer.shadowOpacity = 0.5
          glowView.layer.shadowOffset = .zero
          pinView.insertSubview(glowView, at: 0)

          annotationView.canShowCallout = true
        }

        annotationView.addSubview(pinView)
        annotationView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

        return annotationView
      } else if annotation is UserAnnotation {
        let identifier = "UserPin"
        let annotationView =
          mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
          ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)

        let pinView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))

        let iconView = UIImageView(frame: CGRect(x: 7.5, y: 7.5, width: 15, height: 15))
        iconView.image = UIImage(systemName: "location.fill")
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit

        let backgroundView = UIView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.borderWidth = 1.5
        backgroundView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.8).cgColor

        pinView.addSubview(backgroundView)
        pinView.addSubview(iconView)

        annotationView.addSubview(pinView)
        annotationView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)

        return annotationView
      }

      return nil
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      if let polyline = overlay as? MKPolyline {
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.systemYellow.withAlphaComponent(0.6)
        renderer.lineWidth = 3
        renderer.lineDashPattern = [5, 5]
        return renderer
      }
      return MKOverlayRenderer(overlay: overlay)
    }
  }
}

class StrikeAnnotation: NSObject, MKAnnotation {
  let coordinate: CLLocationCoordinate2D
  let strike: Strike
  let isLatest: Bool

  var title: String? {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: strike.lightningTime)
  }

  var subtitle: String? {
    if let distance = strike.distanceInKilometers {
      return String(
        format: NSLocalizedString("km_away", comment: "Distance format"), distance)
    }
    return nil
  }

  init(coordinate: CLLocationCoordinate2D, strike: Strike, isLatest: Bool) {
    self.coordinate = coordinate
    self.strike = strike
    self.isLatest = isLatest
  }
}

class UserAnnotation: NSObject, MKAnnotation {
  let coordinate: CLLocationCoordinate2D
  let strike: Strike

  init(coordinate: CLLocationCoordinate2D, strike: Strike) {
    self.coordinate = coordinate
    self.strike = strike
  }
}
