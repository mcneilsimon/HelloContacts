//
//  ContactDetailShowAnimator.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-06-02.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit

/* Responsible for the show transition. Implementes the UIVIewControllerAnimatedTransitioning Protocol */
class ContactDetailShowAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    //for the duration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    //for the animation
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        /* The first block of code shows how we're extracting informtion about the tapped cell by casting the fromViewController
           to an instance of ViewController, the view controller that contains the overview page. We ask its collection view for the selected path
           and use that to extract a cell. */
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
        let overViewController = fromViewController as? ViewController,
        let selectedCell = overViewController.collectionView.indexPathsForSelectedItems?.first,
        let sourceCell = overViewController.collectionView.cellForItem(at: selectedCell) as? ContactCollectionViewCell else { return }
        
        let transitionContainer = transitionContext.containerView
        let toEndFrame = transitionContext.finalFrame(for: toViewController)
        let imageFrame = sourceCell.contactImage.frame
        let targetFrame = overViewController.view.convert(imageFrame, from: sourceCell)
        
        /* Gives the target rounded corners so as to aid in the zooming-in effect. The animation is set up to remove the rounded corners
           and to adjust the frame to the planned end frame. */
        toViewController.view.frame = targetFrame
        toViewController.view.layer.cornerRadius = sourceCell.frame.height / 2
        
        
        transitionContainer.addSubview(toViewController.view)
        
        let animationTiming = UICubicTimingParameters(animationCurve: .easeInOut)
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), timingParameters: animationTiming)
        
        animator.addAnimations {
            toViewController.view.frame = toEndFrame
            toViewController.view.layer.cornerRadius = 0
        }
        
        animator.addCompletion { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        animator.startAnimation()
    }
    
    
}
