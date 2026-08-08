import AppKit
import HabitMonCore

/// Procedurally generates simple pixel-grid creature art — no external image assets.
/// Draws filled squares onto a small grid, then renders at a fixed pixel scale with
/// nearest-neighbor interpolation so the result stays crisp and blocky (pixel-art style)
/// instead of blurry. Exact patterns below are a first-pass v1 design — trivially
/// tweakable once you can see it on screen (Task 10).
enum CreatureSpriteBuilder {
    static let gridSize = 16
    static let pixelScale: CGFloat = 8 // final image is gridSize * pixelScale px per side
    static let imageSize = CGFloat(gridSize) * pixelScale

    /// The base body — the same at every stage, doesn't change with stats.
    static func baseBodyImage() -> NSImage {
        var grid = emptyGrid()
        for y in 5...12 {
            for x in 4...11 {
                grid[y][x] = NSColor.systemGray
            }
        }
        grid[8][6] = .black
        grid[8][9] = .black
        return render(grid)
    }

    /// One stat's overlay part at a given stage. Stage 0 has no overlay yet (that stat
    /// hasn't grown) — returns nil so the caller can hide/skip rendering it.
    static func overlayImage(for type: HabitType, stage: Int) -> NSImage? {
        guard stage > 0 else { return nil }
        var grid = emptyGrid()
        let color = overlayColor(for: type)

        switch (type, stage) {
        case (.fire, 1):
            grid[3][7] = color
            grid[3][8] = color
            grid[4][7] = color
            grid[4][8] = color
        case (.fire, 2):
            for x in 5...10 { grid[2][x] = color }
            grid[1][6] = color
            grid[1][7] = color
            grid[1][8] = color
            grid[1][9] = color
            for x in 6...9 { grid[3][x] = color }

        case (.wisdom, 1):
            grid[4][6] = color
            grid[4][9] = color
            grid[3][7] = color
            grid[3][8] = color
        case (.wisdom, 2):
            for x in 5...10 { grid[3][x] = color }
            grid[2][7] = color
            grid[2][8] = color
            grid[1][7] = color
            grid[1][8] = color

        case (.nature, 1):
            grid[4][5] = color
            grid[4][10] = color
            grid[3][7] = color
            grid[3][8] = color
        case (.nature, 2):
            for x in 4...11 { grid[3][x] = color }
            grid[2][5] = color
            grid[2][10] = color
            grid[1][7] = color
            grid[1][8] = color

        case (.water, 1):
            grid[4][7] = color
            grid[4][8] = color
            grid[3][7] = color
        case (.water, 2):
            for x in 5...10 { grid[3][x] = color }
            for x in 6...9 { grid[2][x] = color }
            grid[1][7] = color
            grid[1][8] = color

        case (.storm, 1):
            grid[4][7] = color
            grid[3][8] = color
            grid[4][8] = color
        case (.storm, 2):
            grid[3][6] = color
            grid[2][7] = color
            grid[3][7] = color
            grid[1][8] = color
            grid[2][8] = color
            grid[3][9] = color

        default:
            break
        }

        return render(grid)
    }

    private static func overlayColor(for type: HabitType) -> NSColor {
        switch type {
        case .fire: return .systemOrange
        case .wisdom: return .systemBlue
        case .nature: return .systemGreen
        case .water: return .systemTeal
        case .storm: return .systemYellow
        }
    }

    private static func emptyGrid() -> [[NSColor?]] {
        Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
    }

    private static func render(_ grid: [[NSColor?]]) -> NSImage {
        let image = NSImage(size: CGSize(width: imageSize, height: imageSize))
        image.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .none
        for (y, row) in grid.enumerated() {
            for (x, color) in row.enumerated() {
                guard let color else { continue }
                color.setFill()
                let rect = CGRect(
                    x: CGFloat(x) * pixelScale,
                    y: CGFloat(gridSize - 1 - y) * pixelScale,
                    width: pixelScale,
                    height: pixelScale
                )
                rect.fill()
            }
        }
        image.unlockFocus()
        return image
    }
}
