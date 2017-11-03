//
//  Geo.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 28/09/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation

extension Geo {
    func set(json: [String: Any]) {
        self.lat = json["lat"] as? String
        self.lng = json["lng"] as? String
    }
}
