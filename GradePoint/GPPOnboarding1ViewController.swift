//
//  GPPOnboarding1ViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 1/31/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit

class GPPOnboarding1ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Get price dynamically
        GradePointPremium.store.requestProducts { (success, products) in
            if let product = products?.first, success {
                let price = product.price.floatValue
                DispatchQueue.main.async {
                    self.titleLabel.text = "GradePoint Premium\n$\(price)"
                }
            }
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }


    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
