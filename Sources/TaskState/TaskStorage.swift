import Foundation

/// An `@Observable` box owning one in-flight `Task`, cancelling it when replaced
/// or torn down. Hosted in `@State` by `@TaskState`.
final class TaskStorage<Success: Sendable, Failure: Error> {
    var task: Task<Success, Failure>? {
        didSet { oldValue?.cancel() }
    }

    deinit { task?.cancel() }
}
