//
//  User.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 21/09/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation

extension User {
    func set(json: [String: Any]) {
        self.email = json["email"] as? String
        self.id = json["id"] as! Int32
        self.name = json["name"] as? String
        self.phone = json["phone"] as? String
        self.username = json["username"] as? String
        self.website = json["website"] as? String

        self.address = Address(context: self.managedObjectContext!)
        self.address?.set(json: json["address"] as! [String: Any])
    }
}
