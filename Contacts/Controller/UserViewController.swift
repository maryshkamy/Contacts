//
//  UserViewController.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 19/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import UIKit
import CoreData

class UserViewController: UIViewController {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var albumsTableView: UITableView!

    var jsonData = Data()

    var albums = [Albums]() {
        willSet {
            DispatchQueue.main.async { [weak self] in
                self?.albumsTableView.reloadData()
            }
        }
    }

    var thisUserAlbums = [Albums]() {
        willSet {
            DispatchQueue.main.async { [weak self] in
                self?.albumsTableView.reloadData()
            }
        }
    }

    var photos: [[Photos]] = []

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

    private var session: URLSession {
        let session = URLSession(configuration: SessionManager.shared.sessionConfiguration, delegate: nil, delegateQueue: SessionManager.shared.operationQueue)
        return session
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if user != nil {
            userImageView.imageFromServerURL(urlString: "http://lorempixel.com/90/90/people")
            emailLabel.text = user?.email
            websiteLabel.text = user?.website
        }

        //Chamada Progress Indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        view.addSubview(activityLoadView)

        requestAlbum()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UserViewController.imageTapped(gesture: )))
        userImageView.addGestureRecognizer(tapGesture)
        userImageView.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func imageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            showAlertPhotos()
        }
    }

    func requestAlbum() {
        if let url = URL(string: "https://jsonplaceholder.typicode.com/albums") {
            var request = URLRequest(url:url)
            request.timeoutInterval = 10
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
                do {
                    if error == nil {
                        let decoder = JSONDecoder()
                        self.albums = try decoder.decode([Albums].self, from: data!)
                        self.thisUserAlbums = self.albums.filter { $0.userId == self.user?.id }

                        for i in 0..<self.thisUserAlbums.count {
                            self.requestPhotos(id: Int(self.thisUserAlbums[i].id))
                        }

                        DispatchQueue.main.async { [unowned self] in
                            //Desaparecer Progress Indicator
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            self.activityLoadView.removeFromSuperview()
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            dataTask.resume()
        }
    }

    func requestPhotos(id: Int) {
        if let url = URL(string: "https://jsonplaceholder.typicode.com/albums/\(id)/photos") {
            var request = URLRequest(url:url)
            request.timeoutInterval = 10
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
                do {
                    if error == nil {
                        let decoder = JSONDecoder()
                        let photosByID = try decoder.decode([Photos].self, from: data!)
                        self.photos.append(photosByID)

                        print("O Album \(id) possuí \(photosByID.count) fotos")
                    }

                } catch let error {
                    print(error.localizedDescription)
                }
            })
            dataTask.resume()
        }
    }
}

extension UserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thisUserAlbums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! UserAlbumsTableViewCell

        cell.albumTitle.text = self.thisUserAlbums[indexPath.row].title

        if self.photos.count > 0 && self.photos.count > indexPath.row + 1 {
            cell.setup(photos: self.photos[indexPath.row])
            cell.photosCollectionView.reloadData()
        }

        return cell
    }
}

extension UserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

extension UserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
