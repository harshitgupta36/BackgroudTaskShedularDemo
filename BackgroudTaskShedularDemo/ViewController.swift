//
//  ViewController.swift
//  BackgroudTaskShedularDemo
//
//  Created by Harshit Gupta on 02/10/24.
//

import UIKit
import BackgroundTasks

class ViewController: UIViewController {

    @IBOutlet weak var labelTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        self.scheduleAppRefresh()
        labelTitle.numberOfLines = 0
        labelTitle.text = "Background Task Scheduler Demo \(arrDates) \(countProcess)"
    }
    
//    func scheduleAppRefresh() {
//        BGTaskScheduler.shared.cancelAllTaskRequests()
//        BGTaskScheduler.shared.getPendingTaskRequests { taskArr in
//            for task in taskArr {
//                debugPrint(task.earliestBeginDate)
//                debugPrint(task.description)
//            }
////            if taskArr.isEmpty {  // Avoid scheduling if tasks are already pending
//                let request = BGAppRefreshTaskRequest(identifier: BackgroundTaskConstants.refreshTaskIdentifier)
//                request.earliestBeginDate = Date(timeIntervalSinceNow: 5) // Schedule to start after 5 seconds
//                
//                do {
//                //    e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.harshit.example.refressTask"]
//                    try BGTaskScheduler.shared.submit(request)
//                    print("Scheduled background refresh task successfully.")
//                } catch {
//                    print("Could not schedule app refresh: \(error)")
//                }
////            }
//        }
//    }


}

