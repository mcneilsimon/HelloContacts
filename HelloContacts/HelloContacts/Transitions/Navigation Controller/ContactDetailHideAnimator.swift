//
//  ContactDetailHideAnimator.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-06-02.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit

/* This view / transition is nearly identical to the show transition. It also implements the UIViewControllerAnimatedTransitioning conformance protocol */

class ContactDetailHideAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let overviewViewController = toViewController as? ViewController,
            let selectedCell = overviewViewController.collectionView.indexPathsForSelectedItems?.first,
            let sourceCell = overviewViewController.collectionView.cellForItem(at: selectedCell) as? ContactCollectionViewCell
            else {
                return
        }
        
        let transitionContainer = transitionContext.containerView
        
        transitionContainer.addSubview(toViewController.view)
        transitionContainer.addSubview(fromViewController.view)
        
        let animationTiming = UICubicTimingParameters(animationCurve: .easeInOut)
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), timingParameters: animationTiming)
        
        animator.addAnimations {
            let imageFrame = sourceCell.contactImage.frame
            
            let targetFrame = overviewViewController.view.convert(imageFrame, from: sourceCell)
            
            fromViewController.view.frame = targetFrame
            fromViewController.view.layer.cornerRadius = sourceCell.contactImage.frame.height / 2
        }
        
        animator.addCompletion { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        animator.startAnimation()
    }
    
}
