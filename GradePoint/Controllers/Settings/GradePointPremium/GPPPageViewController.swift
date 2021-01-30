//
//  GPPPageViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 1/31/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit

class GPPPageViewController: UIPageViewController {

    private(set) lazy var onboardControllers: [UIViewController] = {
        return [
            self.newOnboardingControlled(named: "GPPOnboarding1"),
            self.newOnboardingControlled(named: "GPPOnboarding3"),
            self.newOnboardingControlled(named: "GPPOnboarding4"),
            self.newOnboardingControlled(named: "GPPOnboarding5"),
            ]
    }()

    private var oldBackgroundColor: UIColor?

    private var backgroundColor: UIColor? {
        didSet {
            self.oldBackgroundColor = oldValue
            self.view.backgroundColor = self.backgroundColor
        }
    }

    // MARK: View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let firstVc = self.onboardControllers.first {
            self.setViewControllers([firstVc], direction: .forward, animated: true, completion: nil)
            self.view.backgroundColor = firstVc.view.backgroundColor?.lighter(by: 10)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Helpers

    private func newOnboardingControlled(named: String) -> UIViewController {
        return UIStoryboard(name: "GradePointPremium", bundle: nil).instantiateViewController(withIdentifier: named)
    }
}

// MARK: PageViewController DataSource & Delegate

extension GPPPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = onboardControllers.firstIndex(of: viewController) else { return nil }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0, onboardControllers.count > previousIndex else { return nil }

        return onboardControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = onboardControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1

        guard onboardControllers.count != nextIndex, onboardControllers.count > nextIndex else { return nil }

        return onboardControllers[nextIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let toVc = pendingViewControllers.first else { return }

        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = toVc.view.backgroundColor?.lighter(by: 10)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && !completed {
            UIView.animate(withDuration: 0.15) {
                self.backgroundColor = self.oldBackgroundColor
            }
        }
    }

    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        return .portrait
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.onboardControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstVc = self.onboardControllers.first, let firstIndex = self.onboardControllers.firstIndex(of: firstVc) else {
            return 0
        }

        return firstIndex
    }

}
