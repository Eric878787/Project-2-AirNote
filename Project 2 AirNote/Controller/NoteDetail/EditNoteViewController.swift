//
//  EditNoteViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/23.
//

import UIKit
import PhotosUI
import Kingfisher
import MLKit

class EditNoteViewController: BaseViewController {
    
    // MARK: Properties
    private var addNoteTableView = UITableView(frame: .zero)
    var note: Note?
    private let imagePickerController = UIImagePickerController()
    private var coverImage = UIImage(systemName: "magazine")
    private let multiImagePickerController = UIImagePickerController()
    private var contentImages: [UIImage] = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NavigationItemTitle.editNote.rawValue
        configureAddNoteTableView()
        imagePickerController.delegate = self
        multiImagePickerController.delegate = self
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "clear"), style: .plain, target: self, action: #selector(deleteNote))
        deleteButton.tintColor = .red
        self.navigationItem.rightBarButtonItem = deleteButton
        setDefaultImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}

// MARK: Default Image
extension EditNoteViewController {
    private func setDefaultImage() {
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

// MARK: Delete Note
extension EditNoteViewController {
    @objc private func deleteNote() {
        showAlternativeAlert("是否要刪除筆記", "刪除後即無法回復內容", {
            LKProgressHUD.show()
            self.confirmDeletion()
        }, {
            return
        })
    }
    
    func confirmDeletion() {
        guard let noteToBeDeleted = note?.noteId else { return }
        NoteManager.shared.deleteNote(noteId: noteToBeDeleted) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    LKProgressHUD.dismiss()
                    self.showBasicConfirmationAlert("刪除成功", nil) {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            case.failure:
                DispatchQueue.main.async {
                    LKProgressHUD.dismiss()
                    self.showBasicConfirmationAlert("刪除失敗", nil) {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
            
        }
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
        addNoteTableView.separatorStyle = .none
        addNoteTableView.dataSource = self
        addNoteTableView.delegate = self
        addNoteTableView.separatorStyle = .none
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
extension EditNoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 1 {
//            return 300
//        } else if indexPath.row == 4 {
//            return 600
//        } else {
//            return  UITableView.automaticDimension
//        }
        if indexPath.row == 1 {
            return 300
        } else {
            return  UITableView.automaticDimension
        }
    }
}
// MARK: ML Kit
extension EditNoteViewController {
    
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
            self.note?.keywords.append(resultsText)
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
            self.note?.keywords.append(resultsText)
            LKProgressHUD.dismiss()
        }
    }
    
}

private enum Constants {
    static let images = ["image_has_text.jpg"]
    static let detectionNoResultsMessage = "No results returned."
    static let failedToDetectObjectsMessage = "Failed to detect objects in image."
}

// MARK: UIIMagePicker Delegate
extension EditNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
                }  else {
                    self.contentImages.remove(at: 3)
                    self.contentImages.insert(image, at: 0)
                }
            }
        }
        addNoteTableView.reloadData()
        picker.dismiss(animated: true)
    }
    
    func deleteImage(_ index: Int) {
        self.contentImages.remove(at: index)
        addNoteTableView.reloadData()
    }
    
    
    func deleteButtonDidSelect() {
        coverImage = nil
        addNoteTableView.reloadData()
    }
    
    func buttonDidSelect() {
        let controller = UIAlertController(title: "請上傳筆記", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        // Camera
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            self.takePicture()
        }
        cameraAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(cameraAction)
        
        // Album
        let savedPhotosAlbumAction = UIAlertAction(title: "相簿", style: .default) { _ in
            self.openPhotosAlbum()
        }
        savedPhotosAlbumAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(savedPhotosAlbumAction)
        
        // Drawing Pad
        let drawingPadAction = UIAlertAction(title: "手繪板", style: .default) { _ in
            self.openDrawingPad()
        }
        drawingPadAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(drawingPadAction)
        
        // Cancel
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        controller.addAction(cancelAction)
        self.present(controller, animated: true, completion: nil)
        
    }
    
    // Open Camera
    func takePicture() {
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true)
    }
    
    // Open Album
    func openPhotosAlbum() {
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true)
    }
    
    // Open Drawing Pad
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

extension EditNoteViewController: PHPickerViewControllerDelegate{
    
    func selectMultiImages() {
        let controller = UIAlertController(title: "請上傳筆記", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        // Camera
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            self.takePictureForMulti()
        }
        cameraAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(cameraAction)
        
        // Album
        let savedPhotosAlbumAction = UIAlertAction(title: "相簿", style: .default) { _ in
            self.openPhotosAlbumForMulti()
        }
        savedPhotosAlbumAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(savedPhotosAlbumAction)
        
        // Drawing Pad
        let drawingPadAction = UIAlertAction(title: "手繪板", style: .default) { _ in
            self.openDrawingPadForMulti()
        }
        drawingPadAction.setValue(UIColor.black, forKey: "titleTextColor")
        controller.addAction(drawingPadAction)
        
        // Cancel
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
                                self.detectLabels(image: image, shouldUseCustomModel: false)
                            }  else {
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
        // MARK: Multi - images Picker
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
            if let image = image as? UIImage {
                if self?.contentImages.count ?? 0 < 4 {
                    self?.contentImages.insert(image, at: 0)
                }  else {
                    self?.contentImages.remove(at: 3)
                    self?.contentImages.insert(image, at: 0)
                }
                DispatchQueue.main.async {
                    self?.addNoteTableView.reloadData()
                }
            }
        }
    }
    
}

extension EditNoteViewController {
    
    func uploadNote() {
        guard let note = self.note else { return }
        if note.title != "" && note.content != "" && note.category != "" && note.keywords != [] && coverImage != UIImage(systemName: "magazine") && contentImages != [] {
            upload()
        } else {
            showBasicConfirmationAlert("請上傳完整資料", nil)
        }
    }
    
    func upload() {
        let group = DispatchGroup()
        group.enter()
        LKProgressHUD.show()
        guard let image = coverImage else { return }
        NoteManager.shared.uploadPhoto(image: image) { result in
            switch result {
            case .success(let url):
                self.note?.cover = "\(url)"
            case .failure:
                return
            }
            group.leave()
        }
        
        let images = contentImages
        self.note?.images = []
        for image in images {
            group.enter()
            NoteManager.shared.uploadPhoto(image: image) { result in
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
            guard let editedNote = self.note else { return }
            NoteManager.shared.updateNote(note: editedNote, noteId: editedNote.noteId) { [weak self] result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        LKProgressHUD.dismiss()
                        self?.showBasicConfirmationAlert("更新成功", nil) {
                            self?.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                case.failure:
                    LKProgressHUD.dismiss()
                    self?.showBasicConfirmationAlert("更新失敗", "請檢查網路連線") {
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }
    
}
