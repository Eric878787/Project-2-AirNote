//
//  AddNoteViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/13.
//

import UIKit
import PhotosUI

class AddNoteViewController: UIViewController {
    
    // MARK: Table View
    private var addNoteTableView = UITableView(frame: .zero)
    
    // MARK: Properties
    
    private var note = Note(authorId: "",
                            comments: [Comment(content: "", createdTime: Date(), userId: "")],
                            createdTime: Date(),
                            likes: [], noteCategory: "",
                            noteClicks: [], noteContent: "",
                            noteCover: "", noteId: "",
                            noteImages: [], noteKeywords: [],
                            noteTitle: "")
    
    private var noteTitle: String?
    
    private var noteContent: String?
    
    private var noteCategory: String?
    
    private var noteKeywords: [String] = []
    
    // MARK: Cover Image
    private let imagePickerController = UIImagePickerController()
    
    private var coverImage = UIImage(systemName: "magazine")
    
    private var coverImageToDB: String?
    
    // MARK: Content Images
    
    private let multiImagePickerController = UIImagePickerController()
    
    private var contentImages: [UIImage] = []
    
    private var contentImageToDB: [String] = []
    
    // MARK: Data Manager
    
    private var noteManager = NoteManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        navigationItem.title = "新增筆記"
        
        // Init addNoteTableView
        configureAddNoteTableView()
        
        // Image Picker Delegate
        imagePickerController.delegate = self
        multiImagePickerController.delegate = self
        
    }
    
}

// MARK: Configure Add Note Tableview
extension AddNoteViewController {
    
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
extension AddNoteViewController: UITableViewDataSource, CoverDelegate, SelectImagesDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddTitleTableViewCell.self), for: indexPath)
            guard let addTitleCell = cell as? AddTitleTableViewCell else { return cell }
            addTitleCell.dataHandler = { [weak self] title in
                self?.note.noteTitle = title
            }
            return addTitleCell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddContentTableViewCell.self), for: indexPath)
            guard let addContentCell = cell as? AddContentTableViewCell else { return cell }
            addContentCell.dataHandler = {  [weak self] content in
                self?.note.noteContent = content
            }
            return addContentCell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddKeywordsTableViewCell.self), for: indexPath)
            guard let addKeywordsCell = cell as? AddKeywordsTableViewCell else { return cell }
            addKeywordsCell.dataHandler = { [weak self] selectedTags, selectedCategory in
                self?.note.noteCategory = selectedCategory
                self?.note.noteKeywords = selectedTags
            }
            return addKeywordsCell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddCoverTableViewCell.self), for: indexPath)
            guard let addCoverCell = cell as? AddCoverTableViewCell else { return cell }
            addCoverCell.delegate = self
            addCoverCell.coverImageView.image = coverImage ?? UIImage(systemName: "magazine")
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
extension AddNoteViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100
        } else if indexPath.row == 1 {
            return 300
        } else if indexPath.row == 2 {
            return 165
        } else if indexPath.row == 3{
            return 500
        } else {
            return 600
        }
    }
    
}

// MARK: UIIMagePicker Delegate
extension AddNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func buttonDidSelect() {
        
        let controller = UIAlertController(title: "拍照?從照片選取?從相簿選取?", message: "", preferredStyle: .alert)
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
        
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
        
    }
    
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
}

extension AddNoteViewController: PHPickerViewControllerDelegate{
    
    func selectMultiImages() {
        
        let controller = UIAlertController(title: "拍照?從照片選取?從相簿選取?", message: "", preferredStyle: .alert)
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

extension AddNoteViewController {
    func uploadNote() {
        let group = DispatchGroup()
        
        group.enter()
        guard let image = coverImage else {return}
        noteManager.uploadPhoto(image: image) { result in
            switch result {
            case .success(let url):
                self.note.noteCover = "\(url)"
                print("\(url)")
            case .failure(let error):
                print("\(error)")
            }
            group.leave()
        }
        
        let images = contentImages
        if images != [] {
            for image in images {
                group.enter()
                noteManager.uploadPhoto(image: image) { result in
                    switch result {
                    case .success(let url):
                        self.note.noteImages.append("\(url)")
                        print("\(url)")
                    case .failure(let error):
                        print("\(error)")
                    }
                    group.leave()
                }
            }
        } else { return }
        
        group.notify(queue: DispatchQueue.global()) {
            print("\(self.note)")
            self.noteManager.createNote(note: self.note) { result in
                switch result {
                case .success:
                    print("upload note succeeded")
                case.failure:
                    print("upload note failed")
                }
            }
        }
    }
}
