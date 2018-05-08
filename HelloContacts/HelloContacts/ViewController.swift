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
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "contactCell", for: indexPath) as! ContactCollectionViewCell
        
        let contact = contacts[indexPath.row]
        
        cell.nameLabel.text = "\(contact.givenName) \(contact.familyName)"
        
        contact.fetchImageIfNeeded() //sets the image in the HCContact class
        //gets the image property in the HCContact class
        if let image = contact.contactImage {
            cell.contactImage.image = image
        }
        return cell
    }
}











