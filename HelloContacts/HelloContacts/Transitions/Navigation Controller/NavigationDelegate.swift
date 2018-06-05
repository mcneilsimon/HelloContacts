//
//  NavigationDelegate.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-06-02.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit

/* This delegate is responbile for providing animations and managing interaction back gesture. */
class NavigationDelegate: NSObject, UINavigationControllerDelegate {
    
    let navigationController: UINavigationController
    var interactiveController: UIPercentDrivenInteractiveTransition?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
        
        navigationController.view.addGestureRecognizer(panRecognizer)
    }
    
    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = self.navigationController.view else { return }
        
        switch gestureRecognizer.state {
        case .began:
            let location = gestureRecognizer.location(in: view)
            if location.x < view.bounds.midX && navigationController.viewControllers.count > 1{
                interactiveController = UIPercentDrivenInteractiveTransition() //interactiveController begins
                navigationController.popViewController(animated: true)
            }
            break
        case .changed:
            let panTranslation = gestureRecognizer.translation(in: view)
            let animationProgress = fabs(panTranslation.x / view.bounds.width)
            interactiveController?.update(animationProgress)
            break
        default:
            if gestureRecognizer.velocity(in: view).x > 0{
                interactiveController?.finish()
            } else {
                //destroy interactiveController when the gesture ends.
                interactiveController?.cancel()
            }
            interactiveController = nil
        }
    }
    
    /*The two below methods are responsible for providing the required objects for the animations */
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop {
            return ContactDetailHideAnimator()
        } else {
            return ContactDetailShowAnimator()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveController
    }
}






