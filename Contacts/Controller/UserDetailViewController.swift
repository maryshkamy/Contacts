//
//  UserDetailViewController.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 26/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var albumsTableView: UITableView!
    @IBOutlet weak var userImageView: UIImageView!{
        didSet {
            userImageView.imageFromServerURL(urlString: "http://lorempixel.com/90/90/people")
        }
    }

    private var appendingData = Data()
    private var albums: [Albums]?

    private lazy var session: URLSession = {
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate: self,
                                 delegateQueue: nil)
        return session
    }()

    var user: User? {
        didSet {
            title = user?.name
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let myUser = user else { return }

        //Chamada Progress Indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        view.addSubview(activityLoadView)

        if user != nil {
            emailLabel.text = user?.email
            websiteLabel.text = user?.website
        }

        if let url = URL(string: "https://jsonplaceholder.typicode.com/users/\(myUser.id)/albums") {
            session.dataTask(with: url).resume()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UserDetailViewController.imageTapped(gesture: )))
        userImageView.addGestureRecognizer(tapGesture)
        userImageView.isUserInteractionEnabled = true
    }

    @objc func imageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            showAlertPhotos()
        }
    }
}

extension UserDetailViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        appendingData.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            albums = try? JSONDecoder().decode([Albums].self, from: appendingData)
            DispatchQueue.main.async { [weak self] in
                self?.albumsTableView.reloadData()

                //Desaparecer Progress Indicator
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self?.activityLoadView.removeFromSuperview()
            }
        }else {
            //TODO: tratar erro
        }
    }
}

extension UserDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! UserAlbumsTableViewCell

        if let album = albums?[indexPath.row] {
            cell.album = album
        }
        return cell
    }
}

extension UserDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showAlertPhotos() {
        let alert = UIAlertController(title: "Editar Foto", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Biblioteca de Fotos", style: .default, handler: { _ in
            self.showPhotosFromGallery()
        }))
        alert.addAction(UIAlertAction(title: "Câmera", style: .default, handler: { _ in
            self.showCamera()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func showPhotosFromGallery() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!

        self.present(picker, animated: true, completion: nil)
    }

    func showCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo

        self.present(picker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        userImageView.contentMode = .scaleAspectFit
        userImageView.image = chosenImage
        dismiss(animated:true, completion: nil)
    }
}
