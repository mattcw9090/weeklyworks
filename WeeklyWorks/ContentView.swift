import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab for Schedule
            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }

            // Tab for Students
            ScheduleView()
                .tabItem {
                    Label("Students", systemImage: "person.3")
                }
        }
    }
}

#Preview {
    ContentView()
}
