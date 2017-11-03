//
//  Company.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 28/09/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation

extension Company {
    func set(json: [String: Any]) {
        self.bs = json["bs"] as? String
        self.catchPhrase = json["catchPhrase"] as? String
        self.name = json["name"] as? String
    }
}
