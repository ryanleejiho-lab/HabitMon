import SwiftUI
import HabitMonCore

struct ContentView: View {
    @StateObject private var poller = ChecklistPoller()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HabitMon").font(.largeTitle)
            ForEach(HabitType.allCases) { type in
                Text("\(type.displayName): \(poller.state.xp(for: type)) XP")
            }
        }
        .padding()
        .frame(width: 480, height: 360)
        .onAppear { poller.start() }
        .onDisappear { poller.stop() }
    }
}

#Preview {
    ContentView()
}
