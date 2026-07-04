import Foundation

enum TripDisplayMode: String, Codable, CaseIterable, Identifiable {
    case progress
    case countdown

    var id: String { rawValue }

    var title: String {
        switch self {
        case .progress:
            return "تصاعدي"
        case .countdown:
            return "تنازلي"
        }
    }
}
