import CoreLocation
import Foundation
import MapKit

struct TripDestination: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var subtitle: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees

    init(id: UUID = UUID(), name: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension TripDestination {
    init(mapItem: MKMapItem) {
        let placemark = mapItem.placemark
        self.init(
            name: mapItem.name ?? placemark.title ?? "وجهة بدون اسم",
            subtitle: placemark.title ?? "",
            coordinate: placemark.coordinate
        )
    }
}
