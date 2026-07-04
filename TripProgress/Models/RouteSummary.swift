import CoreLocation
import Foundation

struct RouteSummary: Equatable {
    var totalDistance: CLLocationDistance
    var expectedTravelTime: TimeInterval
}
