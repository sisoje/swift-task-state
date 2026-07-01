import Foundation

/// An `@Observable` box owning one in-flight `Task`, cancelling it when replaced
/// or torn down. Hosted in `@State` by `@TaskState`.
public final class TaskStorage<Success: Sendable, Failure: Error> {
    public var task: Task<Success, Failure>? {
        didSet { oldValue?.cancel() }
    }

    public init(_ task: Task<Success, Failure>? = nil) {
        self.task = task
    }

    deinit { task?.cancel() }
}
