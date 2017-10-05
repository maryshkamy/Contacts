//
//  Geo.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 28/09/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation

struct Geo: Codable {
    var lat: String
    var lng: String
}

extension GeoEntity {
    func toGeo() -> Geo {
        return Geo(lat: self.lat ?? "",
                   lng: self.lng ?? "")
    }
}
