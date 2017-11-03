//
//  DataManager+Local.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 01/11/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import CoreData
import Foundation

class DataManager {
    class Local {

        enum OrderBy: String {
            case name = "name"
            case id = "id"
            case username = "username"
        }

        static func getUsers(orderBy: OrderBy = .name, onSuccess: @escaping ([User]) -> (), onError: ((Error) -> ())? = nil, onFinally: (() -> ())? = nil) {
            do {
                let request: NSFetchRequest<User> = User.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: orderBy.rawValue, ascending: true)]

                let result: NSFetchedResultsController<User> = NSFetchedResultsController<User>(fetchRequest: request, managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: nil, cacheName: nil)

                try result.performFetch()
                let users = try AppDelegate.viewContext.fetch(request)

                onSuccess(users)
            } catch let error {
                onError!(error)
            }

            onFinally!()
        }

        static func getUser(by id: Int32, _ completionHandler: @escaping (User?) -> ()) {
            getUsers(onSuccess: { (users) in
                let user = users.first(where: { (user) -> Bool in
                    user.id == id
                })

                completionHandler(user)
            })
        }
    }
}
