import Combine
import CoreLocation
import Foundation
import MapKit

@MainActor
final class TripViewModel: ObservableObject {
    @Published var selectedDestination: TripDestination?
    @Published var displayMode: TripDisplayMode = .progress {
        didSet {
            if var session {
                session.displayMode = displayMode
                self.session = session
            }
            persist()
        }
    }
    @Published private(set) var session: TripSession?
    @Published private(set) var isLoadingRoute = false
    @Published private(set) var errorMessage: String?

    let locationManager: LocationManager

    private let routeService: RouteServicing
    private let tripStore: TripStore
    private var lastRouteRefreshDate: Date?
    private var lastRouteRefreshLocation: CLLocation?
    private var locationCancellable: AnyCancellable?

    init(
        locationManager: LocationManager = LocationManager(),
        routeService: RouteServicing = RouteService(),
        tripStore: TripStore = TripStore()
    ) {
        self.locationManager = locationManager
        self.routeService = routeService
        self.tripStore = tripStore

        if let restored = tripStore.load() {
            session = restored
            selectedDestination = restored.destination
            displayMode = restored.displayMode
        }

        observeLocationUpdates()
    }

    var displayedPercent: Int {
        guard let session else { return 0 }
        return TripProgressCalculator.displayedPercent(
            totalDistance: session.totalDistance,
            remainingDistance: session.remainingDistance,
            mode: session.displayMode
        )
    }

    var displayedFraction: Double {
        guard let session else { return 0 }
        return TripProgressCalculator.displayedFraction(
            totalDistance: session.totalDistance,
            remainingDistance: session.remainingDistance,
            mode: session.displayMode
        )
    }

    var remainingDistanceText: String {
        DistanceFormatterService.string(from: session?.remainingDistance ?? 0)
    }

    var etaText: String {
        guard let travelTime = session?.expectedTravelTime, travelTime > 0 else { return "--" }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = travelTime >= 3600 ? [.hour, .minute] : [.minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        return formatter.string(from: travelTime) ?? "--"
    }

    var canStartTrip: Bool {
        selectedDestination != nil && locationManager.currentLocation != nil && !isLoadingRoute
    }

    func requestLocation() {
        locationManager.requestAuthorization()
        locationManager.startUpdating()
    }

    func selectDestination(_ destination: TripDestination) {
        selectedDestination = destination

        if var session {
            session.destination = destination
            self.session = session
            persist()
        }
    }

    func startTrip() async {
        guard let destination = selectedDestination else {
            errorMessage = "اختر وجهة أولًا."
            return
        }

        guard let currentLocation = locationManager.currentLocation else {
            errorMessage = "نحتاج إلى موقعك الحالي قبل بدء الرحلة."
            locationManager.startUpdating()
            return
        }

        await calculateInitialRoute(from: currentLocation, to: destination)
    }

    func stopTrip() {
        if var session {
            session.isActive = false
            self.session = session
        }
        locationManager.stopUpdating()
        persist()
    }

    func clearTrip() {
        session = nil
        selectedDestination = nil
        tripStore.save(nil)
    }

    func clearError() {
        errorMessage = nil
    }

    private func calculateInitialRoute(from currentLocation: CLLocation, to destination: TripDestination) async {
        isLoadingRoute = true
        errorMessage = nil

        do {
            let route = try await routeService.route(from: currentLocation.coordinate, to: destination.coordinate)
            session = TripSession(
                destination: destination,
                displayMode: displayMode,
                totalDistance: route.totalDistance,
                remainingDistance: route.totalDistance,
                expectedTravelTime: route.expectedTravelTime,
                startedAt: Date(),
                isActive: true
            )
            locationManager.startUpdating()
            lastRouteRefreshDate = Date()
            lastRouteRefreshLocation = currentLocation
            persist()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingRoute = false
    }

    private func observeLocationUpdates() {
        locationCancellable = locationManager.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                Task { @MainActor in
                    await self?.refreshRemainingRouteIfNeeded(from: location)
                }
            }
    }

    private func refreshRemainingRouteIfNeeded(from location: CLLocation) async {
        guard let session, session.isActive else { return }

        let movedEnough = lastRouteRefreshLocation.map { location.distance(from: $0) > 25 } ?? true
        let waitedEnough = lastRouteRefreshDate.map { Date().timeIntervalSince($0) > 15 } ?? true

        guard movedEnough || waitedEnough else { return }

        do {
            let route = try await routeService.route(from: location.coordinate, to: session.destination.coordinate)
            var updated = session
            updated.remainingDistance = min(route.totalDistance, updated.totalDistance)
            updated.expectedTravelTime = route.expectedTravelTime
            self.session = updated
            lastRouteRefreshDate = Date()
            lastRouteRefreshLocation = location
            persist()
        } catch {
            updateWithDirectDistanceFallback(from: location)
        }
    }

    private func updateWithDirectDistanceFallback(from location: CLLocation) {
        guard var session else { return }

        let destinationLocation = CLLocation(
            latitude: session.destination.latitude,
            longitude: session.destination.longitude
        )
        session.remainingDistance = min(location.distance(from: destinationLocation), session.totalDistance)
        self.session = session
        persist()
    }

    private func persist() {
        tripStore.save(session)
    }
}
