#if canImport(SwiftUI)
    import SwiftUI
    import TaskState
    import XCTest

    /// Compiles only if @TaskState expands and type-checks inside a real View,
    /// exercising get/set and the $ binding projection.
    private struct DemoView: View {
        @TaskState var download: Task<Void, Never>?

        var body: some View {
            Button("Go") {
                download = Task {} // set
                let _: Task<Void, Never>? = download // get
                let _: Binding<Task<Void, Never>?> = $download // projection
            }
        }
    }

    final class IntegrationCompileTests: XCTestCase {
        @MainActor func testCompiles() {
            _ = DemoView()
        }
    }
#endif
