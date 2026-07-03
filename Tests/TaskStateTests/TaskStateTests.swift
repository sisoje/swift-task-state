@testable import TaskState
import XCTest

final class TaskStorageTests: XCTestCase {
    func testReplacingTaskCancelsPrevious() async {
        let storage = TaskStorage<Void, Never>()

        let started = expectation(description: "started")
        let first = Task {
            started.fulfill()
            while !Task.isCancelled {
                await Task.yield()
            }
        }
        storage.task = first
        await fulfillment(of: [started], timeout: 1)

        storage.task = Task {} // replacing must cancel the previous
        await first.value
        XCTAssertTrue(first.isCancelled)
    }

    func testDeinitCancelsTask() async {
        let started = expectation(description: "started")
        let task = Task {
            started.fulfill()
            while !Task.isCancelled {
                await Task.yield()
            }
        }

        var storage: TaskStorage<Void, Never>? = TaskStorage()
        storage?.task = task
        await fulfillment(of: [started], timeout: 1)

        storage = nil // deinit → cancellation
        _ = storage

        await task.value
        XCTAssertTrue(task.isCancelled)
    }
}
