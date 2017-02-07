//
//  UIViewController+Alert.swift
//  GradePoint
//
//  Created by Luis Padron on 1/26/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Presents a blur alert with given title and message, optional completion handler
    func presentErrorAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let t = NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17),
                                                                   NSForegroundColorAttributeName: UIColor.red])
        let m = NSAttributedString(string: message, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 15),
                                                               NSForegroundColorAttributeName: UIColor.mutedText])
        let alert = UIBlurAlertController(size: CGSize(width: 300, height: 200), title: t, message: m)
        let ok = UIButton()
        ok.setTitle("OK", for: .normal)
        ok.backgroundColor = UIColor.lapisLazuli
        alert.addButton(button: ok) {
            completion?()
        }
        alert.presentAlert(presentingViewController: self)
    }
}
