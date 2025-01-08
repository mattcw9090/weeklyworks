import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab for Schedule
            TrainingSessionsView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }

            // Tab for Students
            TrainingSessionsView()
                .tabItem {
                    Label("Students", systemImage: "person.3")
                }
        }
    }
}

#Preview {
    ContentView()
}
