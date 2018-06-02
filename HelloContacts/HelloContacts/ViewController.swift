//
//  ViewController.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-05-08.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit
import Contacts

/* UICollectionView Delegate Flow Layout:
    -This delegate protocol allows you to implement a few customization points for the layout.
     For instance, you can dynamically calculate cell sizes or manipulate the cell spacing. */



class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var contacts = [HCContact]()
    var navigationDelegate: NavigationDelegate?
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: override func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //Uncomment if you want to use the ContactsCollectionViewLayoutClass
        //collectionView.collectionViewLayout = ContactsCollectionViewLayout()
        
        //object that will access the user's conctact database
        let store = CNContactStore()
        
        //checks if user has given us permission to access their contacts list
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        //check if notDetermined meaning we havn't asked the user permission yet.
        if authorizationStatus == .notDetermined {
            
            /* When asking for permission we make use of a completion handler (closure).
             Completion handlers are used when you perform a task that could take a while and is performed parallel to
             the rest of the your application, so the user interface can continue running without waiting for the result. */
            store.requestAccess(for: .contacts, completionHandler: { [weak self] authorized, error in
                if authorized {
                    self?.retrieveContacts(fromStore: store)
                }
            })
        } else if authorizationStatus == .authorized {
            retrieveContacts(fromStore: store)
        }
        
        /* Implementing are gesture reconizer, with its target being self. Remember self means that the current instance of our view controller
            is the object that is called whenever the long-press is detected. The second object is a selector. A selector is roughly the same as
            a reference to a method. It tells the long-press gesture recognizer that it should call the part between the parentheses on the
            target that was specified.
         */
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.recieveLongPress(gestureReconizer:)))
        collectionView.addGestureRecognizer(longPressRecognizer)
        navigationItem.leftBarButtonItem = editButtonItem
        
        
        //checks the current trait collection so that the environment supports 3D touch
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: collectionView)
        }
        
        if let navigationController = self.navigationController {
            navigationDelegate = NavigationDelegate(navigationController: navigationController)
            navigationController.delegate = navigationDelegate
        }

    }
    
    //Passes data from the overview to the contact detail page.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let contactDetailVC = segue.destination as? ContactDetailViewController, segue.identifier == "detailViewSegue",
            let selectedIndex = collectionView.indexPathsForSelectedItems?.first {
            contactDetailVC.contactInfo = contacts[selectedIndex.row]
        }
        //indexPathForSelectedItems get the total amount of selected items, in this case it will only be one.
    }
    
    //Responsible for fetching the contacts.
    func retrieveContacts(fromStore store: CNContactStore) {
        
        /*These lists of keys represent properties that a contact object can have. Each property represents a piece of data. */
        let keysToFetch = [
            CNContactGivenNameKey as CNKeyDescriptor, //gets contact name
            CNContactFamilyNameKey as CNKeyDescriptor, //gets contact family name
            CNContactImageDataKey as CNKeyDescriptor, //gets contacts image.
            CNContactImageDataAvailableKey as CNKeyDescriptor, //checks if contact image is available
            CNContactEmailAddressesKey as CNKeyDescriptor, //gets contacts email
            CNContactPhoneNumbersKey as CNKeyDescriptor, //gets phoneNumber
            CNContactPostalAddressesKey as CNKeyDescriptor //gets contacts address
        ]
        
        //gets all types of contacts
        var allContainers: [CNContainer] = []
        do {
            allContainers = try store.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        for container in allContainers {
            //When fetching a list of contacts we use a predicate. It's main purpose is to set up a filter for the contacts database.
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            do {
                //unifiedContact gets the contact information according to the predicate we set and the keys we created.
                let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch).map {
                    contact in return HCContact(contact: contact)
                }
                contacts.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func recieveLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        let tappedPoint =  gestureReconizer.location(in: collectionView)
        
        /*First asks the collectionView for the index path that it belong to this point (tappedIndexPath). The found index path is then used
          to find out which cell was tapped (tappedCell) So first it check tappedIndexPath and then tappedCell uses tappedIndexPath if it doesn't
          produc nil */
        guard let tappedIndexPath = collectionView.indexPathForItem(at: tappedPoint),
            let tappedCell = collectionView.cellForItem(at: tappedIndexPath) else { return }
        
        if isEditing {
            reorderContact(withCell: tappedCell, atIndexPath: tappedIndexPath, gesture: gestureReconizer)
        } else {
            deleteContact(withCell: tappedCell, atIndexPath: tappedIndexPath)
        }
    }
    
    func reorderContact(withCell cell: UICollectionViewCell, atIndexPath indexPath: IndexPath, gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            collectionView.beginInteractiveMovementForItem(at: indexPath)
            
            let downAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
                cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }            
            downAnimator.startAnimation()
            break
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
            break
        case .ended:
            collectionView.endInteractiveMovement()
            break
        default:
            collectionView.cancelInteractiveMovement()
            break
        }
    }
    
    func deleteContact(withCell cell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
        let confirmDialog = UIAlertController(title: "Delete This Contact?", message: "Are You Sure You Want To Delete This Contact?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            self.contacts.remove(at: indexPath.row)
            self.collectionView.deleteItems(at: [indexPath])
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        confirmDialog.addAction(deleteAction)
        confirmDialog.addAction(cancelAction)
        
        if let popOver = confirmDialog.popoverPresentationController {
            popOver.sourceView = cell
            
            if let cell = cell as? ContactCollectionViewCell {
                let imageFrame = cell.contactImage.frame
                
                let popOverX = imageFrame.origin.x + imageFrame.size.width / 2
                let popOverY = imageFrame.origin.y + imageFrame.size.height / 2
                
                popOver.sourceRect = CGRect(x: popOverX, y: popOverY, width: 0, height: 0)
            }
        }
        
        present(confirmDialog, animated: true, completion: nil)
    }
    
    //Changes the background color of the cells when collection view is in edit mode
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        for visibleCell in collectionView.visibleCells {
            guard let cell = visibleCell as? ContactCollectionViewCell else { continue }
            
            if editing {
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                    cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                    cell.backgroundColor = .clear
                }, completion: nil)
            }
        }
    }
    
    //Gets the count of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "contactCell", for: indexPath) as! ContactCollectionViewCell
        
        let contact = contacts[indexPath.row]
        
        
        cell.nameLabel.text = "\(contact.givenName)\n\(contact.familyName)"
        
        contact.fetchImageIfNeeded() //sets the image in the HCContact class
        //gets the image property in the HCContact class
        if let image = contact.contactImage {
            cell.contactImage.image = image
        }
        return cell
    }
    
    //Tells the collection view whether it's okay for a certain item to be moved around
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Responsilbe for updating the underlying data source based on the new cell order
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedContact = contacts.remove(at: sourceIndexPath.row)
        contacts.insert(movedContact, at: destinationIndexPath.row)
    }
    
    /* Delegate method that we need to implement in order to provide dynamic cell sizes. Simply return a cell size width and height.
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 160)
    }
    
    //creates the spacing between cells, this sets it so that each collection view will display 3 cells no matter what screen size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let cellsPerRow: CGFloat = 3
        let widthReminder = (collectionView.bounds.width - (cellsPerRow-1)).truncatingRemainder(dividingBy: cellsPerRow) / (cellsPerRow-1)
        return 1 + widthReminder
    }
    
    //when user taps on a cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /* First thing to note is that we can ask UICollectionView for a cell based on the IndexPath. The cellForItem method returns an
         optional UICollectionViewCell. There might not be a cell at the requested IndexPath; if this is the case cellForItem returns nil, otherwise
         a UICollectionView cell instance is returned */
        guard let cell = collectionView.cellForItem(at: indexPath) as? ContactCollectionViewCell else {return }
        
        /*The following animation code produces an ease in ease out when a user taps on a contact in the collection view. downAnimator and
          upAnimator declaration are the actual animation property. downAnimator and upAnimator.addCompletion() talk to each other by saying
          what the next action should be when their animation is fnished They create the instances of UIViewPropertyAnimator. downAnimator.startAnimation()
         starts the animation */
        let downAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            cell.contactImage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        
        let upAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeIn) {
            cell.contactImage.transform = CGAffineTransform.identity
        }
        
        downAnimator.addCompletion { _ in
            upAnimator.startAnimation()
        }
        
        upAnimator.addCompletion { [weak self] _ in
            self?.performSegue(withIdentifier: "detailViewSegue", sender: self)
        }
        
        /* Need completion closure before calling this. Once this is called, the animation is started automatically. You can also delay the start of animation
           by doing startAnimation(afterDelay:) */
        downAnimator.startAnimation()
    }
}

//MARK: 3D touch protocols
extension ViewController: UIViewControllerPreviewingDelegate {
    
    /* Responsible for providing the previewed view controller. This is done by figuring out the tapped item in the collectionView. Next a
       view controller is obtained through the storyoard by using the identifier. Then a vc is assigned a contact and returned for previewing. */
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let tappedIndexPath = collectionView.indexPathForItem(at: location) else {return nil}
        
        let contact = contacts[tappedIndexPath.row]
        
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "ContactDetailViewController") as? ContactDetailViewController else { return nil}
        
        viewController.contactInfo = contact
        
        return viewController
    }
    
    //Simply tells the navigation controller to present the view controller that was previewed. 
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.show(viewControllerToCommit, sender: self)
    }
    
    
}

























