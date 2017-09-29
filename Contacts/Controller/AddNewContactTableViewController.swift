//
//  AddNewContactTableViewController.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 28/09/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import UIKit
import CoreData

class AddNewContactTableViewController: UITableViewController {
    private var viewContext = AppDelegate.viewContext

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var suiteTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var catchPhraseTextField: UITextField!
    @IBOutlet weak var bsTextField: UITextField!

    private var sessionConfiguration: URLSessionConfiguration {
        let cfg = URLSessionConfiguration.default
        cfg.allowsCellularAccess = true
        cfg.networkServiceType = .default
        cfg.requestCachePolicy = .returnCacheDataElseLoad
        cfg.isDiscretionary = true
        cfg.urlCache = URLCache(memoryCapacity: 2048,
                                diskCapacity: 10240,
                                diskPath: NSTemporaryDirectory())
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
        let session = URLSession(configuration: sessionConfiguration,
                                 delegate: self,
                                 delegateQueue: operationQueue)
        return session
    }

    @IBAction func DoneButton(_ sender: UIBarButtonItem) {
        let user = UserEntity(context: viewContext)
        user.id = Int32(arc4random() % (arc4random() % 100))
        user.name = nameTextField.text
        user.username = usernameTextField.text
        user.email = emailTextField.text
        user.address = AddressEntity(context: viewContext)
        user.address?.street = streetTextField.text
        user.address?.suite = suiteTextField.text
        user.address?.city = cityTextField.text
        user.address?.zipcode = zipcodeTextField.text
        user.address?.geo = GeoEntity(context: viewContext)
        user.address?.geo?.lat = String(0)
        user.address?.geo?.lng = String(0)
        user.phone = phoneTextField.text
        user.website = websiteTextField.text
        user.company = CompanyEntity(context: viewContext)
        user.company?.name = companyNameTextField.text
        user.company?.catchPhrase = catchPhraseTextField.text
        user.company?.bs = bsTextField.text

        do {
            try viewContext.save()
            DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
                self.send(user)
            }
        }catch {
            debugPrint(error)
        }
    }

    private func send(_ coreDataUser: UserEntity) {
        let user = User(id: coreDataUser.id,
                        name: coreDataUser.name!,
                        username: coreDataUser.username!,
                        email: coreDataUser.email!,
                        address: Address(street: coreDataUser.address!.street!,
                                         suite: coreDataUser.address!.suite!,
                                         city: coreDataUser.address!.city!,
                                         zipcode: coreDataUser.address!.zipcode!,
                                         geo: Geo(lat: coreDataUser.address!.geo!.lat!,
                                                  lng: coreDataUser.address!.geo!.lng!)),
                        phone: coreDataUser.phone!,
                        website: coreDataUser.website!,
                        company: Company(name: coreDataUser.company!.name!,
                                         catchPhrase: coreDataUser.company!.catchPhrase!,
                                         bs: coreDataUser.company!.bs!))
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(user)

            if let url = URL(string: "https://jsonplaceholder.typicode.com/users") {
                var request = URLRequest(url:url)
                request.httpMethod = "POST"
                request.timeoutInterval = 10
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData

                let dataTask = session.dataTask(with: request)
                dataTask.resume()
            }
        }catch {
            debugPrint(error)
        }
    }

    @IBAction func CancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AddNewContactTableViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let response = task.response as? HTTPURLResponse, response.statusCode == 201 {
            print("deu derto")
            DispatchQueue.main.async { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }
        }

        if let erro = error {
            debugPrint(erro)
            DispatchQueue.main.async { [unowned self] in
                let ac = UIAlertController(title: "Erro",
                                           message: erro.localizedDescription,
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK",
                                           style: .default,
                                           handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
}
