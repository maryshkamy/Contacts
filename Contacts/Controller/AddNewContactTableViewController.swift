//
//  AddNewContactTableViewController.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 28/09/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

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

    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        self.dismissKeyboard()

        //Progress Indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.view.addSubview(self.activityLoadView)

        self.saveInCoreData()
    }

    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismissKeyboard()
        
        dismiss(animated: true, completion: nil)
    }

    private var lat: Double = 0
    private var lng: Double = 0

    private var textFields: [Int] = []

    private var viewContext = AppDelegate.viewContext

    private var session: URLSession {
        let session = URLSession(configuration: SessionManager.shared.sessionConfiguration, delegate: self, delegateQueue: SessionManager.shared.operationQueue)
        return session
    }

    private func checkTextFields() {
        if textFields.count == 12 {
            doneBarButtonItem.isEnabled = true
        } else {
            doneBarButtonItem.isEnabled = false
        }
    }

    private func saveInCoreData() {
        let user = User(context: viewContext)

        user.id = Int32(arc4random() % (arc4random() % 100))
        user.name = nameTextField.text
        user.username = usernameTextField.text
        user.email = emailTextField.text
        user.address = Address(context: viewContext)
        user.address?.street = streetTextField.text
        user.address?.suite = suiteTextField.text
        user.address?.city = cityTextField.text
        user.address?.zipcode = zipcodeTextField.text
        user.address?.geo = Geo(context: viewContext)
        user.address?.geo?.lat = String(lat)
        user.address?.geo?.lng = String(lng)
        user.phone = phoneTextField.text
        user.website = websiteTextField.text
        user.company = Company(context: viewContext)
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

    private func postToJSON(_ user: User) {
        if let url = URL(string: "https://jsonplaceholder.typicode.com/users") {
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.timeoutInterval = 10
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = Data()

            let dataTask = session.dataTask(with: request)
            dataTask.resume()
        }
    }

    @objc func dismissKeyboard() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        self.tableView.reloadData()
        checkTextFields()
        view.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            if let destination = segue.destination as? MapViewController {
                destination.delegate = self
            }
        }
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
                if !self.textFields.contains(textField.tag) {
                    self.textFields.append(textField.tag)
                }

                textField.setInvalidColor(valid: true)
            } else {
                if self.textFields.contains(textField.tag) {
                    self.textFields.remove(at: textField.tag)
                }

                textField.setInvalidColor(valid: false)
            }
        case 4:
            if !textField.text!.isEmpty && textField.isValidURL(){
                if !self.textFields.contains(textField.tag) {
                    self.textFields.append(textField.tag)
                }

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
                if !self.textFields.contains(textField.tag) {
                    self.textFields.append(textField.tag)
                }

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
                self.dismissKeyboard()

                //Progress Indicator
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.view.addSubview(self.activityLoadView)

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
                //Progress Indicator
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityLoadView.removeFromSuperview()

                self.dismiss(animated: true, completion: nil)
            }
        }

        if let erro = error {
            debugPrint(erro)
            DispatchQueue.main.async { [unowned self] in
                
                //Progress Indicator
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityLoadView.removeFromSuperview()

                let ac = UIAlertController(title: "Erro", message: erro.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil) }))

                self.present(ac, animated: true, completion: nil)
            }
        }
    }
}

extension AddNewContactTableViewController: AddressProtocol {
    func didReceive(placemark: CLPlacemark?) {
        guard let placemark = placemark else { return }

        print(placemark)

        self.streetTextField.text = placemark.name!
        if !self.textFields.contains(self.streetTextField.tag) {
            self.textFields.append(self.streetTextField.tag)
        }

        self.cityTextField.text = placemark.locality
        if !self.textFields.contains(self.cityTextField.tag) {
            self.textFields.append(self.cityTextField.tag)
        }

        self.zipcodeTextField.text = placemark.postalCode
        if !self.textFields.contains(self.zipcodeTextField.tag) {
            self.textFields.append(self.zipcodeTextField.tag)
        }


        self.lat = placemark.location!.coordinate.latitude
        self.lng = placemark.location!.coordinate.longitude
    }
}
