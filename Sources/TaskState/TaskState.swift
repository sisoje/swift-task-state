import SwiftUI

/// A drop-in `@State` for a cancellable `Task`. Assigning a new task cancels the
/// previous one; the live task is cancelled when the view leaves the graph.
///
///     @TaskState var download: Task<Data, Error>?
///     download = Task { … }   // cancels any previous download
///     ChildView(task: $download)   // $download is a Binding, like @State
///
/// It is a custom `DynamicProperty` hosting an `@Observable` `TaskStorage` in
/// `@State`, so SwiftUI owns its lifecycle: it persists across re-renders,
/// re-renders when the task changes, and cancels on teardown.
@propertyWrapper
public struct TaskState<Success: Sendable, Failure: Error>: DynamicProperty {
    @State private var storage = TaskStorage<Success, Failure>()

    public init() {}

    public var wrappedValue: Task<Success, Failure>? {
        get { storage.task }
        nonmutating set { storage.task = newValue }
    }

    public var projectedValue: Binding<Task<Success, Failure>?> {
        $storage.task
    }
}
