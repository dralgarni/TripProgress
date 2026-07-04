import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TripViewModel()
    @State private var isShowingDestinationSearch = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    destinationSection
                    modePicker
                    progressSection
                    metricGrid
                    actionButtons
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("عداد المشوار")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingDestinationSearch) {
                DestinationSearchView { destination in
                    viewModel.selectDestination(destination)
                    isShowingDestinationSearch = false
                }
            }
            .alert("تنبيه", isPresented: errorBinding) {
                Button("حسنًا", role: .cancel) {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onAppear {
                viewModel.requestLocation()
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding {
            viewModel.errorMessage != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.clearError()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("حوّل رحلتك إلى نسبة واضحة")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text("اختر الوجهة، ابدأ الرحلة، وتابع مقدار ما أنجزته من الطريق بدون خريطة مزدحمة.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var destinationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("الوجهة")
                .font(.headline)

            Button {
                isShowingDestinationSearch = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title3)
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.selectedDestination?.name ?? "اختر وجهة")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(viewModel.selectedDestination?.subtitle ?? "ابحث عن مكان أو عنوان")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()
                    Image(systemName: "chevron.left")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }

    private var modePicker: some View {
        Picker("وضع العرض", selection: $viewModel.displayMode) {
            ForEach(TripDisplayMode.allCases) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private var progressSection: some View {
        VStack(spacing: 18) {
            ProgressRingView(fraction: viewModel.displayedFraction)
                .frame(width: 220, height: 220)

            VStack(spacing: 4) {
                Text("\(viewModel.displayedPercent)%")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Text(viewModel.displayMode == .progress ? "نسبة الوصول" : "المتبقي حتى الوصول")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    private var metricGrid: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                MetricTile(title: "المسافة المتبقية", value: viewModel.remainingDistanceText, systemImage: "road.lanes")
                MetricTile(title: "وقت الوصول المتوقع", value: viewModel.etaText, systemImage: "clock")
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task { await viewModel.startTrip() }
            } label: {
                Label(viewModel.isLoadingRoute ? "جاري حساب المسار" : "بدء الرحلة", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.canStartTrip)

            HStack(spacing: 12) {
                Button {
                    viewModel.stopTrip()
                } label: {
                    Label("إيقاف", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(viewModel.session?.isActive != true)

                Button(role: .destructive) {
                    viewModel.clearTrip()
                } label: {
                    Label("مسح", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(viewModel.session == nil && viewModel.selectedDestination == nil)
            }
        }
    }
}

#Preview {
    ContentView()
}
