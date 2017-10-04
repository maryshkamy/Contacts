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
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!

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

    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        self.saveInCoreData()
    }

    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    private var viewContext = AppDelegate.viewContext

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

    private var textFields: [Int] = []

    private func checkTextFields() {
        if textFields.count == 12 {
            doneBarButtonItem.isEnabled = true
        } else {
            doneBarButtonItem.isEnabled = false
        }
    }

    private func saveInCoreData() {
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
                self.postToJSON(user)
            }
        }catch {
            debugPrint(error)
        }
    }

    private func postToJSON(_ coreDataUser: UserEntity) {
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

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer (target: self, action: #selector(AddNewContactTableViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UITextField {
    func isValidEmail() -> Bool {
        return (self.text?.contains("@"))! && (self.text?.contains(".com"))!
    }

    func isValidURL() -> Bool {
        return (self.text?.contains("http://"))! || (self.text?.contains("https://"))!
    }

    func setInvalidColor(valid: Bool) {
        if valid == true {
            self.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1).cgColor
        } else {
            self.layer.borderColor = UIColor.red.cgColor
        }

        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
}

extension AddNewContactTableViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 2:
            if !textField.text!.isEmpty && textField.isValidEmail() {
                self.textFields.append(textField.tag)
                textField.setInvalidColor(valid: true)
            } else {
                if self.textFields.contains(textField.tag) {
                    self.textFields.remove(at: textField.tag)
                }

                textField.setInvalidColor(valid: false)
            }
        case 4:
            if !textField.text!.isEmpty && textField.isValidURL(){
                self.textFields.append(textField.tag)
                textField.setInvalidColor(valid: true)
            } else {
                if self.textFields.contains(textField.tag) {
                    self.textFields.remove(at: textField.tag)
                }

                textField.setInvalidColor(valid: false)
            }
        default:
            if textField.text!.isEmpty {
                if self.textFields.contains(textField.tag) {
                    self.textFields.remove(at: textField.tag)
                }
                
                textField.setInvalidColor(valid: false)
            } else {
                self.textFields.append(textField.tag)
                textField.setInvalidColor(valid: true)
            }
        }

        checkTextFields()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 2:
            if textField.isValidEmail() && textField == self.emailTextField {
                textField.setInvalidColor(valid: true)
                self.phoneTextField.becomeFirstResponder()
            } else {
                textField.setInvalidColor(valid: false)
            }
        case 4:
            if textField.isValidURL() && textField == self.websiteTextField {
                textField.setInvalidColor(valid: true)
                self.streetTextField.becomeFirstResponder()
            } else {
                textField.setInvalidColor(valid: false)
            }
        default:
            if !textField.text!.isEmpty && textField == self.nameTextField {
                textField.setInvalidColor(valid: true)
                self.usernameTextField.becomeFirstResponder()
            } else if !textField.text!.isEmpty && textField == self.usernameTextField {
                textField.setInvalidColor(valid: true)
                self.emailTextField.becomeFirstResponder()
            } else if !textField.text!.isEmpty && textField == self.phoneTextField {
                textField.setInvalidColor(valid: true)
                self.websiteTextField.becomeFirstResponder()
            } else if !textField.text!.isEmpty && textField == self.streetTextField {
                textField.setInvalidColor(valid: true)
                self.suiteTextField.becomeFirstResponder()
            } else if !textField.text!.isEmpty && textField == self.suiteTextField {
                textField.setInvalidColor(valid: true)
                self.cityTextField.becomeFirstResponder()
            } else if !textField.text!.isEmpty && textField == self.cityTextField {
                textField.setInvalidColor(valid: true)
                self.zipcodeTextField.becomeFirstResponder()
            } else if !textField.text!.isEmpty && textField == self.zipcodeTextField {
                textField.setInvalidColor(valid: true)
                self.companyNameTextField.becomeFirstResponder()
            } else if !textField.text!.isEmpty && textField == self.companyNameTextField {
                textField.setInvalidColor(valid: true)
                self.catchPhraseTextField.becomeFirstResponder()
            } else if !textField.text!.isEmpty && textField == self.catchPhraseTextField {
                textField.setInvalidColor(valid: true)
                self.bsTextField.becomeFirstResponder()
            } else if !textField.text!.isEmpty && textField == self.bsTextField {
                textField.setInvalidColor(valid: true)
                self.saveInCoreData()
            } else {
                textField.setInvalidColor(valid: false)
            }
        }

        checkTextFields()

        return true
    }
}

extension AddNewContactTableViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let response = task.response as? HTTPURLResponse, response.statusCode == 201 {
            print("201 Created")
            DispatchQueue.main.async { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }
        }

//        if let erro = error {
//            debugPrint(erro)
//            DispatchQueue.main.async { [unowned self] in
//                let ac = UIAlertController(title: "Erro", message: erro.localizedDescription, preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(ac, animated: true, completion: nil)
//            }
//        }
    }
}
