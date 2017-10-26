//
//  UserAlbums.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 25/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation

struct Photos: Codable {
    var albumId: Int32
    var id: Int32
    var title: String
    var url: String
    var thumbnailUrl: String
}
