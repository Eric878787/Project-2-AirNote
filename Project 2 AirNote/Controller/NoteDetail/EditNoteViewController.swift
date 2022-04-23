//
//  EditNoteViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/23.
//

import UIKit
import PhotosUI
import Kingfisher

class EditNoteViewController: UIViewController {
    
    // MARK: Table View
    private var addNoteTableView = UITableView(frame: .zero)
    
    // MARK: Properties
    var note: Note?
    
    // MARK: Cover Image
    private let imagePickerController = UIImagePickerController()
    
    private var coverImage = UIImage(systemName: "magazine")
    
    // MARK: Content Images
    private let multiImagePickerController = UIImagePickerController()
    
    private var contentImages: [UIImage] = []
    
    // MARK: Data Manager
    private var noteManager = NoteManager()
    
    // MARK: Loading Animation
    private var loadingAnimation = LottieAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        navigationItem.title = "修改筆記"
        
        // Init addNoteTableView
        configureAddNoteTableView()
        
        // Image Picker Delegate
        imagePickerController.delegate = self
        multiImagePickerController.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set Default Images
        guard let note = note else { return }
        
        for image in note.images {
            let defaultImageView = UIImageView()
            let url = URL(string: image)
            defaultImageView.kf.setImage(with: url)
            contentImages.append(defaultImageView.image ?? UIImage())
        }
        
        let defaultImageView = UIImageView()
        let url = URL(string: note.cover)
        defaultImageView.kf.setImage(with: url)
        coverImage = defaultImageView.image

    }
    
}

// MARK: Configure Add Note Tableview
extension EditNoteViewController {
    
    func configureAddNoteTableView () {
        
        addNoteTableView.registerCellWithNib(identifier: String(describing: AddTitleTableViewCell.self), bundle: nil)
        addNoteTableView.registerCellWithNib(identifier: String(describing: AddContentTableViewCell.self), bundle: nil)
        addNoteTableView.registerCellWithNib(identifier: String(describing: AddKeywordsTableViewCell.self), bundle: nil)
        addNoteTableView.registerCellWithNib(identifier: String(describing: AddCoverTableViewCell.self), bundle: nil)
        addNoteTableView.registerCellWithNib(identifier: String(describing: AddPhotosTableViewCell.self), bundle: nil)
        addNoteTableView.dataSource = self
        addNoteTableView.delegate = self
        addNoteTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addNoteTableView)
        
        addNoteTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        addNoteTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        addNoteTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        addNoteTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    
}

// MARK: Table View DataSource
extension EditNoteViewController: UITableViewDataSource, CoverDelegate, SelectImagesDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddTitleTableViewCell.self), for: indexPath)
            guard let addTitleCell = cell as? AddTitleTableViewCell else { return cell }
            addTitleCell.titleTextField.text = note?.title
            addTitleCell.dataHandler = { [weak self] title in
                self?.note?.title = title
            }
            return addTitleCell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddContentTableViewCell.self), for: indexPath)
            guard let addContentCell = cell as? AddContentTableViewCell else { return cell }
            addContentCell.contentTextView.text = note?.content
            addContentCell.dataHandler = {  [weak self] content in
                self?.note?.content = content
            }
            return addContentCell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddKeywordsTableViewCell.self), for: indexPath)
            guard let addKeywordsCell = cell as? AddKeywordsTableViewCell else { return cell }
            addKeywordsCell.categoryTextField.text = note?.category
            addKeywordsCell.dataHandler = { [weak self] selectedTags, selectedCategory in
                self?.note?.category = selectedCategory
                self?.note?.keywords = selectedTags
            }
            return addKeywordsCell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddCoverTableViewCell.self), for: indexPath)
            guard let addCoverCell = cell as? AddCoverTableViewCell else { return cell }
            addCoverCell.delegate = self
            addCoverCell.coverImageView.image = coverImage
            return addCoverCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddPhotosTableViewCell.self), for: indexPath)
            guard let addPhotosCell = cell as? AddPhotosTableViewCell else { return cell }
            addPhotosCell.delegate = self
            
            for item in 0..<contentImages.count {
                
                addPhotosCell.bookImageViews[item].image = contentImages[item]
                
            }
            return addPhotosCell
        }
    }
}

// MARK: Table View Delegate
extension EditNoteViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return 100
//        } else if indexPath.row == 1 {
//            return 300
//        } else if indexPath.row == 2 {
//            return 165
//        } else if indexPath.row == 3{
//            return 500
//        } else {
//            return 600
//        }
        
        if indexPath.row == 1 {
            return 300
        } else if indexPath.row == 4 {
            return 600
        } else {
            return  UITableView.automaticDimension
        }
    }
}

// MARK: UIIMagePicker Delegate
extension EditNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            if picker == imagePickerController {
                
