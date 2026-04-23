import Foundation
import CoreLocation


@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {


    var userLocation: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationError: AppError?


    private let manager = CLLocationManager()



    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }


    func requestOnceIfNeeded() {
        guard userLocation == nil else { return }
        manager.requestLocation()
    }

    func centerOnUser() -> CLLocationCoordinate2D? {
        userLocation
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last?.coordinate
        locationError = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let clError = error as? CLError
        switch clError?.code {
        case .denied:
            locationError = .locationPermissionDenied
        default:
            locationError = .locationUnavailable
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            locationError = nil
        case .denied, .restricted:
            locationError = .locationPermissionDenied
        default:
            break
        }
    }
}
