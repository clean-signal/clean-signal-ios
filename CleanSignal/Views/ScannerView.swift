import SwiftUI

struct ScannerView: View {
    @State private var scannedProduct: Product?
    @State private var structuredIngredients: [StructuredIngredient] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var lastScannedBarcode: String?
    @State private var manualBarcode = ""
    @FocusState private var isManualEntryFocused: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if scannedProduct != nil {
                productView
            } else {
                scannerContent
            }
        }
    }

    private var scannerContent: some View {
        ZStack {
            BarcodeScannerView { barcode in
                handleScan(barcode)
            }
            .ignoresSafeArea()

            // Overlay
            VStack {
                // Top bar
                Text("Clean Signal")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 60)

                Spacer()

                // Scan frame indicator
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.4), lineWidth: 2)
                    .frame(width: 260, height: 160)

                Spacer()

                // Bottom info
                VStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.2)
                        Text("Looking up product...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else if let error = errorMessage {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    } else {
                        Image(systemName: "barcode.viewfinder")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Point at a barcode to scan")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // Manual entry
                    HStack(spacing: 8) {
                        TextField("Enter barcode", text: $manualBarcode)
                            .keyboardType(.numberPad)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .focused($isManualEntryFocused)

                        Button {
                            submitManualBarcode()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.body)
                                .foregroundColor(.black)
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        .disabled(manualBarcode.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                        .opacity(manualBarcode.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
    }

    private var productView: some View {
        ProductDetailView(product: scannedProduct!, structuredIngredients: structuredIngredients) {
            withAnimation(.easeInOut(duration: 0.2)) {
                scannedProduct = nil
                structuredIngredients = []
                lastScannedBarcode = nil
                errorMessage = nil
            }
        }
    }

    private func submitManualBarcode() {
        let barcode = manualBarcode.trimmingCharacters(in: .whitespaces)
        guard !barcode.isEmpty else { return }
        isManualEntryFocused = false
        manualBarcode = ""
        handleScan(barcode)
    }

    private func handleScan(_ barcode: String) {
        guard !isLoading, barcode != lastScannedBarcode else { return }
        lastScannedBarcode = barcode
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await APIService.lookupBarcode(barcode)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        scannedProduct = result.product
                        structuredIngredients = result.structuredIngredients
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                    // Allow re-scanning same barcode after error
                    lastScannedBarcode = nil
                }
            }
        }
    }
}
