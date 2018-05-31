//
//  CustomModalShowAnimator.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-05-31.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit


/*
 This animation controller is a separate object that conforms to UIViewControllerAnimatedTransition, and it will take
 care of animating the presented view onto the screen.
 
 In order to achieve the previous statement, this class will act as are animation controller that's responsible for
 performing our animation. It will act as both the transitioning delegate and the animation controller.
*/

class CustomModalShowAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    //The time interval that we want are transition to last
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    /*  This methods purpose is to take care of the actual animation for the custom transition. Our implementation will take the target view controller animate its view from the top down to its final position.
        It will also do a little bit of scaling, and the opacity for the view will also be animated; to do this we will
        use UIViewPropertyAnimator.
     */
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController =  transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        
        let transitionContainer = transitionContext.containerView
        
        var transorm = CGAffineTransform.identity
        transorm = transorm.concatenating(CGAffineTransform(scaleX: 0.6, y: 0.6 ))
        transorm = transorm.concatenating(CGAffineTransform(scaleX: 0, y: -200))
        
        toViewController.view.transform = transorm
        toViewController.view.alpha = 0
        
        transitionContainer.addSubview(toViewController.view)
        
        let animationTiming = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: 1, dy: 0))
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), timingParameters: animationTiming)
        
        animator.addAnimations {
            toViewController.view.transform = CGAffineTransform.identity
            toViewController.view.alpha = 1
        }
        
        animator.addCompletion { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        animator.startAnimation()
    }
}














