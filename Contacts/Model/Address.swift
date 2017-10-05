//
//  Address.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 28/09/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation

struct Address: Codable {
    var street: String
    var suite: String
    var city: String
    var zipcode: String
    var geo: Geo
}

extension AddressEntity {
    func toAddress() -> Address {
        return Address(street: self.street ?? "",
                       suite: self.suite ?? "",
                       city: self.city ?? "",
                       zipcode: self.zipcode ?? "",
                       geo: self.geo!.toGeo())
    }
}
