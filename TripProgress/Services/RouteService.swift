import CoreLocation
import Foundation
import MapKit

enum RouteServiceError: LocalizedError {
    case noRoute

    var errorDescription: String? {
        switch self {
        case .noRoute:
            return "تعذر حساب المسار لهذه الوجهة."
        }
    }
}

protocol RouteServicing {
    func route(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) async throws -> RouteSummary
}

final class RouteService: RouteServicing {
    func route(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) async throws -> RouteSummary {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        request.requestsAlternateRoutes = false

        let response = try await MKDirections(request: request).calculate()
        guard let route = response.routes.first else {
            throw RouteServiceError.noRoute
        }

        return RouteSummary(totalDistance: route.distance, expectedTravelTime: route.expectedTravelTime)
    }
}
