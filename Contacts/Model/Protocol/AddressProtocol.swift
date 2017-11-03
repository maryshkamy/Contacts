//
//  AddressProtocol.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 14/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation
import CoreLocation

protocol AddressProtocol {
    func didReceive(placemark: CLPlacemark?)
}
