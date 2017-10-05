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

    var users = [User]() {
        willSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    var container: NSPersistentContainer = AppDelegate.persistentContainer {
        didSet {
            self.updateUI()
        }
    }

    private var session: URLSession {
        let session = URLSession(configuration: SessionManager.shared.sessionConfiguration, delegate: self, delegateQueue: SessionManager.shared.operationQueue)
        return session
    }

    fileprivate var fetchedResultsController: NSFetchedResultsController<UserEntity>?

    private func updateUI() {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true, selector: nil)]

        self.fetchedResultsController = NSFetchedResultsController<UserEntity>(fetchRequest: request, managedObjectContext: self.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        self.fetchedResultsController?.delegate = self
        try? self.fetchedResultsController?.performFetch()

        do {
            let entities = try! self.container.viewContext.fetch(request)
            self.users = entities.map({ $0.toUser() })
        }

        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let reachabilityStatus = Reachability.networkReachabilityForInternetConnection()?.currentReachabilityStatus

        if reachabilityStatus == .notReachable {
            print("Offline")

            self.updateUI()
        } else {
            print("Online")

            //Chamada Progress Indicator

            if let url = URL(string: "https://jsonplaceholder.typicode.com/users") {
                var request = URLRequest(url:url)
                request.timeoutInterval = 10
                request.setValue("application/json", forHTTPHeaderField: "Accept")

                let dataTask = session.dataTask(with: request)
                dataTask.resume()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        if let user  = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.username
        } else {
            cell.textLabel?.text = self.users[indexPath.row].name
            cell.detailTextLabel?.text = self.users[indexPath.row].username
        }

        return cell
    }
}

extension ContactTableViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        jsonData.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        //Desaparecer Progress Indicator
        
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
                    debugPrint(error)
                }
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
