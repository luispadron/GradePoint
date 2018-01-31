//
//  GameViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 1/30/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import SpriteKit
import UIKit

class GameViewController: UIViewController {

    // MARK: View life cycle
    private lazy var skView: SKView = {
        let view = SKView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up sprite kit view
        if !self.view.subviews.contains(skView) {
            self.view.addSubview(skView)
            self.skView.frame = self.view.frame
        }
        self.skView.showsFPS = true
        self.skView.showsNodeCount = false
        self.skView.ignoresSiblingOrder = false
        // Setup scene
        let scene = GameScence(size: self.view.bounds.size)
        scene.scaleMode = .resizeFill
        scene.gameController = self

        self.skView.presentScene(scene)
    }


    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
