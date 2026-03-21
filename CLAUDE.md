# Clean Signal — iOS App

Barcode nutrition scanner. Point camera at a food barcode → see nutritional info. Minimal dark UI (Revolut-style).

## Stack

- **Language**: Swift 5
- **UI**: SwiftUI (dark mode forced)
- **Camera**: AVFoundation (no third-party libs)
- **Min deployment**: iOS 17
- **Xcode**: 26.0.1
- **GitHub**: https://github.com/clean-signal/clean-signal-ios

## Project Structure

```
CleanSignal.xcodeproj/
CleanSignal/
├── CleanSignalApp.swift        # App entry point, forces dark mode
├── Info.plist                  # Camera permission, local networking
├── Assets.xcassets/
├── Models/
│   └── Product.swift           # Product + ProductResponse Codable models
├── Services/
│   ├── APIService.swift        # Edge Function API calls
│   └── BarcodeScannerDelegate.swift  # AVCaptureMetadataOutput delegate
└── Views/
    ├── ScannerView.swift       # Main view — camera + loading + error states
    ├── BarcodeScannerView.swift # UIViewControllerRepresentable wrapping AVFoundation
    └── ProductDetailView.swift  # Nutritional info display (macros card, NOVA badge, ingredients)
```

## Backend

The app calls a Supabase Edge Function — no direct DB access from the client.

**Production endpoint**: `https://zijbiydtfezbbgyikcgc.supabase.co/functions/v1/lookup-barcode`
**Method**: POST
**Body**: `{ "barcode": "50457250" }`
**Response**: `{ "source": "cache"|"api", "product": {...} }` or `{ "error": "..." }`

The endpoint URL is hardcoded in `APIService.swift`. No auth headers needed (JWT verification is disabled).

## Building

```bash
# Build for simulator (no code signing needed)
xcodebuild -project CleanSignal.xcodeproj -scheme CleanSignal \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO -quiet build

# For device — open in Xcode, set dev team (9PPNJ8A8D5), run
open CleanSignal.xcodeproj
```

**Note**: Camera doesn't work in simulator. Must test on device for barcode scanning.

## Design

- Background: `#0D0D0D` (near black)
- Cards: `#1A1A1A` (dark grey)
- Typography: system font, white on dark
- Macro colors: orange (calories), blue (protein), green (carbs), red (fat)
- NOVA badge: green (1) → yellow (2) → orange (3) → red (4)
- Animations: `easeInOut(duration: 0.2)` for view transitions

## Barcode Types Supported

EAN-8, EAN-13, UPC-E, Code128, Code39, Code93 (configured in `BarcodeScannerView.swift`)

## Debugging

### "Product not found"
The barcode exists but Open Food Facts doesn't have it. Check the `not_found_barcodes` table in Supabase to see scan counts.

### "Failed to fetch from Open Food Facts"
The API returned a non-200/non-404 status. Could be rate limiting or network issues from the Edge Function.

### "Could not connect to the server"
The app can't reach the Edge Function URL. Check:
- Is the URL in `APIService.swift` correct?
- If testing locally, `127.0.0.1` won't work from a physical device — use the Mac's local IP or deploy to remote Supabase.

### No camera feed
- Check camera permission in Settings
- Camera doesn't work in simulator — test on device

## Key Files to Edit

| Task | File |
|------|------|
| Change API endpoint | `Services/APIService.swift` |
| Add new barcode types | `Views/BarcodeScannerView.swift` (metadataObjectTypes) |
| Change UI colors/layout | `Views/ProductDetailView.swift` |
| Add new nutritional fields | `Models/Product.swift` + `Views/ProductDetailView.swift` |
| Change scan behavior | `Views/ScannerView.swift` |
