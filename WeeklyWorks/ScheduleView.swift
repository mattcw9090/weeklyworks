import SwiftUI

struct ScheduleView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("This is the Schedule View")
                    .font(.title)
                    .padding()

                NavigationLink(destination: ScheduleDetailView()) {
                    Text("Go to Schedule Details")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Schedule")
        }
    }
}

struct ScheduleDetailView: View {
    var body: some View {
        Text("This is the Schedule Detail View")
            .font(.title2)
            .padding()
    }
}

#Preview {
    ScheduleView()
}
