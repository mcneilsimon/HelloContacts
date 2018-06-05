//
//  CustomModalHideAnimator.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-06-01.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit

/*This class implementes convenience methods to easily update the interactive transition. It also conforms to UIViewControllerInteractiveTransitioning
  so we don't have to add conformance ourselves. */
class CustomModalHideAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    
    let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
        
        let panGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(gestureReconizer:)))
        
        panGesture.edges = .left //implements the swipe left gesture
        viewController.view.addGestureRecognizer(panGesture)
    }
    
    
    
    /* This method figures out the distance that is swiped. Then the state of the gesture is checked. If the user just started the guesture, we
       tell the view controller to dismiss it. This will trigger the sequence of steps that was outlined before and will start the
       interactive dismissal */
    @objc func handleEdgePan(gestureReconizer: UIScreenEdgePanGestureRecognizer) {
        let panTranslation = gestureReconizer.translation(in: viewController.view)
        let animationProgress = min(max(panTranslation.x / 200, 0.0), 1.0)
        
        switch gestureReconizer.state {
        case .began:
            viewController.dismiss(animated: true, completion: nil)
        case .changed:
            //the update method comes from the UIPercentDrivenInteracticeTransition
            update(animationProgress)
            break
        case .ended:
            //If the gesture ended, we check the progress made so far. If there is enough we finish the transition, if not we cancel it.
            if animationProgress < 0.5 {
                cancel()
            } else{
                finish()
            }
            break
        default:
            cancel()
            break
        }
        
    }
    
    
    /* The next two functions are the exact ones you see in CustomModalShowAnimator, but the code inside them is just the reverse.
       So the animation knows to do the reverse of it self when the user swipes left */
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {return}
        
        let transitionContainer = transitionContext.containerView
        
        transitionContainer.addSubview(toViewController.view)
        transitionContainer.addSubview(fromViewController.view)
        
        let animationTiming = UISpringTimingParameters(dampingRatio: 1)
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), timingParameters: animationTiming)
        
        animator.addAnimations {
            var transform = CGAffineTransform.identity
            transform = transform.concatenating(CGAffineTransform(scaleX: 1, y: 0.1))
            transform = transform.concatenating(CGAffineTransform(translationX: 0, y: 20))
            
            fromViewController.view.transform = transform
            fromViewController.view.alpha = 0
        }
        
        animator.addCompletion { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        animator.startAnimation()
    }

}





