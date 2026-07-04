import MapKit
import SwiftUI

struct DestinationSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DestinationSearchViewModel()

    let onSelect: (TripDestination) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.results, id: \.self) { result in
                    Button {
                        Task {
                            if let item = await viewModel.mapItem(for: result) {
                                onSelect(TripDestination(mapItem: item))
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.title)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.primary)

                            if !result.subtitle.isEmpty {
                                Text(result.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .overlay {
                if viewModel.query.isEmpty {
                    ContentUnavailableView("ابحث عن وجهتك", systemImage: "magnifyingglass", description: Text("اكتب اسم مكان أو عنوان للبدء."))
                } else if viewModel.results.isEmpty && !viewModel.isSearching {
                    ContentUnavailableView("لا توجد نتائج", systemImage: "mappin.slash")
                }
            }
            .navigationTitle("اختيار الوجهة")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "اسم المكان أو العنوان")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") {
                        dismiss()
                    }
                }
            }
        }
    }
}
