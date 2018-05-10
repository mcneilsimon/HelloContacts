//
//  ViewController.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-05-08.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UIViewController {

    var contacts = [HCContact]()
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    }
    
    //Responsible for fetching the contacts.
    func retrieveContacts(fromStore store: CNContactStore) {
        
        /*These lists of keys represent properties that a contact object can have. Each property represents a piece of data. */
        let keysToFetch = [
            CNContactGivenNameKey as CNKeyDescriptor, //gets contact name
            CNContactFamilyNameKey as CNKeyDescriptor, //gets contact family name
            CNContactImageDataKey as CNKeyDescriptor, //gets contacts image.
            CNContactImageDataAvailableKey as CNKeyDescriptor //checks if contact image is available
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
        
        let confirmDialog = UIAlertController(title: "Delete This Contact?", message: "Are You Sure You Want To Delete This Contact?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            self.contacts.remove(at: tappedIndexPath.row)
            self.collectionView.deleteItems(at: [tappedIndexPath])
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        confirmDialog.addAction(deleteAction)
        confirmDialog.addAction(cancelAction)
        
        if let popOver = confirmDialog.popoverPresentationController {
            popOver.sourceView = tappedCell
        }
        present(confirmDialog, animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDataSource {
    
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
}

/* This delegate protocol allows you to implement a few customization points for the layout.
 For instance, you can dynamically calculate cell sizes or manipulate the cell spacing. */
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    /* Delegate method that we need to implement in order to provide dynamic cell sizes. Simply return a cell size width and height.
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 160)
    }
    
    //creates the spacing between cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let cellsPerRow: CGFloat = 3
        let widthReminder = (collectionView.bounds.width - (cellsPerRow-1)).truncatingRemainder(dividingBy: cellsPerRow) / (cellsPerRow-1)
        return 1 + widthReminder
    }
    
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /* First thing to note is that we can ask UICollectionView for a cell based on the IndexPath. The cellForItem method returns an
           optional UICollectionViewCell. There might not be a cell at the requested IndexPath; if this is the case cellForItem returns nil, otherwise
           a UICollectionView cell instance is returned */
        guard let cell = collectionView.cellForItem(at: indexPath) as? ContactCollectionViewCell else {return }
        
        //The following animation code produces an ease in ease out when a user taps on a contact in the collection view
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            cell.contactImage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { finished in
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
                cell.contactImage.transform = CGAffineTransform.identity
            }, completion: nil)
        })

    }
}



























