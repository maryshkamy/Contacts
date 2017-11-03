//
//  UserDetailsViewController+UIImagePicker.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 02/11/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation
import UIKit

extension UserDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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

