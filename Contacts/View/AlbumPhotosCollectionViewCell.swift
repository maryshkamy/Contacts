//
//  AlbumPhotosCollectionViewCell.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 25/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import UIKit

class AlbumPhotosCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var imageURL: URL? {
        didSet {
            if let url = imageURL {
                activityIndicatorView.startAnimating()
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    if let data = try?Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            self?.photoImageView.image = UIImage(data: data)
                            self?.activityIndicatorView.stopAnimating()
                        }
                    }
                }
            }
        }
    }

    
}
