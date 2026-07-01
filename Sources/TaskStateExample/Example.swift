import SwiftUI
import TaskState

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @TaskState var counting: Task<Void, Never>?
    @State private var count = 0

    var body: some View {
        VStack {
            Text("\(count)")

            Button("Count to 10") {
                counting = Task {
                    for i in 1 ... 10 {
                        try? await Task.sleep(for: .seconds(1))
                        count = i
                    }
                }
            }

            Button("Cancel") { counting = nil }
        }
        .padding()
    }
}
