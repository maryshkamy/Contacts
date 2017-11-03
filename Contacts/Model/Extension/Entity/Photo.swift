//
//  Photo.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 25/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation

extension Photo {
    func set(json: [String: Any]) {
        self.id = json["id"] as! Int32
        self.title = json["title"] as? String
        self.url = json["url"] as? String
        self.thumbnailUrl = json["thumbnailUrl"] as? String
    }
}
