//
//  AddNoteViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/13.
//

import UIKit
import PhotosUI
import MLKit

class AddNoteViewController: BaseViewController {
    
    // MARK: Properties
    private var addNoteTableView = UITableView(frame: .zero)
    private var note = Note(authorId: "",
                            comments: [Comment(content: "", createdTime: Date(), uid: "")],
                            createdTime: Date(),
                            likes: [], category: "",
                            clicks: [], content: "",
                            cover: "", noteId: "",
                            images: [], keywords: [],
                            title: "")
    private var user: User?
    private let imagePickerController = UIImagePickerController()
    private var coverImage = UIImage(systemName: "magazine")
    private let multiImagePickerController = UIImagePickerController()
    private var contentImages: [UIImage] = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NavigationItemTitle.createNote.rawValue
        configureAddNoteTableView()
        imagePickerController.delegate = self
        multiImagePickerController.delegate = self
    }
    
}

// MARK: ML Kit
extension AddNoteViewController {
    
    private func detectLabels(image: UIImage?, shouldUseCustomModel: Bool) {
        var resultsText = ""
        guard let image = image else { return }
        
        // [START config_label]
        var options: CommonImageLabelerOptions!
        options = ImageLabelerOptions()
        // [END config_label]
        
        // [START init_label]
        let onDeviceLabeler = ImageLabeler.imageLabeler(options: options)
        // [END init_label]
        
        // Initialize a `VisionImage` object with the given `UIImage`.
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        
        // [START detect_label]
        weak var weakSelf = self
        onDeviceLabeler.process(visionImage) { labels, error in
            guard weakSelf != nil else {
                return
            }
            guard error == nil, let labels = labels, !labels.isEmpty else {
                return
            }
            
            // [START_EXCLUDE]
            resultsText = labels.map { label -> String in
                return "Label: \(label.text), Confidence: \(label.confidence), Index: \(label.index)"
            }.joined(separator: "\n")
            self.note.keywords.append(resultsText)
            self.detectTextOnDevice(image: image)
            // [END_EXCLUDE]
        }
        // [END detect_label]
    }
    
    private func detectTextOnDevice(image: UIImage?) {
        
        guard let image = image else { return }
        let options = ChineseTextRecognizerOptions()
        let textRecognizer = TextRecognizer.textRecognizer(options: options)
        
        // Initialize a `VisionImage` object with the given `UIImage`.
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        process(visionImage, with: textRecognizer)
    }
    
    private func process(_ visionImage: VisionImage, with textRecognizer: TextRecognizer?) {
        
        weak var weakSelf = self
        var resultsText = ""
        textRecognizer?.process(visionImage) { text, error in
            guard weakSelf != nil else {
                return
            }
            guard error == nil, let text = text else {
                let errorString = error?.localizedDescription ?? Constants.detectionNoResultsMessage
                resultsText = "Text recognizer failed with error: \(errorString)"
                return
            }
            resultsText += "\(text.text)"
            self.note.keywords.append(resultsText)
            LKProgressHUD.dismiss()
        }
    }
    
}

private enum Constants {
    static let images = ["image_has_text.jpg"]
    static let detectionNoResultsMessage = "No results returned."
    static let failedToDetectObjectsMessage = "Failed to detect objects in image."
}

// MARK: Configure Add Note Tableview
extension AddNoteViewController {
    
