//
//  GPPOnboarding5ViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 1/31/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit

class GPPOnboarding5ViewController: UIViewController {

    private lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        return view
    }()

    @IBOutlet weak var purchaseButton: UIButton!

    // MARK: View lify cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePurchaseNotification),
                                               name: NSNotification.Name(rawValue: IAPManager.IAPManagerPurchaseNotification),
                                               object: nil)
        self.view.addSubview(self.indicator)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.purchaseButton.layer.cornerRadius = self.purchaseButton.frame.height / 2
        self.purchaseButton.clipsToBounds = true
        self.indicator.center = self.view.center
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: Actions

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.indicator.stopAnimating()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func purchasedButtonTapped(_ sender: UIButton) {
        self.indicator.startAnimating()
        GradePointPremium.purchase { success in
            if !success {
                self.presentErrorAlert(title: "Purchase error", message: "Something went wrong when purchasing, please try again later.")
            }
        }
    }
    
    @IBAction func restorePurchasedButtonTapped(_ sender: UIButton) {
        self.indicator.startAnimating()
        GradePointPremium.store.restorePurchases()
    }

    @objc private func handlePurchaseNotification(_ notification: Notification) {
        self.indicator.stopAnimating()

        guard let productId = notification.object as? String else { return }
        guard productId == gradePointPremiumProductId else {
            self.presentErrorAlert(title: "Purchase error", message: "Something went wrong when purchasing, please try again later.")
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
