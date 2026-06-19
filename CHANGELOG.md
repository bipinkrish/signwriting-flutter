## 1.0.0

* Visualizer

## 1.0.1

* Documentation

## 1.0.2

* More Documentation

## 1.0.3

* Refactor

## 1.0.4

* Removed Assets from PUB

## 1.1.0

* Accept SWU strings in `signwritingToImage` (auto-detected and converted)
* Add `signwritingsToImage` to render and combine multiple signs (horizontal/vertical, centered)
* `trustBox: false` now uses the tight box from `signwritingBox` (font-metric based), matching the Python reference
* Re-export the pure `signwriting` utilities (incl. `getSymbolSize`, `signwritingBox`) for a single import
* Fix documentation rendering (escape generic types in doc comments)
* Require `signwriting: ^1.4.0`
