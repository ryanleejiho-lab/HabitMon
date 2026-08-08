import SwiftUI
import HabitMonCore

struct StatHUDView: View {
    let state: HabitMonState

    var body: some View {
        HStack(spacing: 16) {
            ForEach(HabitType.allCases) { type in
                VStack(spacing: 2) {
                    Text(type.displayName)
                        .font(.caption2)
                        .bold()
                    Text("\(state.xp(for: type)) XP")
                        .font(.caption2)
                    Text("Stage \(Evolution.stage(forXP: state.xp(for: type)))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(10)
        .background(.regularMaterial)
    }
}

#Preview {
    StatHUDView(state: .empty)
}
