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
    @IBOutlet weak var albumTitle: UILabel! {
        didSet{
            setup()
        }
    }

    private var photos: [Photos]?

    var album: Albums? {
        didSet {
            setup()
        }
    }

    private func setup() {
        guard let myAlbum = album else { return }

        albumTitle?.text = myAlbum.title

        if let url = URL(string: "https://jsonplaceholder.typicode.com/albums/\(myAlbum.id)/photos") {
            URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
                if let albumData = data {
                    self?.photos = try? JSONDecoder().decode([Photos].self, from: albumData)
                    DispatchQueue.main.async {
                        self?.photosCollectionView.reloadData()
                    }
                }
            }).resume()
        }


    }

}

extension UserAlbumsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! AlbumPhotosCollectionViewCell

        cell.imageURL = URL(string: "http://lorempixel.com/30/30")
        cell.activityIndicatorView.hidesWhenStopped = true

        return cell
    }
}