    func configureAddNoteTableView () {
        self.addNoteTableView.separatorColor = .clear
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
extension AddNoteViewController: UITableViewDataSource, CoverDelegate, SelectImagesDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddTitleTableViewCell.self), for: indexPath)
            guard let addTitleCell = cell as? AddTitleTableViewCell else { return cell }
            addTitleCell.dataHandler = { [weak self] title in
                self?.note.title = title
            }
            return addTitleCell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddContentTableViewCell.self), for: indexPath)
            guard let addContentCell = cell as? AddContentTableViewCell else { return cell }
            addContentCell.dataHandler = {  [weak self] content in
                self?.note.content = content
            }
            return addContentCell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddKeywordsTableViewCell.self), for: indexPath)
            guard let addKeywordsCell = cell as? AddKeywordsTableViewCell else { return cell }
            addKeywordsCell.dataHandler = { [weak self] selectedTags, selectedCategory in
                self?.note.category = selectedCategory
                self?.note.keywords = selectedTags
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
            addPhotosCell.hideDeleteButton()
            for item in 0...3 {
                addPhotosCell.bookImageViews[item].image = UIImage(systemName: "text.book.closed")
            }
            for item in 0..<contentImages.count {
                addPhotosCell.bookImageViews[item].image = contentImages[item]
                for button in addPhotosCell.deleteButtons where button.tag == item {
                    button.isHidden = false
                }
            }
            return addPhotosCell
        }
    }
    
}

// MARK: Table View Delegate
extension AddNoteViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 300
        } else {
            return  UITableView.automaticDimension
        }
    }
    
}

// MARK: UIIMagePicker Delegate
extension AddNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func deleteImage(_ index: Int) {
        self.contentImages.remove(at: index)
        addNoteTableView.reloadData()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if  picker == imagePickerController {
            if let image = info[.editedImage] as? UIImage {
                coverImage = image
                LKProgressHUD.show()
                self.detectLabels(image: coverImage, shouldUseCustomModel: false)
            }
        } else {
            if let image = info[.originalImage] as? UIImage {
                if self.contentImages.count < 4 {
                    self.contentImages.insert(image, at: 0)
                } else {
                    self.contentImages.remove(at: 3)
                    self.contentImages.insert(image, at: 0)
                }
            }
        }
        addNoteTableView.reloadData()
        picker.dismiss(animated: true)
    }
    
    func deleteButtonDidSelect() {
        self.coverImage = UIImage(systemName: "magazine")
        self.addNoteTableView.reloadData()
    }
    
    func buttonDidSelect() {
        let controller = UIAlertController(title: "???????????????", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        // Camera
        let cameraAction = UIAlertAction(title: "??????", style: .default) { _ in
            self.takePicture()
        }
        cameraAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(cameraAction)
        
        // Album
        let savedPhotosAlbumAction = UIAlertAction(title: "??????", style: .default) { _ in
            self.openPhotosAlbum()
        }
        savedPhotosAlbumAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(savedPhotosAlbumAction)
        
        // Drawing Pad
        let drawingPadAction = UIAlertAction(title: "?????????", style: .default) { _ in
            self.openDrawingPad()
        }
        drawingPadAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(drawingPadAction)
        
        // Cancel
        let cancelAction = UIAlertAction(title: "??????", style: .destructive, handler: nil)
        controller.addAction(cancelAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    func takePicture() {
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true)
    }
    
    func openPhotosAlbum() {
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true)
    }
    
    func openDrawingPad() {
        let storyBoard = UIStoryboard(name: "DrawingPad", bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: "DrawingPadViewController") as? DrawingPadViewController else { return }
        self.navigationController?.pushViewController(viewController, animated: true)
        viewController.imageProvider = { [weak self] image in
            self?.coverImage = image
            self?.addNoteTableView.reloadData()
        }
    }
    
}

extension AddNoteViewController: PHPickerViewControllerDelegate{
    
