//
//  MockDataTask.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 22/09/21.
//

import Foundation
import MailTMSwift

class MockDataTask: MTAPIServiceTaskProtocol {

    var taskId: UUID

    init (taskId: UUID = .init()) {
        self.taskId = taskId
    }

    var cancelCallCount = 0
    func cancel() {
        cancelCallCount += 1
    }

}
