# TaskState

`@TaskState` — a drop-in replacement for `@State`, scoped to cancellable
`Task`s. Store a task like any piece of view state and get automatic
cancellation for free:

- Assigning a new task **cancels the one it replaces**.
- The in-flight task is **cancelled when the view leaves the graph**.

```swift
import TaskState

struct DownloadView: View {
    @TaskState var download: Task<Data, Error>?
    @State private var data: Data?

    var body: some View {
        Button("Download") {
            download = Task {          // cancels any previous download
                data = try await fetch()
            }
        }
    }
}
```

It reads, writes, and binds identically to `@State`:

```swift
@TaskState var download: Task<Data, Error>?   // always starts nil

download = Task { … }        // assign (cancels any previous task)
download?.cancel()           // read
ChildView(task: $download)   // $download is a Binding, just like @State
```

## How it works

Two small pieces, no macro. `TaskStorage` is a plain class — the one place a
class is justified, because it needs a `deinit` hook a struct can't provide:

```swift
public final class TaskStorage<Success: Sendable, Failure: Error> {
    public var task: Task<Success, Failure>? {
        didSet { oldValue?.cancel() }   // replacing cancels the old task
    }
    deinit { task?.cancel() }           // teardown cancels the live task
}
```

`@TaskState` is a custom `DynamicProperty` that hosts it in `@State`:

```swift
@propertyWrapper
public struct TaskState<Success: Sendable, Failure: Error>: DynamicProperty {
    @State private var storage = TaskStorage<Success, Failure>()

    public var wrappedValue: Task<Success, Failure>? {
        get { storage.task }
        nonmutating set { storage.task = newValue }
    }
    public var projectedValue: Binding<Task<Success, Failure>?> { $storage.task }
}
```

`@State` owns the storage's lifecycle — it persists across re-renders and gets
`deinit`-cancelled on teardown. There's deliberately no `@Observable`: a `Task`
handle isn't render-driving state (it never nils itself on completion), so
mutating it shouldn't re-render. Drive UI from separate `@State` the task writes.

## Requirements

- Swift 6.0+
- iOS 17 / macOS 14 / tvOS 17 / watchOS 10 (requires Observation)

## Install

```swift
.package(url: "…/TaskState.git", from: "1.0.0")
```

Then add `TaskState` to your target's dependencies.
