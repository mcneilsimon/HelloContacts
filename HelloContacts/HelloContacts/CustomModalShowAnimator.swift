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
        return 0.5
    }
    
    /*  This methods purpose is to take care of the actual animation for the custom transition. Our implementation will take the target view controller animate its view from the top down to its final position.
        It will also do a little bit of scaling, and the opacity for the view will also be animated; to do this we will
        use UIViewPropertyAnimator. */
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        /* optains a reference to the target view controller from the context. Then view that will contain the transition is fetched
           and the final frame for the target view controller is read.. */
        guard let toViewController =  transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        
        let transitionContainer = transitionContext.containerView
        
        

        //let pos = toViewController.view.frame.minX
        //let pos1 = toViewController.view.frame.maxY

        
        //the next three lines of code is to set up the intial frame for the target view controller. This is the position for which the animation will start
        var transform = CGAffineTransform.identity
        transform = transform.concatenating(CGAffineTransform(scaleX: 0, y: 1))
        transform = transform.concatenating(CGAffineTransform(translationX: 0, y: 0))
        
        toViewController.view.transform = transform
        toViewController.view.alpha = 0
        
        /* target view is added to the transitionContainter and the actual transition is implemented. Once the animation completes, the
           completeTransition(_:) method is called on the context to inform it that the transition is finished. */
        transitionContainer.addSubview(toViewController.view)
        
        
        let animationTiming = UISpringTimingParameters(dampingRatio: 1)
        
        
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














