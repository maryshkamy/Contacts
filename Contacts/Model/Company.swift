//
//  Company.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 28/09/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation

struct Company: Codable {
    var name: String
    var catchPhrase: String
    var bs: String
}

extension CompanyEntity {
    func toCompany() -> Company {
        return Company(name: self.name ?? "",
                       catchPhrase: self.catchPhrase ?? "",
                       bs: self.bs ?? "")
    }
}
