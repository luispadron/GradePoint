//
//  GPPOnboarding5ViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 1/31/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit

class GPPOnboarding5ViewController: UIViewController {

    var bgView: UIView?

    private lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        return view
    }()

    @IBOutlet weak var purchaseButton: UIButton!

    // MARK: View lify cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePurchaseNotification),
                                               name: NSNotification.Name(rawValue: IAPManager.IAPManagerPurchaseNotification),
                                               object: nil)
        self.bgView = UIView()
        self.bgView?.backgroundColor = .black
        self.bgView?.alpha = 0.6
        self.bgView?.frame = CGRect(x: 0, y: 0, width: self.indicator.frame.width + 50, height: self.indicator.frame.width + 50)
        self.bgView?.center = self.view.center
        self.bgView?.layer.cornerRadius = 10
        self.view.addSubview(self.bgView!)
        self.bgView?.isHidden = true

        self.indicator.center = self.view.center
        self.view.addSubview(self.indicator)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.purchaseButton.layer.cornerRadius = self.purchaseButton.frame.height / 2
        self.purchaseButton.clipsToBounds = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: Actions

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.indicator.stopAnimating()
        self.bgView?.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func purchasedButtonTapped(_ sender: UIButton) {
        self.indicator.startAnimating()
        self.bgView?.isHidden = false
        GradePointPremium.purchase { success in
            if !success {
                self.presentErrorAlert(title: "Purchase error", message: "Something went wrong when purchasing, please try again later.")
                self.indicator.stopAnimating()
                self.bgView?.isHidden = true
            }
        }
    }
    
    @IBAction func restorePurchasedButtonTapped(_ sender: UIButton) {
        self.indicator.startAnimating()
        self.bgView?.isHidden = false
        GradePointPremium.store.restorePurchases { success in
            if !success {
                self.presentErrorAlert(title: "Restore error", message: "Something went wrong when restoring, please try again later.")
                self.indicator.stopAnimating()
                self.bgView?.isHidden = true
            }
        }
    }

    @objc private func handlePurchaseNotification(_ notification: Notification) {
        self.indicator.stopAnimating()
        self.bgView?.isHidden = true
        guard let productId = notification.object as? String else { return }
        guard productId == kGradePointPremiumProductId else {
            self.presentErrorAlert(title: "Purchase error", message: "Something went wrong when purchasing, please try again later.")
            self.indicator.stopAnimating()
            self.bgView?.isHidden = true
            return
        }

        self.presentInfoAlert(title: "Purchase completed", message: "Thanks for purchasing GradePoint premium!") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }


    // MARK: Deinit

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
