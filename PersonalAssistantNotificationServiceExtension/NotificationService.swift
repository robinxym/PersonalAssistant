//
//  NotificationService.swift
//  PersonalAssistantNotificationServiceExtension
//
//  Created by Xue Yong Ming on 25/12/2016.
//  Copyright © 2016 Robin. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
      self.contentHandler = contentHandler
      bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

//      if let bestAttemptContent = bestAttemptContent {
//        // Modify the notification content here...
//        bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
//
//        //            contentHandler(bestAttemptContent)
//      }
//
//      let decryptedBody = request.content.userInfo["encrypted-content"]
//      let newContent = UNMutableNotificationContent()
//      newContent.body = decryptedBody as! String
//
//      contentHandler(newContent)

      let urlStr = request.content.userInfo["picture"] as? String ?? ""
      let urls = urlStr.components(separatedBy: ".")
      guard urls.count > 1 else { contentHandler(request.content); return}
      let pictureURL = Bundle.main.url(forResource: urls[0], withExtension: urls[1])
      let attachment = try! UNNotificationAttachment(identifier: urlStr, url: pictureURL!, options: nil)

      if let bestAttemptContent =  bestAttemptContent {
        bestAttemptContent.attachments = [attachment]
        contentHandler(bestAttemptContent)
      }
  }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
