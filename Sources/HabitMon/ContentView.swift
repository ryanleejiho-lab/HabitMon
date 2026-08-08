import SwiftUI
import SpriteKit
import HabitMonCore

struct ContentView: View {
    @StateObject private var poller = ChecklistPoller()
    private let scene: RoomScene = {
        let scene = RoomScene()
        scene.size = CGSize(width: 480, height: 360)
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        SpriteView(scene: scene)
            .frame(width: 480, height: 360)
            .onAppear {
                poller.start()
                scene.updateOverlays(state: poller.state)
            }
            .onDisappear {
                poller.stop()
            }
            .onChange(of: poller.state) { newState in
                scene.updateOverlays(state: newState)
            }
    }
}

#Preview {
    ContentView()
}
