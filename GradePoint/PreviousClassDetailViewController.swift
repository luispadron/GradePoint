//
//  PreviousClassDetailViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 7/10/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import CoreMotion

class PreviousClassDetailViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var gradeHolderView: UIView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    public var gradeString: String? = nil
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI setup
        bgView.layer.cornerRadius = 10
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 0)
        bgView.layer.shadowOpacity = 0.5
        bgView.layer.shadowRadius = 10.0
        
        gradeHolderView.layer.cornerRadius = gradeHolderView.frame.height / 2
        gradeHolderView.layer.shadowColor = UIColor.black.cgColor
        gradeHolderView.layer.shadowOffset = CGSize(width: 0, height: 0)
        gradeHolderView.layer.shadowOpacity = 0.8
        gradeHolderView.layer.shadowRadius = 8.0
        
        button.layer.cornerRadius = 10
        button.layer.backgroundColor = UIColor.highlight.cgColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.gradeLabel.text = self.gradeString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonWasTapped(_ sender: UIButton) {
    }
    
}
