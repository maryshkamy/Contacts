//
//  UserDAO.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 28/09/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import UIKit
import CoreData

struct UserDAO {
    func saveData(users: [User], withPersistentContainer persistentContainer: NSPersistentContainer) {
        persistentContainer.performBackgroundTask { (context) in
            do {
                for user in users {
                    let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
                    userFetchRequest.predicate = NSPredicate(format: "id == %d", user.id)

                    let usersInCore = try context.fetch(userFetchRequest)

                    if usersInCore.count == 0 {
                        let userData = UserEntity(context: context)

                        userData.id = user.id
                        userData.name = user.name
                        userData.username = user.username
                        userData.email = user.email
                        userData.phone = user.phone
                        userData.website = user.website

                        let companyData = CompanyEntity(context: context)
                        companyData.name = user.company.name
                        companyData.catchPhrase = user.company.catchPhrase

                        let addressData = AddressEntity(context: context)
                        addressData.street = user.address.street
                        addressData.suite = user.address.suite
                        addressData.city = user.address.city
                        addressData.zipcode = user.address.zipcode

                        let geoData = GeoEntity(context: context)
                        geoData.lat = user.address.geo.lat
                        geoData.lng = user.address.geo.lng

                        addressData.geo = geoData
                        userData.address = addressData
                        userData.company = companyData

                        try context.save()
                    }
                }
            }catch {
                debugPrint(error)
            }
        }
    }
}
