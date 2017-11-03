//
//  Address.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 28/09/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation

extension Address {
    func set(json: [String: Any]) {
        self.city = json["city"] as? String
        self.street = json["street"] as? String
        self.suite = json["suite"] as? String
        self.zipcode = json["zipcode"] as? String

        self.geo = Geo(context: self.managedObjectContext!)
        self.geo?.set(json: json["geo"] as! [String: Any])
    }
}

