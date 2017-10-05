//
//  User.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 21/09/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation

struct User: Codable {
    var id: Int32
    var name: String
    var username: String
    var email: String
    var address: Address
    var phone: String
    var website: String
    var company: Company
}

extension UserEntity {
    func toUser() -> User {
        return User(id: self.id,
                    name: self.name ?? "",
                    username: self.username ?? "",
                    email: self.email ?? "",
                    address: self.address!.toAddress(),
                    phone: self.phone ?? "",
                    website: self.website ?? "",
                    company: self.company!.toCompany())
    }
}
