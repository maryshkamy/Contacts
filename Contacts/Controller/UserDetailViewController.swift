//
//  UserDetailViewController.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 26/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController, UITableViewDataSource {

    // MARK: Private Property(ies).

    private var dataSource: [Album] = []
    private var user: User!
    private let status = Reachability.networkReachabilityForInternetConnection()?.currentReachabilityStatus

    // MARK: IBOutlet(s).

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var albumsTableView: UITableView!
    @IBOutlet weak var userImageView: UIImageView!

    // MARK: UIViewController Delegate(s).

    override func viewDidLoad() {
        super.viewDidLoad()

        if let email = self.user.email {
            self.emailLabel.text = email
        }

        if let website = self.user.website {
            self.websiteLabel.text = website
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UserDetailViewController.imageTapped(gesture: )))
        userImageView.addGestureRecognizer(tapGesture)
        userImageView.isUserInteractionEnabled = true

        switch status {
        case .notReachable?:
            if let photo = self.user.photo {
                userImageView.image = UIImage(data: (photo.photo)!)!
            }
        default:
            userImageView.imageFromServerURL(urlString: "http://lorempixel.com/90/90/people")
        }

        requestFromCoreData()
    }

    // MARK: UITableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! UserAlbumsTableViewCell
        cell.render(album: dataSource[indexPath.row])

        return cell
    }

    // MARK: Public Function(s).

    func render(user: User) {
        self.user = user
        self.dataSource = self.user.album!.map { $0 as! Album }
    }

    // MARK: Private Function(s).

    private func requestFromCoreData() {
        if let user = self.user {
            if let album = user.album {
                self.dataSource = album.map { $0 as! Album }
            }
        }

        requestDataFromServer()
    }

    private func requestDataFromServer() {
        DataManager.Remote.getAlbum(by: self.user, onSuccess: { (dataSource) in
            self.dataSource = dataSource

            let set = NSSet(array: self.dataSource)
            self.user.album = set
            self.reloadData()
        }, onError: { (error) in
            print(error.localizedDescription)
        })
    }

    private func reloadData() {
        DispatchQueue.main.async {
            self.albumsTableView.reloadData()
        }
    }

    @objc private func imageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            let alert = UIAlertController(title: "Editar Foto", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Biblioteca de Fotos", style: .default, handler: { _ in self.showPhotosFromGallery() }))
            alert.addAction(UIAlertAction(title: "Câmera", style: .default, handler: { _ in self.showCamera() }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }
    }
}

