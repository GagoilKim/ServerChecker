//
//  AlertService.swift
//  ServerChecker
//
//  Created by Kyle Kim on 2022/12/28.
//

import Foundation
import UserNotifications

protocol NotifyServiceProtocol {
    func notifyDisconnect()
    
}

class NotifyService: NotifyServiceProtocol{
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                debugPrint("NOTIFICATION SET")
            } else {
                debugPrint("NOTIFICATION FAILED")
            }
        }
    }
    
    func notifyDisconnect() {
        let content = UNMutableNotificationContent()
        content.title = "Server Disconnected"
        content.subtitle = "Check it out!!"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
