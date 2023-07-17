//
//  LDKNodeMondayApp.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/20/23.
//

import SwiftUI
import UserNotifications

@main
struct LDKNodeMondayApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            StartView(viewModel: .init())
        }
    }
    
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        try? LightningNodeService.shared.stop()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request Notification Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .provisional, .providesAppNotificationSettings]) { (granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Print entire userInfo dictionary to console
        print("Received remote notification: \(userInfo)")

        // Check for the special key that indicates this is a silent notification.
        if let specialValue = userInfo["your-special-key"] {
            print("Received special key with value: \(specialValue)")

            // Handle the payment here, then call the completion handler.
            // You might want to pass this off to some other component of your app to handle.
            // Once that's done, be sure to call the completionHandler so system resources can be reclaimed.
            completionHandler(.newData)
        } else {
            // No special key, so this is a normal notification.
            print("No special key found in notification.")
            completionHandler(.noData)
        }
    }

}
