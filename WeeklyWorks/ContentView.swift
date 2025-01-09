import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab for Training Sessions
            TrainingSessionsView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }

            // Tab for Students
            StudentsView()
                .tabItem {
                    Label("Students", systemImage: "person.3")
                }
        }
    }
}

#Preview {
    ContentView()
}
