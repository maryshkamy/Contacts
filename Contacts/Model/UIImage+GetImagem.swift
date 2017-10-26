//
//  GetImagem.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 26/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    private var session: URLSession {
        let session = URLSession(configuration: SessionManager.shared.sessionConfiguration, delegate: nil, delegateQueue: SessionManager.shared.operationQueue)
        return session
    }
    
    public func imageFromServerURL(urlString: String) {
        let url = URL(string:urlString)!
        var request = URLRequest(url:url)
        request.timeoutInterval = 100

        session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
        }).resume()
    }
}
