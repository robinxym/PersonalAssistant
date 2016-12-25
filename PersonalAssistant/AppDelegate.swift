//
//  AppDelegate.swift
//  PersonalAssistant
//
//  Created by Xue Yong Ming on 25/12/2016.
//  Copyright © 2016 Robin. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.

    let center = UNUserNotificationCenter.current()
    center.delegate = self
    center.requestAuthorization(options: [UNAuthorizationOptions.alert, UNAuthorizationOptions.badge,  UNAuthorizationOptions.sound]) { (granted, error) in
      if granted {
        center.getNotificationSettings(completionHandler: { (notificationSettings) in
          print(notificationSettings)
        })
        self.prepareForRemoteNotifications()
        application.registerForRemoteNotifications()
      }
    }
    
    return true
  }

  func prepareForRemoteNotifications() {
    let content = UNMutableNotificationContent()
    content.title = "Notifications Introduction"
    content.subtitle = "iOS 10"
    content.body = "New notification is great."
    content.badge = 1
    content.categoryIdentifier = "message"

    let trigger1 = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
//    let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
//    var dateComponents = DateComponents()
//    dateComponents.weekday = 1
//    dateComponents.hour = 8
//    let trigger3 = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//    //    let region = CLRegion()
//    let circleRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 120.674938, longitude: 31.318136), radius: CLLocationDistance.abs(100), identifier: "circleRegion")
//    let trigger4 = UNLocationNotificationTrigger(region: circleRegion, repeats: false)

    let center = UNUserNotificationCenter.current()
    let replyAction = UNTextInputNotificationAction(identifier: "reply", title: "Reply", options: .foreground, textInputButtonTitle: "Reply", textInputPlaceholder: "Type Text To Reply.")
//    let replyAction = UNNotificationAction(identifier: "reply", title: "Reply", options: [.foreground])
    let clearAction = UNNotificationAction(identifier: "clear", title: "Clear", options: [])
    let category = UNNotificationCategory(identifier: "message", actions: [replyAction, clearAction], intentIdentifiers: ["message"], options: [.customDismissAction])
    center.setNotificationCategories(Set([category]))

    let requestIdentifier = "requestIdentifier"
    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger1)
    center.add(request) { (error) in
      if let error = error {
        print("add notification request error: \(error)")
      }
    }

//    content.title = "Re-Introduction to Notifications"
//    center.add(request) { (error) in
//      if let error = error {
//        print("add notification request error: \(error)")
//      }
//    }

  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
    var tokenString = ""

    for i in 0..<deviceToken.count {
      tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }

    print("Device Token:", tokenString)
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    		print("Failed to register:", error)
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    completionHandler(UIBackgroundFetchResult.newData)
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([UNNotificationPresentationOptions.alert, UNNotificationPresentationOptions.badge,  UNNotificationPresentationOptions.sound])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    defer {completionHandler()}
    let categoryIdentifier = response.notification.request.content.categoryIdentifier
    switch categoryIdentifier {
    case "message":
      switch response.actionIdentifier {
      case "reply":
        guard let textResponse = response as? UNTextInputNotificationResponse else {return}
        let userText = textResponse.userText
        guard let aps = response.notification.request.content.userInfo["aps"] as? [String: Any], let messageAlert = aps["alert"] as? String else {return}
print(messageAlert)
        guard let messageTableViewController = (window?.rootViewController as? UITabBarController)?.childViewControllers.last as? MessageTableViewController else {return}
        messageTableViewController.messages.append("\(messageAlert) - \(userText)")

        if let tabBarController = window?.rootViewController as? UITabBarController {
          tabBarController.selectedIndex = tabBarController.childViewControllers.count == 0 ? 0 : tabBarController.childViewControllers.count - 1
        }


      case "clear":
        break
      default:
        break
      }
    default:
      break
    }
  }
}
