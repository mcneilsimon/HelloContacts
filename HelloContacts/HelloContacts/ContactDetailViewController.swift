//
//  ContactDetailViewController.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-05-24.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {

    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactPhoneLabel: UILabel!
    @IBOutlet weak var contactEmailLabel: UILabel!
    @IBOutlet weak var contactAddressLabel: UILabel!
    
    @IBOutlet weak var drawer: UIView!
    var isDrawerOpen = false
    var drawerPanStart: CGFloat = 0
    var animator: UIViewPropertyAnimator!

    var contactInfo: HCContact?
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let contact = self.contactInfo {
            contact.fetchImageIfNeeded()
            contactImage.image = contact.contactImage
            contactNameLabel.text = "\(contact.givenName) \(contact.familyName)"
            contactPhoneLabel.text = contact.phoneNumber
            contactEmailLabel.text = contact.emailAddress
            contactAddressLabel.text = contact.address
        }
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanOnDrawer(recognizer:)))
        drawer.addGestureRecognizer(panRecognizer)
        
        view.clipsToBounds = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
               selector: #selector(self.onKeyboardAppear(notifcation:)),
               name: .UIKeyboardWillShow,
               object: nil)
        
        NotificationCenter.default.addObserver(self,
           selector: #selector(self.onKeyboardHide(notifcation:)),
           name: .UIKeyboardWillHide,
           object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onKeyboardAppear(notifcation: NSNotification) {
        guard let userInfo = notifcation.userInfo, let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        scrollViewBottomConstraint.constant = keyboardFrameValue.cgRectValue.size.height
        
        UIView.animate(withDuration: TimeInterval(animationDuration), animations: {
            [weak self] in self?.view.layoutIfNeeded()
        })
    }
    
    @objc func onKeyboardHide(notifcation: NSNotification) {
        guard let userInfo = notifcation.userInfo,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        scrollViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: TimeInterval(animationDuration), animations: {
            [weak self] in self?.view.layoutIfNeeded()
        })
    }

}

//We use an extenion here so we can group together the animation code nicely
extension ContactDetailViewController {
    
    //Creates the bouncy animation effect when opening and closing our drawer.
    func setUpAnimation() {
        guard animator == nil || animator?.isRunning == false
            else { return }
        
        let spring: UISpringTimingParameters
        if self.isDrawerOpen {
            //A larger damping ratio makes the app feel less bouncy. Has to be a value between 0-1
            spring = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: 0, dy: 10))
        } else {
            spring = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: 0, dy: -10))
        }
        
        animator = UIViewPropertyAnimator(duration: 0.8, timingParameters: spring)
        
        animator.addAnimations { [unowned self] in
            if self.isDrawerOpen {
                //original state
                self.drawer.transform = CGAffineTransform.identity
            } else {
                //sets the height of the drawer when you tap on it.
                self.drawer.transform = CGAffineTransform(translationX: 0, y: -285)
            }
        }
        
        animator.addCompletion { [unowned self] _ in
            self.animator = nil
            //isDrawer back to false
            self.isDrawerOpen = !(self.drawer.transform == CGAffineTransform.identity)
        }
    }
    
    @IBAction func toggleDrawerTapped() {
        setUpAnimation()
        animator.startAnimation()
    }
    
    @objc func didPanOnDrawer(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            setUpAnimation()
            animator.pauseAnimation()
            drawerPanStart = animator.fractionComplete
        case .changed:
            if self.isDrawerOpen {
                animator.fractionComplete = (recognizer.translation(in: drawer).y / 305) + drawerPanStart
            } else {
                animator.fractionComplete = (recognizer.translation(in: drawer).y / -305) + drawerPanStart
            }
        default:
            drawerPanStart = 0
            let currentVelocity = recognizer.velocity(in: drawer)
            let spring = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: 0, dy: currentVelocity.y))
            
            animator.continueAnimation(withTimingParameters: spring, durationFactor: 0)
            let isSwipingDown = currentVelocity.y > 0
            if isSwipingDown == !isDrawerOpen {
                animator.isReversed = true
            }
        }
    }
}
















