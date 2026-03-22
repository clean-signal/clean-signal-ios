# Clean Signal — iOS App

Barcode nutrition scanner with evidence-based Clean Score. Point camera at a food barcode → see how clean it is for longevity. Minimal dark UI (Revolut-style).

## Stack

- **Language**: Swift 5
- **UI**: SwiftUI (dark mode forced)
- **Camera**: AVFoundation (no third-party libs)
- **Min deployment**: iOS 17
- **Xcode**: 26.0.1
- **GitHub**: https://github.com/clean-signal/clean-signal-ios
- **Dev team**: 9PPNJ8A8D5

## Project Structure

```
CleanSignal.xcodeproj/
CleanSignal/
├── CleanSignalApp.swift        # App entry point, forces dark mode
├── Info.plist                  # Camera permission, local networking
├── Assets.xcassets/
├── Models/
│   └── Product.swift           # Product, Additive, ScoreBreakdown models
├── Services/
│   ├── APIService.swift        # Edge Function API calls
│   └── BarcodeScannerDelegate.swift  # AVCaptureMetadataOutput delegate
└── Views/
    ├── ScannerView.swift       # Main view — camera + loading + error states
    ├── BarcodeScannerView.swift # UIViewControllerRepresentable wrapping AVFoundation
    └── ProductDetailView.swift  # Product detail — score, concerns, macros, allergens, etc.
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

# For device — open in Xcode, run
open CleanSignal.xcodeproj
```

**Note**: Camera doesn't work in simulator. Must test on device for barcode scanning.

## Design

- Background: `#0D0D0D` (near black)
- Cards: `#1A1A1A` (dark grey, 16pt corner radius, 20pt padding)
- Typography: system font, white on dark
- Score colors: 80+ green (`#1B8A2A`), 60-79 light green (`#85BB2F`), 40-59 orange (`#EE8100`), <40 red (`#E63E11`)
- Macro colors: orange (calories), blue (protein), green (carbs), red (fat)
- Animations: `easeInOut(duration: 0.2)` for view transitions

## Product Detail View Layout

1. **Header**: Product image + name + brand + Clean Score badge (compact 48x48 square)
2. **Concerns**: Only factors that lost points (not estimated). Shows verdict + points lost. If any factors have missing data, shows "Some nutritional data unavailable" note
3. **Macros card**: Primary (cal, protein, carbs, fat) + secondary row (sat fat, sugars, salt, fiber)
4. **Allergens**: Red pills for allergens, orange for traces ("May contain")
5. **Additives**: Each with E-number ID + human-readable name, count in header
6. **Ingredients**: Full text, count in header
7. **Analysis**: Vegan/vegetarian status pills, ecoscore badge

## Key Data Models

- `Product` — all fields from the Edge Function response, all optional except barcode
- `Additive` — `{id: "E412", name: "Guar gum"}`
- `ScoreBreakdown` — `{factor, points, maxPoints, verdict, estimated}`

The `estimated` flag on ScoreBreakdown indicates missing data that was given full points (benefit of the doubt). The UI filters these from the concerns list and shows a note instead.

## Barcode Types Supported

EAN-8, EAN-13, UPC-E, Code128, Code39, Code93 (configured in `BarcodeScannerView.swift`)

## Debugging

### "Product not found"
The barcode exists but Open Food Facts doesn't have it. Check the `not_found_barcodes` table in Supabase.

### "Failed to fetch from Open Food Facts"
The API returned a non-200/non-404 status. Could be rate limiting or network issues from the Edge Function.

### "Could not connect to the server"
The app can't reach the Edge Function URL. Check `APIService.swift` URL. `127.0.0.1` won't work from a physical device — must use deployed Supabase.

### Score seems wrong
Check the full `clean_score_breakdown` in the DB — there may be factors with `estimated: true` (missing data getting full points) or factors losing points that aren't visible in the concerns UI. See supabase CLAUDE.md for scoring details.

### No camera feed
- Check camera permission in Settings
- Camera doesn't work in simulator — test on device

## Key Files to Edit

| Task | File |
|------|------|
| Change API endpoint | `Services/APIService.swift` |
| Add new barcode types | `Views/BarcodeScannerView.swift` (metadataObjectTypes) |
| Change score display/colors | `Views/ProductDetailView.swift` (scoreBadge, scoreColor, concernsSection) |
| Add new product fields | `Models/Product.swift` + `Views/ProductDetailView.swift` |
| Change scan behavior | `Views/ScannerView.swift` |
