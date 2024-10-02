//
//  AppDelegate.swift
//  BackgroudTaskShedularDemo
//
//  Created by Harshit Gupta on 02/10/24.
//

import UIKit
import BackgroundTasks
import os.log


enum BackgroundTaskConstants {
    static let refreshTaskIdentifier = "com.harshit.example.refressTask"
}


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppDelegate")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        debugPrint("countProcess",countProcess)
        // Register background tasks
        
        logger.notice(#function)
        registerLocalNotification()
        BackgroundTaskManager.shared.register()
        BackgroundTaskManager.shared.scheduleAppRefresh()
        
        
//
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundTaskConstants.refreshTaskIdentifier, using: nil) { task in
//            self.scheduleLocalNotification()
//            if let task = task as? BGAppRefreshTask{
//                self.handleAppRefresh(task: task )
//            }
//        }
//        
       
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Handle session discard if needed
    }
}

// MARK: - Background Task Handlers
extension AppDelegate {
    // Handle background refresh task
    func handleAppRefresh(task: BGAppRefreshTask) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let date = dateFormatter.string(from: Date())
        
        // Thread-safe write to arrDates
            var arrDatest = arrDates
            arrDatest.append(date)
            arrDates = arrDatest
            countProcess += 1
        
        print("Fetching data from server... Date added: \(date)")
        
        scheduleAppRefresh()
        // Expiration handler
        task.expirationHandler = {
            print("Background refresh task expired.")
        }
        
        task.setTaskCompleted(success: true)


    }
    

}

extension AppDelegate : UNUserNotificationCenterDelegate{
    func registerLocalNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    func scheduleLocalNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.fireNotification()
            }
        }
    }
    
    func fireNotification() {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "Bg"
        notificationContent.body = "BG Notifications."
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 60.0, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
        UNUserNotificationCenter.current().delegate = self

    }
    
    func scheduleAppRefresh() {
        BGTaskScheduler.shared.cancelAllTaskRequests()

        BGTaskScheduler.shared.getPendingTaskRequests { taskArr in
            for task in taskArr {
                debugPrint(task.earliestBeginDate)
                debugPrint(task.description)
            }
//            if taskArr.isEmpty {  // Avoid scheduling if tasks are already pending
                let request = BGAppRefreshTaskRequest(identifier: BackgroundTaskConstants.refreshTaskIdentifier)
                request.earliestBeginDate = Date(timeIntervalSinceNow: 60) // Schedule to start after 5 seconds
                
                do {
                    try BGTaskScheduler.shared.submit(request)
                    print("Scheduled background refresh task successfully.")
                } catch {
                    print("Could not schedule app refresh: \(error)")
                }
//            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

            //displaying the ios local notification when app is in foreground
            completionHandler([.alert, .badge, .sound])
        }
    
    
}

// MARK: - Thread-safe UserDefaults access
var arrDates: [String] {
    get {
        return UserDefaults.standard.value(forKey: "ArrData") as? [String] ?? []
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "ArrData")
        UserDefaults.standard.synchronize()
    }
}

var countProcess: Int {
    get {
        return UserDefaults.standard.integer(forKey: "count")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "count")
        UserDefaults.standard.synchronize()
    }
}
