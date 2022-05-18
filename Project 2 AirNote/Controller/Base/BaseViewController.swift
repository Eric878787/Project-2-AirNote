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
    
    func initChoosePhotoAlert(_ imagePickerController: UIImagePickerController) {
        let controller = UIAlertController(title: "請上傳頭貼", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        // 相機
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            takePicture()
        }
        cameraAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(cameraAction)
        
        // 相薄
        let savedPhotosAlbumAction = UIAlertAction(title: "相簿", style: .default) { _ in
            openPhotosAlbum()
        }
        savedPhotosAlbumAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(savedPhotosAlbumAction)
        
        // 取消
        let cancelAction = UIAlertAction(title: "取消", style: .default)
        controller.addAction(cancelAction)
        
        // 開啟相機
        func takePicture() {
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true)
        }
        
        // 開啟相簿
        func openPhotosAlbum() {
            imagePickerController.sourceType = .savedPhotosAlbum
            self.present(imagePickerController, animated: true)
        }
        
        // 取消選取
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        DispatchQueue.main.async {
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    func initBasicConfirmationAlert(_ title: String, _ message: String, _ completion: (() -> Void)? = nil) {
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
    
    func initAlternativeAlert(_ title: String, _ message: String?, _ confirmation: (() -> Void)? = nil, _ cancelation: (() -> Void)? = nil ) {
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
