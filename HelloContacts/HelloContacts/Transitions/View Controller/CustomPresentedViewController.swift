//
//  CustomPresentedViewController.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-05-31.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit

class CustomPresentedViewController: UIViewController {

    var hideAnimator: CustomModalHideAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        transitioningDelegate = self
        //creates an instance of CustomModalHideAnimator and binds the view controller to it by passing it to the init
        hideAnimator = CustomModalHideAnimator(viewController: self)
    }
    
}

//This code assigns the view controller as its own transition delegate
extension CustomPresentedViewController: UIViewControllerTransitioningDelegate {
    

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //Returns the animation controller you created before. This nicely seperates code and keeps files clean.
        return CustomModalShowAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return hideAnimator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return hideAnimator
    }
}
