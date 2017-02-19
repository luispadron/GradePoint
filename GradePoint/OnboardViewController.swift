//
//  OnboardViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/19/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class OnboardViewController: UIPageViewController, UIPageViewControllerDataSource {

    /// The controllers for the onboarding
    private(set) lazy var onboardControllers: [UIViewController] = {
        return [self.newOnboardController(with: "Onboard1"),
                self.newOnboardController(with: "Onboard2")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        if let firstVC = onboardControllers.first {
            self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
    }

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
    
    
    
    // MARK: Helper methods
    
    private func newOnboardController(with id: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: id)
    }
}