                coverImage = image
                
            } else {
                
                if self.contentImages.count < 4 {
                    self.contentImages.insert(image, at: 0)
                }  else {
                    self.contentImages.remove(at: 3)
                    self.contentImages.insert(image, at: 0)
                }
                
            }
            
        }
        
        addNoteTableView.reloadData()
        
        picker.dismiss(animated: true)
        
    }
    
    func buttonDidSelect() {
        
        let controller = UIAlertController(title: "請上傳筆記", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        // 相機
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            self.takePicture()
        }
        controller.addAction(cameraAction)
        
        // 相薄
        let savedPhotosAlbumAction = UIAlertAction(title: "相簿", style: .default) { _ in
            self.openPhotosAlbum()
        }
        controller.addAction(savedPhotosAlbumAction)
        
        // 手繪版
        let drawingPadAction = UIAlertAction(title: "手繪板", style: .default) { _ in
            self.openDrawingPad()
        }
        controller.addAction(drawingPadAction)
        
        // 取消
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
        
    }
    
    /// 開啟相機
    func takePicture() {
        imagePickerController.sourceType = .camera
        self.present(imagePickerController, animated: true)
    }
    
    /// 開啟相簿
    func openPhotosAlbum() {
        imagePickerController.sourceType = .savedPhotosAlbum
        self.present(imagePickerController, animated: true)
    }
    
    // 開啟手繪版
    func openDrawingPad() {
        let storyBoard = UIStoryboard(name: "DrawingPad", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "DrawingPadViewController") as? DrawingPadViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
        vc.imageProvider = { [weak self] image in
            self?.coverImage = image
            self?.addNoteTableView.reloadData()
        }
    }
}

extension EditNoteViewController: PHPickerViewControllerDelegate{
    
    func selectMultiImages() {
        
        let controller = UIAlertController(title: "請上傳筆記", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        // 相機
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            self.takePictureForMulti()
        }
        controller.addAction(cameraAction)
        
        // 相薄
        let savedPhotosAlbumAction = UIAlertAction(title: "相簿", style: .default) { _ in
            self.openPhotosAlbumForMulti()
        }
        controller.addAction(savedPhotosAlbumAction)
        
        // 取消
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
        
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        if results.count != 0 {
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            // 判斷是否超過4張
                            if self.contentImages.count < 4 {
                                self.contentImages.insert(image, at: 0)
                            }  else {
                                self.contentImages.remove(at: 3)
                                self.contentImages.insert(image, at: 0)
                            }
                            self.addNoteTableView.reloadData()
                        }
                    }
                })
            }
        } else {
            return
        }
    }
    
    // 開啟相簿多選
    func openPhotosAlbumForMulti() {
        // MARK: Multi - images Picker
        var configuration = PHPickerConfiguration()
        
        configuration.filter = .images
        
        configuration.selectionLimit = 4
        
        let pHPImagePicker = PHPickerViewController(configuration: configuration)
        
        pHPImagePicker.delegate = self
        
        self.present(pHPImagePicker, animated: true)
    }
    
    // 開啟相機（content photo）
    func takePictureForMulti() {
        multiImagePickerController.sourceType = .camera
        self.present(multiImagePickerController, animated: true)
    }
    
}

extension EditNoteViewController {
    
    func configureAnimation() {
        loadingAnimation.loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingAnimation.loadingView)
        loadingAnimation.loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingAnimation.loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func uploadNote() {
        
        guard let note = self.note else { return }
        
        if note.title != "" && note.content != "" && note.category != "" && note.keywords != [] && coverImage != UIImage(systemName: "magazine") && contentImages != [] {
            
            upload()
            
        } else {
            let controller = UIAlertController(title: "請上傳完整資料", message: "", preferredStyle: .alert)
            controller.view.tintColor = UIColor.gray
            let cancelAction = UIAlertAction(title: "確認", style: .destructive, handler: nil)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func upload() {
        
        let group = DispatchGroup()
        let controller = UIAlertController(title: "上傳成功", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        group.enter()
        // Loading Animation
        configureAnimation()
        loadingAnimation.loadingView.play()
        guard let image = coverImage else { return }
        noteManager.uploadPhoto(image: image) { result in
            switch result {
            case .success(let url):
                self.note?.cover = "\(url)"
                print("\(url)")
            case .failure(let error):
                print("\(error)")
            }
            group.leave()
        }
        
        let images = contentImages
        for image in images {
            group.enter()
            noteManager.uploadPhoto(image: image) { result in
                switch result {
                case .success(let url):
                    self.note?.images.append("\(url)")
                    print("\(url)")
                case .failure(let error):
                    print("\(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.global()) {
            print("123")
            guard let editedNote = self.note else { return }
            self.noteManager.updateNote(note: editedNote, noteId: editedNote.noteId) { [weak self] result in
                switch result {
                case .success:
                    print(result)
                    let cancelAction = UIAlertAction(title: "確認", style: .destructive) { _ in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    DispatchQueue.main.async {
                        self?.loadingAnimation.loadingView.pause()
                        self?.loadingAnimation.loadingView.isHidden = true
                        controller.addAction(cancelAction)
                        self?.present(controller, animated: true, completion: nil)
                    }
                case.failure:
                    print(result)
                }
            }
        }
    }
}