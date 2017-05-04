//
//  OnboardViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/19/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class OnboardPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    /// The controllers for the onboarding
    private(set) lazy var onboardControllers: [UIViewController] = {
        return
           [self.newOnboardController(with: "Onboard1"),
            self.newOnboardController(with: "Onboard2"),
            self.newOnboardController(with: "Onboard3"),
            self.newOnboardController(with: "Onboard4")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let firstVC = onboardControllers.first {
            self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
            self.view.backgroundColor = firstVC.view.backgroundColor?.lighter(by: 20)
        }
    }
    
    private var backgroundColor: UIColor? {
        didSet {
            self.oldColor = oldValue
            self.view.backgroundColor = self.backgroundColor
        }
    }
    
    private var oldColor: UIColor?
    
    // MARK: PageViewController DataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = onboardControllers.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0, onboardControllers.count > previousIndex else { return nil }
        
        return onboardControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = onboardControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard onboardControllers.count != nextIndex, onboardControllers.count > nextIndex else { return nil }
        
        // Special case if were trying to move to the next controller and were in oboarding 3, then we need to make sure values are filled
        if let vc = viewController as? Onboard3ViewController, !vc.isReadyToTransition { return nil }
        
        return onboardControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return onboardControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstVC = onboardControllers.first, let firstIndex = onboardControllers.index(of: firstVC) else {
            return 0
        }
        
        return firstIndex
    }
    
    // MARK: PageViewController Delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let toVC = pendingViewControllers.first else { return }
        
        // Set self as controller
        if let vc = toVC as? Onboard3ViewController {
            vc.pageController = self
        }
        // Set the background color for this pageviewcontroller, which in turn sets the page controls color
        UIView.animate(withDuration: 0.2) { 
            self.backgroundColor = toVC.view.backgroundColor?.lighter(by: 10)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && !completed {
            // Return to old color since user didnt go through with transition
            UIView.animate(withDuration: 0.15, animations: { 
                self.backgroundColor = self.oldColor
            })
        }
    }
    
    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: Helper methods
    
    private func newOnboardController(with id: String) -> UIViewController {
        return UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: id)
    }
}
