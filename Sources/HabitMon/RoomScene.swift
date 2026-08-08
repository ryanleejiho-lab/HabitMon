import SpriteKit
import HabitMonCore

final class RoomScene: SKScene {
    private let creatureNode = SKSpriteNode()
    private var overlayNodes: [HabitType: SKSpriteNode] = [:]
    private var moveDirection = CGVector(dx: 0, dy: 0)
    private let moveSpeed: CGFloat = 120
    private let creatureSize = CGSize(width: 128, height: 128)

    override func didMove(to view: SKView) {
        backgroundColor = NSColor(calibratedRed: 0.85, green: 0.93, blue: 0.82, alpha: 1)

        creatureNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        creatureNode.size = creatureSize
        creatureNode.texture = SKTexture(image: CreatureSpriteBuilder.baseBodyImage())
        addChild(creatureNode)

        for type in HabitType.allCases {
            let overlay = SKSpriteNode()
            overlay.size = creatureSize
            overlay.zPosition = 1
            overlay.isHidden = true
            creatureNode.addChild(overlay)
            overlayNodes[type] = overlay
        }
    }

    /// Called by ContentView whenever the poller's state changes — swaps each stat's
    /// overlay part to match its current stage.
    func updateOverlays(state: HabitMonState) {
        for type in HabitType.allCases {
            guard let node = overlayNodes[type] else { continue }
            let stage = Evolution.stage(forXP: state.xp(for: type))
            if let image = CreatureSpriteBuilder.overlayImage(for: type, stage: stage) {
                node.texture = SKTexture(image: image)
                node.isHidden = false
            } else {
                node.isHidden = true
            }
        }
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123: moveDirection.dx = -1 // left arrow
        case 124: moveDirection.dx = 1  // right arrow
        case 125: moveDirection.dy = -1 // down arrow
        case 126: moveDirection.dy = 1  // up arrow
        default: break
        }
    }

    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 123, 124: moveDirection.dx = 0
        case 125, 126: moveDirection.dy = 0
        default: break
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard moveDirection != .zero else { return }
        let dx = moveDirection.dx * moveSpeed / 60.0
        let dy = moveDirection.dy * moveSpeed / 60.0
        var newPosition = CGPoint(x: creatureNode.position.x + dx, y: creatureNode.position.y + dy)
        newPosition.x = min(max(newPosition.x, creatureSize.width / 2), size.width - creatureSize.width / 2)
        newPosition.y = min(max(newPosition.y, creatureSize.height / 2), size.height - creatureSize.height / 2)
        creatureNode.position = newPosition
    }
}
