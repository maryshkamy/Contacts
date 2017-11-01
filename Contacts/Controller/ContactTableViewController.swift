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

    var activityLoadView: UIView = {
        let box = UIView(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 75, y: (UIScreen.main.bounds.height / 2) - 150, width: 150, height: 150))
        box.layer.borderWidth = 1
        box.layer.cornerRadius = 10
        box.backgroundColor = .black
        box.alpha = 0.75

        let textActivity: UILabel = UILabel(frame: CGRect(x: 25, y: 75, width: 200, height: 50))
        textActivity.text = "Carregando..."
        textActivity.textColor = UIColor.white
        box.addSubview(textActivity)

        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 50, y: 40, width: 50, height: 50))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        box.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        return box
    }()

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
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            view.addSubview(activityLoadView)

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userSegue" {
            if let destination = segue.destination as? UserDetailViewController {
                if let cell = sender as? UITableViewCell {
                    if let indexPath = tableView.indexPath(for: cell) {
                        destination.user = self.users[indexPath.row]
                    }
                }
            }
        }
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
                //Desaparecer Progress Indicator
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityLoadView.removeFromSuperview()

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

