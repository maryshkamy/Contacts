//
//  ContactTableViewController.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 21/09/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import UIKit
import CoreData

class ContactTableViewController: UITableViewController {
    var jsonData = Data()
    var users = [User]()

    var container: NSPersistentContainer = AppDelegate.persistentContainer {
        didSet {
            self.updateUI()
        }
    }

    private var sessionConfiguration: URLSessionConfiguration {
        let cfg = URLSessionConfiguration.default
        cfg.allowsCellularAccess = true
        cfg.networkServiceType = .default
        cfg.requestCachePolicy = .returnCacheDataElseLoad
        cfg.isDiscretionary = true
        cfg.urlCache = URLCache(memoryCapacity: 2048, diskCapacity: 10240, diskPath: NSTemporaryDirectory())
        return cfg
    }

    private var operationQueue: OperationQueue {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 5
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        return queue
    }

    private var session: URLSession {
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: operationQueue)
        return session
    }

    fileprivate var fetchedResultsController: NSFetchedResultsController<UserEntity>?

    private func updateUI() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true, selector: nil)]

        self.fetchedResultsController = NSFetchedResultsController<UserEntity>(fetchRequest: request, managedObjectContext: self.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        self.fetchedResultsController?.delegate = self
        try? self.fetchedResultsController?.performFetch()

        do {
            let entities = try! self.container.viewContext.fetch(request)
            self.users = entities.map({ $0.toUser() })
        }

        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let reachabilityStatus = Reachability.networkReachabilityForInternetConnection()?.currentReachabilityStatus
        if reachabilityStatus == .notReachable {
            print("Offline")
            self.updateUI()
        } else {
            print("Online")
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            if let url = URL(string: "https://jsonplaceholder.typicode.com/users") {
                var request = URLRequest(url:url)
                request.timeoutInterval = 10
                request.setValue("application/json", forHTTPHeaderField: "Accept")

                let dataTask = session.dataTask(with: request)
                dataTask.resume()
            }
        }

        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        if let user = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.username
        }
        
        return cell
    }
}

extension ContactTableViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        jsonData.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        do {
            let decoder = JSONDecoder()
            users = try decoder.decode([User].self, from: jsonData)

            let dao = UserDAO()
            dao.saveData(users: users, withPersistentContainer: container)

            DispatchQueue.main.async { [unowned self] in
                do {
                    try AppDelegate.viewContext.save()
                    self.container = AppDelegate.persistentContainer
                }
                catch {
                    print("Erro ao salvar o contexto ")
                }

                self.updateUI()
                print("Atualizando dados")
            }
        }catch {
            debugPrint(error)
        }
    }
}

extension ContactTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections([sectionIndex], with: .fade)
        case .delete:
            tableView.deleteSections([sectionIndex], with: .fade)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension UserEntity {
    func toUser() -> User {
        return User(id: self.id,
                    name: self.name ?? "",
                    username: self.username ?? "",
                    email: self.email ?? "",
                    address: self.address!.toAddress(),
                    phone: self.phone ?? "",
                    website: self.website ?? "",
                    company: self.company!.toCompany())
    }
}

extension AddressEntity {
    func toAddress() -> Address {
        return Address(street: self.street ?? "",
                       suite: self.suite ?? "",
                       city: self.city ?? "",
                       zipcode: self.zipcode ?? "",
                       geo: self.geo!.toGeo())
    }
}

extension GeoEntity {
    func toGeo() -> Geo {
        return Geo(lat: self.lat ?? "",
                   lng: self.lng ?? "")
    }
}

extension CompanyEntity {
    func toCompany() -> Company {
        return Company(name: self.name ?? "",
                       catchPhrase: self.catchPhrase ?? "",
                       bs: self.bs ?? "")
    }
}
