//
//  BaseViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/18.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: Propertities
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: Methods
    
    func showChoosePhotoAlert(_ imagePickerController: UIImagePickerController) {
        let controller = UIAlertController(title: "請上傳頭貼", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        // Camera
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            takePicture()
        }
        cameraAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(cameraAction)
        
        // Album
        let savedPhotosAlbumAction = UIAlertAction(title: "相簿", style: .default) { _ in
            openPhotosAlbum()
        }
        savedPhotosAlbumAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(savedPhotosAlbumAction)
        
        // Cancel
        let cancelAction = UIAlertAction(title: "取消", style: .default)
        controller.addAction(cancelAction)
        
        // Present Camera View
        func takePicture() {
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true)
        }
        
        // Present Album View
        func openPhotosAlbum() {
            imagePickerController.sourceType = .savedPhotosAlbum
            self.present(imagePickerController, animated: true)
        }
        
        // Cancel Selection
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        DispatchQueue.main.async {
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    func showBasicConfirmationAlert(_ title: String, _ message: String?, _ completion: (() -> Void)? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        let action = UIAlertAction(title: "確認", style: .default) { _ in
            completion?()
        }
        action.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(action)
        DispatchQueue.main.async {
            self.present(controller, animated: true)
        }
    }
    
    func showAlternativeAlert(_ title: String, _ message: String?,
                              _ confirmation: (() -> Void)? = nil,
                              _ cancelation: (() -> Void)? = nil ) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
       
        let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
            confirmation?()
        }
        confirmAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            cancelation?()
        }
        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(controller, animated: true)
        }
    }
    
    func showBlockUserAlert(_ completion: @escaping () -> Void) {
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "封鎖用戶", style: .default) { _ in
            completion()
        }
        controller.addAction(action)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        
        // iPad Situation
        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                  y: self.view.bounds.midY,
                                                  width: 0,
                                                  height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        self.present(controller, animated: true)
    }
    
    func setUpBasicLabel(_ label: UILabel) {
        label.font = UIFont(name: "PingFangTC-Regular", size: 16)
        label.textColor = .black
    }
    
    func setUpBasicSegmentControl(_ segmentControl: UISegmentedControl) {
        segmentControl.backgroundColor = .clear
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.myDarkGreen], for: .normal)
        segmentControl.selectedSegmentTintColor = .myDarkGreen
    }
    
}
