//
//  Coordinator.swift
//  Card Tracker
//
//  Created by Michael Rowe on 1/1/21.
//  Copyright © 2021 Michael Rowe. All rights reserved.
//

import SwiftUI

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @Binding var isCoordinatorShown: Bool
    @Binding var imageInCoordinator: Image?
    @Binding var useCamera: Bool

    init(isShown: Binding<Bool>, image: Binding<Image?>, useCamera: Binding<Bool>) {
        _isCoordinatorShown = isShown
        _imageInCoordinator = image
        _useCamera = useCamera
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let unwrapImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageInCoordinator = Image(uiImage: unwrapImage)
        isCoordinatorShown = false
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isCoordinatorShown = false
    }
}
