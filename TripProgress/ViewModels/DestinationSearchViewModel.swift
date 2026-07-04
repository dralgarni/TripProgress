import Foundation
import MapKit

@MainActor
final class DestinationSearchViewModel: NSObject, ObservableObject {
    @Published var query = "" {
        didSet { completer.queryFragment = query }
    }
    @Published private(set) var results: [MKLocalSearchCompletion] = []
    @Published private(set) var isSearching = false
    @Published var errorMessage: String?

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func mapItem(for completion: MKLocalSearchCompletion) async -> MKMapItem? {
        isSearching = true
        defer { isSearching = false }

        let request = MKLocalSearch.Request(completion: completion)

        do {
            let response = try await MKLocalSearch(request: request).start()
            return response.mapItems.first
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}

extension DestinationSearchViewModel: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            self.results = completer.results
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
        }
    }
}