    func selectMultiImages() {
        let controller = UIAlertController(title: "???????????????", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        // Camera
        let cameraAction = UIAlertAction(title: "??????", style: .default) { _ in
            self.takePictureForMulti()
        }
        cameraAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(cameraAction)
        
        // Album
        let savedPhotosAlbumAction = UIAlertAction(title: "??????", style: .default) { _ in
            self.openPhotosAlbumForMulti()
        }
        savedPhotosAlbumAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(savedPhotosAlbumAction)
        
        // Drawing Pad
        let drawingPadAction = UIAlertAction(title: "?????????", style: .default) { _ in
            self.openDrawingPadForMulti()
        }
        drawingPadAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(drawingPadAction)
        
        // Cancel
        let cancelAction = UIAlertAction(title: "??????", style: .destructive, handler: nil)
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
                            // ??????????????????4???
                            if self.contentImages.count < 4 {
                                self.contentImages.insert(image, at: 0)
                                self.detectLabels(image: image, shouldUseCustomModel: false)
                            } else {
                                self.contentImages.remove(at: 3)
                                self.contentImages.insert(image, at: 0)
                                self.detectLabels(image: image, shouldUseCustomModel: false)
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
    
    func openPhotosAlbumForMulti() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 4
        let pHPImagePicker = PHPickerViewController(configuration: configuration)
        pHPImagePicker.delegate = self
        self.present(pHPImagePicker, animated: true)
    }
    
    func takePictureForMulti() {
        multiImagePickerController.sourceType = .camera
        self.present(multiImagePickerController, animated: true)
    }
    
    func openDrawingPadForMulti() {
        let storyBoard = UIStoryboard(name: "DrawingPad", bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: "DrawingPadViewController") as? DrawingPadViewController else { return }
        self.navigationController?.pushViewController(viewController, animated: true)
        viewController.imageProvider = { [weak self] image in
                if self?.contentImages.count ?? 0 < 4 {
                    self?.contentImages.insert(image, at: 0)
                } else {
                    self?.contentImages.remove(at: 3)
                    self?.contentImages.insert(image, at: 0)
                }
                DispatchQueue.main.async {
                    self?.addNoteTableView.reloadData()
                }
        }
    }
    
}

extension AddNoteViewController {
    func uploadNote() {
        if note.title != "" && note.content != "" && note.category != "" && note.keywords != [] && coverImage != UIImage(systemName: "magazine") && contentImages != [] {
            upload()
        } else {
            let controller = UIAlertController(title: "?????????????????????", message: "", preferredStyle: .alert)
            controller.view.tintColor = UIColor.gray
            let cancelAction = UIAlertAction(title: "??????", style: .destructive, handler: nil)
            cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func upload() {
        let group = DispatchGroup()
        let controller = UIAlertController(title: "????????????", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        group.enter()
        LKProgressHUD.show()
        guard let image = coverImage else { return }
        NoteManager.shared.uploadPhoto(image: image) { result in
            switch result {
            case .success(let url):
                self.note.cover = "\(url)"
                print("\(url)")
            case .failure(let error):
                print("\(error)")
            }
            group.leave()
        }
        
        let images = contentImages
        for image in images {
            group.enter()
            NoteManager.shared.uploadPhoto(image: image) { result in
                switch result {
                case .success(let url):
                    self.note.images.append("\(url)")
                    print("\(url)")
                case .failure(let error):
                    print("\(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.global()) {
            NoteManager.shared.createNote(note: &self.note) { result in
                switch result {
                case .success(let noteId):
                    let cancelAction = UIAlertAction(title: "??????", style: .destructive) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                    guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
                    UserManager.shared.fetchUser(uid) { result in
                        switch result {
                        case .success(let user):
                            self.user = user
                            self.user?.userNotes.append(noteId)
                            guard let userToBeUpdated = self.user else { return }
                            UserManager.shared.updateUser(user: userToBeUpdated, uid: uid) { result in
                                switch result {
                                case .success:
                                    DispatchQueue.main.async {
                                        LKProgressHUD.dismiss()
                                        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
                                        controller.addAction(cancelAction)
                                        self.present(controller, animated: true, completion: nil)
                                    }
                                case .failure:
                                    self.showBasicConfirmationAlert("??????????????????", "?????????????????????")
                                }
                            }
                        case .failure:
                            self.showBasicConfirmationAlert("??????????????????", "?????????????????????")
                        }
                    }
                case.failure:
                    self.showBasicConfirmationAlert("??????????????????", "?????????????????????")
                }
            }
        }
    }
    
}
