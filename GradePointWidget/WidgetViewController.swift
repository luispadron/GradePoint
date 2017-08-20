//
//  TodayViewController.swift
//  GradePointWidget
//
//  Created by Luis Padron on 8/20/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import NotificationCenter
import UICircularProgressRing
import RealmSwift

class WidgetViewController: UIViewController, NCWidgetProviding {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.preferredContentSize = CGSize(width: 320, height: 120)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }

    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return .zero
    }

    // MARK: Helpers

    private func setupUI() {
        if #available(iOS 10.0, *) {
            // Something else here
        } else {
            // Change colors
        }
    }
}
