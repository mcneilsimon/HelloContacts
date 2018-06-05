//
//  BounceAnimationHelper.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-06-05.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit

struct BounceAnimationHelper {
    typealias BounceAnimationComplete = (UIViewAnimatingPosition) -> Void
    
    //UIViewPropertyAnimator so we can tell it to start animating whenever the helper's startAnimation method is called
    var animator: UIViewPropertyAnimator
    
    //The first initializer calls out to the second with a default duration value of 0.4
    init(targetView: UIView, onComplete: @escaping BounceAnimationComplete) {
        self.init(targetView: targetView, onComplete: onComplete, duration: 0.3)
    }
    
    
    /* The following animation code produces an ease in ease out when a user taps on a contact in the collection view. downAnimator and
     upAnimator declaration are the actual animation property. downAnimator and upAnimator.addCompletion() talk to each other by saying
     what the next action should be when their animation is fnished They create the instances of UIViewPropertyAnimator. downAnimator.startAnimation()
     starts the animation */
    init(targetView: UIView, onComplete: @escaping BounceAnimationComplete, duration: TimeInterval) {
        
        let downAnimationTiming = UISpringTimingParameters(dampingRatio: 1, initialVelocity: CGVector(dx: 0, dy: 0))
        
        self.animator = UIViewPropertyAnimator(duration: duration, timingParameters: downAnimationTiming)
        
        self.animator.addAnimations {
            targetView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        
        self.animator.addCompletion { position in
            let upAnimationTiming = UISpringTimingParameters(dampingRatio: 1, initialVelocity:CGVector(dx: 0, dy: 0))
            let upAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: upAnimationTiming)
            
            upAnimator.addAnimations {
                //image goes back to its regular form when upAnimator is finished
                targetView.transform = CGAffineTransform.identity
            }
            
            upAnimator.addCompletion(onComplete)
            
            upAnimator.startAnimation()
        }
    }
    
    func startAnimation() {
        animator.startAnimation()
    }
}
