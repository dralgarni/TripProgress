import CoreLocation
import Foundation

struct TripSession: Codable, Equatable {
    var destination: TripDestination
    var displayMode: TripDisplayMode
    var totalDistance: CLLocationDistance
    var remainingDistance: CLLocationDistance
    var expectedTravelTime: TimeInterval
    var startedAt: Date
    var isActive: Bool
}
