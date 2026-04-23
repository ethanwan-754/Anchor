import Foundation
import CoreLocation


struct GeocodingService {

  
    static func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> ReverseGeocodeResult {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

      
        let placemarks = try await geocoder.reverseGeocodeLocation(location)

        guard let placemark = placemarks.first else {
            throw AppError.geocodingFailed
        }

        return ReverseGeocodeResult(from: placemark)
    }
}



struct ReverseGeocodeResult {
    let locality: String?
    let subLocality: String?
    let thoroughfare: String?
    let administrativeArea: String?
    let country: String?
    let areasOfInterest: [String]
    let ocean: String?
    let inlandWater: String?

    var shortAddress: String {
        [subLocality ?? thoroughfare, locality]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    var detectedEnvironment: AnchorEnvironment {
        let tokens = [
            locality, subLocality, thoroughfare,
            ocean, inlandWater,
            areasOfInterest.joined(separator: " ")
        ].compactMap { $0 }
        return AnchorEnvironment.detect(from: tokens)
    }

    init(from placemark: CLPlacemark) {
        self.locality             = placemark.locality
        self.subLocality          = placemark.subLocality
        self.thoroughfare         = placemark.thoroughfare
        self.administrativeArea   = placemark.administrativeArea
        self.country              = placemark.country
        self.areasOfInterest      = placemark.areasOfInterest ?? []
        self.ocean                = placemark.ocean
        self.inlandWater          = placemark.inlandWater
    }
}
