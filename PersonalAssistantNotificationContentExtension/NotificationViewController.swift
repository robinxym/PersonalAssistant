//
//  NotificationViewController.swift
//  PersonalAssistantNotificationContentExtension
//
//  Created by Xue Yong Ming on 25/12/2016.
//  Copyright © 2016 Robin. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.

      let size = view.bounds.size
      preferredContentSize = CGSize(width: size.width, height: size.height/2)
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
    }

}
