//
//  UserAlbumsTableViewCell.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 25/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import UIKit

class UserAlbumsTableViewCell: UITableViewCell {
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var albumTitle: UILabel!

    var photos: [Photos] = []

    func setup(photos: [Photos]) {
        self.photos = photos
    }
}

extension UserAlbumsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! AlbumPhotosCollectionViewCell

        cell.photoImageView.imageFromServerURL(urlString: "http://lorempixel.com/30/30")

        return cell
    }
}
