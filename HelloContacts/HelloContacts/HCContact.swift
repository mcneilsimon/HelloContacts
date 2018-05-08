//
//  HCContact.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-05-08.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class HCContact {
    private let contact: CNContact
    var contactImage: UIImage?
    
    // the following two scopes use two things called computer properties to provide a proxy to the CNContact istance that is stored in this class.
    var givenName: String {
        return contact.givenName
    }
    
    var familyName: String {
        return contact.familyName
    }
    
    init(contact: CNContact) {
        self.contact = contact
    }
    
    /* This method performs the decoding of the image data. It makes sense that the stored contact has image data
       available and it checks whether the contact image isn't set yet. If this is the case, the image data is decoded and
       assigned to the contactImage. The next time this method is called nothing will happen because contactImage,
       won't be nil since the prefetching already did its job.
     */
    func fetchImageIfNeeded() {
        if let imageData = contact.imageData, contactImage == nil {
            contactImage = UIImage(data: imageData)
        }
    }
}


