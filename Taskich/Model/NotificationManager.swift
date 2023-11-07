import UIKit

public final class NotificationManager {
    public static let shared = NotificationManager()
    private init() {}
    
    private func authorizeRequest() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in }
    }
    
    public func requestNotificationAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                self.authorizeRequest()
            }
        }
    }

    
    public func createNotification(for task: Task) {
        guard let body = task.text, let targetDate = task.reminder else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Taskich"
        content.sound = .default
        content.body = body
        
        let targetDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                                   from: targetDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: targetDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(task.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    public func updateNotification(in task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(task.id)"])
        createNotification(for: task)
    }

    
    public func deleteNotification(with id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(id)"])
    }
}
