#if canImport(AppKit)
    import AppKit
    import SwiftUI
    @testable import TaskState
    import XCTest

    /// Proves `@TaskState` is a real SwiftUI source of truth: its storage survives
    /// a **parent** re-render (which reconstructs the child) instead of being
    /// recreated — otherwise the running task would be dropped on every redraw.
    @MainActor
    final class StatePersistenceTests: XCTestCase {
        @Observable final class Trigger { var n = 0 }
        final class Recorder { var tasks: [Task<Void, Never>] = [] } // Task is Hashable

        struct Parent: View {
            let trigger: Trigger
            let recorder: Recorder

            var body: some View {
                // Pass the trigger in so the child re-renders (and is reconstructed)
                // whenever it changes.
                Child(tick: trigger.n, recorder: recorder)
            }
        }

        struct Child: View {
            @TaskState var work: Task<Void, Never>?
            let tick: Int
            let recorder: Recorder

            var body: some View {
                if let work { recorder.tasks.append(work) }
                return Color.clear
                    .onAppear { work = Task {} }
            }
        }

        func testTaskSurvivesParentReRenders() {
            let trigger = Trigger()
            let recorder = Recorder()

            let host = NSHostingView(rootView: Parent(trigger: trigger, recorder: recorder))
            host.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            let window = NSWindow(
                contentRect: host.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.contentView = host
            pump()

            for i in 1 ... 3 {
                trigger.n = i
                pump()
            }

            XCTAssertGreaterThan(recorder.tasks.count, 1, "parent did not re-render the child")
            XCTAssertEqual(
                Set(recorder.tasks).count, 1,
                "the task was recreated across re-renders — @TaskState did not persist"
            )
        }

        private func pump() {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
    }
#endif
