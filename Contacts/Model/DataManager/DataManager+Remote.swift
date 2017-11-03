//
//  DataManager+Remote.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 01/11/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation

extension DataManager {
    class Remote {

        // MARK: Private Property(ies).

        private static let status = Reachability.networkReachabilityForInternetConnection()?.currentReachabilityStatus
        private static var session: URLSession {
            let session = URLSession(configuration: SessionManager.shared.sessionConfiguration, delegate: nil, delegateQueue: SessionManager.shared.operationQueue)
            return session
        }

        // MARK: Static Function(s).

        static func getUsers(onSuccess: @escaping ([User]) -> (), onError: ((Error) -> ())? = nil ) {
            if status != .notReachable {
                if let url = URL(string: "https://jsonplaceholder.typicode.com/users") {
                    var request = URLRequest(url:url)
                    request.timeoutInterval = 10
                    request.setValue("application/json", forHTTPHeaderField: "Accept")

                    session.dataTask(with: request, completionHandler: { (data, response, error) in
                        if let error = error {
                            onError!(error)
                        }

                        if let data = data {
                            let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                            var dataSource: [User] = []

                            json?.forEach {
                                let user = User(context: AppDelegate.viewContext)
                                user.set(json: $0)

                                do {
                                    try AppDelegate.viewContext.save()
                                } catch let error {
                                    onError!(error)
                                }

                                dataSource.append(user)
                            }

                            onSuccess(dataSource)
                        }
                    }).resume()
                }
            } else {
//                print("Sem conexão com a internet")
            }
        }

        static func getAlbum(by user: User, onSuccess: @escaping ([Album]) -> (), onError: ((Error) -> ())? = nil) {
            if status != .notReachable {
                if let url = URL(string: "https://jsonplaceholder.typicode.com/users/\(user.id)/albums") {
                    var request = URLRequest(url:url)
                    request.timeoutInterval = 10
                    request.setValue("application/json", forHTTPHeaderField: "Accept")

                    session.dataTask(with: request, completionHandler: { (data, response, error) in
                        if let error = error {
                            onError!(error)
                        }

                        if let data = data {
                            let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                            var dataSource: [Album] = []

                            json?.forEach {
                                let album = Album(context: AppDelegate.viewContext)
                                album.set(json: $0)
                                dataSource.append(album)
                            }

                            do {
                                user.album?.addingObjects(from: dataSource)
                                try AppDelegate.viewContext.save()
                            } catch let error {
                                onError!(error)
                            }

                            onSuccess(dataSource)
                        }
                    }).resume()
                }

            } else {
//                print("Sem conexão com a internet")
            }
        }

        static func getPhotos(by album: Album, onSuccess: @escaping ([Photo]) -> (), onError: ((Error) -> ())? = nil) {
            if status != .notReachable {
                if let url = URL(string: "https://jsonplaceholder.typicode.com/albums/\(album.id)/photos") {
                    var request = URLRequest(url:url)
                    request.timeoutInterval = 100
                    request.setValue("application/json", forHTTPHeaderField: "Accept")

                    URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                        if let error = error {
                            onError!(error)
                        }

                        if let data = data {
                            let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                            var dataSource: [Photo] = []

                            json?.forEach {
                                let photo = Photo(context: AppDelegate.viewContext)
                                photo.set(json: $0)

                                dataSource.append(photo)
                            }

                            do {
                                let set = NSSet(array: dataSource)
                                album.photo = set
                                try AppDelegate.viewContext.save()
                            } catch let error {
                                onError!(error)
                            }

                            onSuccess(dataSource)
                        }
                    }).resume()
                }

            } else {
//                print("Sem conexão com a internet")
            }
        }
    }
}

