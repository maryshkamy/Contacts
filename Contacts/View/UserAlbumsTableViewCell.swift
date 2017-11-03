//
//  UserAlbumsTableViewCell.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 25/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import UIKit

class UserAlbumsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: Private Property(ies).

    private var album: Album!
    private var dataSource: [Photo] = [] {
        willSet {
            reloadData()
        }
    }

    // MARK: IBOutlet(s).

    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var albumTitle: UILabel!

    // MARK: Public Function(s).

    func render(album: Album) {
        self.album = album
        self.albumTitle.text = self.album.title!

        self.requestFromCoreData()
    }

    // MARK: Private Function(s).

    private func reloadData() {
        DispatchQueue.main.async {
            self.photosCollectionView.reloadData()
        }
    }

    private func requestFromCoreData() {
        if let dataSource = self.album.photo {
            self.dataSource = dataSource.map { $0 as! Photo }
        }

        requestFromServer()
    }

    private func requestFromServer() {
        DataManager.Remote.getPhotos(by: self.album!, onSuccess: { (dataSource) in
            self.dataSource = dataSource
        }, onError: { (error) in
            print(error.localizedDescription)
        })
    }

    // MARK: UICollectionView DataSource.

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! AlbumPhotosCollectionViewCell
        cell.render(photo: dataSource[indexPath.row])

        return cell
    }
}
