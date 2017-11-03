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

    // MARK: Property(ies).

    fileprivate var dataSource = [User]() {
        willSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: UIViewController Delegate(s).

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestDataFromCoreData()
    }

    // MARK: UITableView DataSource.

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        cell.textLabel?.text = self.dataSource[indexPath.row].name
        cell.detailTextLabel?.text = self.dataSource[indexPath.row].username

        return cell
    }

    // MARK: UITableView Delegate(s).

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userSegue" {
            if let destination = segue.destination as? UserDetailViewController {
                if let cell = sender as? UITableViewCell {
                    if let indexPath = tableView.indexPath(for: cell) {
                        destination.render(user: self.dataSource[indexPath.row])
                    }
                }
            }
        }
    }

    // MARK: Private Function(s).

    private func requestDataFromCoreData() {
        DataManager.Local.getUsers(orderBy: .name, onSuccess: { (dataSource) in
            self.dataSource = dataSource
        }, onError: { (error) in
            print(error.localizedDescription)
        }, onFinally: {
            self.requestDataFromServer()
        })
    }

    private func requestDataFromServer() {
        self.showLoading()
        DataManager.Remote.getUsers(onSuccess: { (dataSource) in
            self.dataSource = dataSource
            self.hideLoading()
        }, onError: { (error) in
            print(error.localizedDescription)
        })
    }

    private func showLoading() {
        if isOnline {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
    }

    private func hideLoading() {
        if isOnline {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

extension ContactTableViewController {
    var activityLoadView: UIView {
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
    }
}
