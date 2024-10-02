//
//  BackgroundTaskManager.swift
//  BackgroudTaskShedularDemo
//
//  Created by Harshit Gupta on 02/10/24.
//


//  BackgroundTaskManager.swift
//
//  Created by Robert Ryan on 5/14/24.

import Foundation
import os.log
import BackgroundTasks
import UserNotifications

@MainActor
class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "BackgroundTaskManager")
    private let appRefreshIdentifier = BackgroundTaskConstants.refreshTaskIdentifier

    private init() { }

    @discardableResult
    func register() -> Bool {
        let isRegistered = BGTaskScheduler.shared.register(
            forTaskWithIdentifier: appRefreshIdentifier,
            using: nil
        ) { [weak self, logger] task in
            guard let self else { return }
            logger.notice("\(#function, privacy: .public): register closure called")
            Task { [task] in
                let processTask = Task { await self.handleAppRefresh() }
                task.expirationHandler = { processTask.cancel() }
                task.setTaskCompleted(success: await processTask.value)
            }
        }

        logger.notice("\(#function, privacy: .public): isRegistered = \(isRegistered)")

        return isRegistered
    }

    func scheduleAppRefresh() {
        logger.notice(#function)

        let request = BGAppRefreshTaskRequest(identifier: appRefreshIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logger.error("\(#function, privacy: .public): Could not schedule app refresh: \(error)")
        }
    }
}

// MARK: - Private methods

private extension BackgroundTaskManager {
    func handleAppRefresh() async -> Bool {
        logger.notice("\(#function, privacy: .public): starting")

        // make sure to schedule again, so that this continues to enjoy future background fetch

        scheduleAppRefresh()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let date = dateFormatter.string(from: Date())
        // now fetch data
        
        do {
            var arrDatest = arrDates
            arrDatest.append(date)
            arrDates = arrDatest
            countProcess += 1
            
//            try await DataRepositoryService.shared.fetchNewData()
            notifyUserInDebugBuild(message: "\(#function): success")
            logger.notice("\(#function, privacy: .public): success")
            return true
        } catch {
            notifyUserInDebugBuild(message: "\(#function): failed")
            logger.error("\(#function, privacy: .public): failed \(error, privacy: .public)")
            return false
        }
    }

    func notifyUserInDebugBuild(message: String) {
#if DEBUG
        logger.notice("\(#function, privacy: .public): message: \(message, privacy: .public)")

        let content = UNMutableNotificationContent()
        content.title = "BackgroundTaskManager"
        content.body = message
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request)
#endif
    }
}
