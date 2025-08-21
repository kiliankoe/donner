import ComposableArchitecture
import ComposableCoreLocation

extension DependencyValues {
  var locationManager: LocationManager {
    get { self[LocationManager.self] }
    set { self[LocationManager.self] = newValue }
  }
}

extension LocationManager: DependencyKey {
  public static let liveValue = LocationManager.live
}
