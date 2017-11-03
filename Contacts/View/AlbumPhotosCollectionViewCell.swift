//
//  AlbumPhotosCollectionViewCell.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 25/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import UIKit

class AlbumPhotosCollectionViewCell: UICollectionViewCell {

    // MARK: Private Property(ies).

    private let status = Reachability.networkReachabilityForInternetConnection()?.currentReachabilityStatus
    private var photo: Photo!

    // MARK: IBOutlet(s).

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    // MARK: Public Function(s).

    func render(photo: Photo) {
        self.photo = photo
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()

        requestFromCoreData()
    }

    private func requestFromCoreData() {
        if let data = photo.photo {
            self.photoImageView.image = UIImage(data: data)!
        }

        requestFromServer()
    }

    private func requestFromServer() {
        if status != .notReachable {
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                if let data = try? Data(contentsOf: URL(string: "http://lorempixel.com/30/30")!) {
                    DispatchQueue.main.async {
                        self?.photoImageView.image = UIImage(data: data)
                        self?.activityIndicatorView.stopAnimating()
                        self?.photo.photo = UIImagePNGRepresentation(UIImage(data: data)!)

                        do {
                            try AppDelegate.viewContext.save()
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}
