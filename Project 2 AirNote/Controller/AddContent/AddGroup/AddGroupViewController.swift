//
//  AddGroupViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/18.
//

import UIKit
import PhotosUI
import CoreLocation
import MLKit

class AddGroupViewController: BaseViewController {
    
    // MARK: Properties
    private var addGroupTableView = UITableView(frame: .zero)
    private var group = Group(schedules: [Schedule(date: Date(), title: "")],
                              createdTime: Date(),
                              groupCategory: "",
                              groupKeywords: [],
                              groupContent: "",
                              groupCover: "",
                              groupId: "",
                              groupMembers: [],
                              groupOwner: "",
                              groupTitle: "",
                              location: Location(address: "", latitude: 0, longitude: 0), messages: [])
    private var user: User?
    private let imagePickerController = UIImagePickerController()
    private var coverImage = UIImage(systemName: "magazine")
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NavigationItemTitle.createGroup.rawValue
        imagePickerController.delegate = self
        configureAddGroupTableView()
    }
    
}

// MARK: Configure Add Group Tableview
extension AddGroupViewController {
    
    func configureAddGroupTableView () {
        self.addGroupTableView.separatorColor = .clear
        addGroupTableView.registerCellWithNib(identifier: String(describing: AddTitleTableViewCell.self), bundle: nil)
        addGroupTableView.registerCellWithNib(identifier: String(describing: AddContentTableViewCell.self), bundle: nil)
        addGroupTableView.registerCellWithNib(identifier: String(describing: AddKeywordsTableViewCell.self),
                                              bundle: nil)
        addGroupTableView.registerCellWithNib(identifier: String(describing: AddCalendarTableViewCell.self),
                                              bundle: nil)
        addGroupTableView.registerCellWithNib(identifier: String(describing: AddCoverTableViewCell.self), bundle: nil)
        addGroupTableView.registerCellWithNib(identifier: String(describing: AddAddressTableViewCell.self), bundle: nil)
        addGroupTableView.registerHeaderWithNib(identifier: String(describing: AddCalendarHeaderView.self), bundle: nil)
        addGroupTableView.dataSource = self
        addGroupTableView.delegate = self
        if #available(iOS 15.0, *) {
            addGroupTableView.sectionHeaderTopPadding = 0.0
        }
        addGroupTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addGroupTableView)
        addGroupTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: 15).isActive = true
        addGroupTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        addGroupTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        addGroupTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
}

// MARK: Table View DataSource
extension AddGroupViewController: UITableViewDataSource, CoverDelegate, AddCalendarHeaderViewDelegate {
    
    func addCalendar(_ header: AddCalendarHeaderView) {
        self.group.schedules.append(Schedule(date: Date(), title: ""))
        addGroupTableView.reloadSections(IndexSet(integer: 3), with: .automatic)
    }
    
    func minusCalendar(_ header: AddCalendarHeaderView) {
        self.group.schedules.removeLast()
        addGroupTableView.reloadSections(IndexSet(integer: 3), with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = addGroupTableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: AddCalendarHeaderView.self) )
                as? AddCalendarHeaderView else { return UITableViewHeaderFooterView() }
        if section == 3 {
            header.delegate = self
            let count = group.schedules.count
            if  count >= 5 {
                header.addButton.isEnabled = false
                
            } else if count <= 1 {
                header.minusButton.isEnabled = false
            } else {
                
                header.addButton.isEnabled = true
                
                header.minusButton.isEnabled = true
            }
            return  header
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return UITableView.automaticDimension
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return group.schedules.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddTitleTableViewCell.self), for: indexPath)
            guard let addTitleCell = cell as? AddTitleTableViewCell else { return cell }
            addTitleCell.dataHandler = { [weak self] title in
                self?.group.groupTitle = title
            }
            return addTitleCell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddContentTableViewCell.self), for: indexPath)
            guard let addContentCell = cell as? AddContentTableViewCell else { return cell }
            addContentCell.dataHandler = {  [weak self] content in
                self?.group.groupContent = content
            }
            return addContentCell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddKeywordsTableViewCell.self), for: indexPath)
            guard let addKeywordsCell = cell as? AddKeywordsTableViewCell else { return cell }
            addKeywordsCell.dataHandler = { [weak self] selectedTags, selectedCategory in
                self?.group.groupCategory = selectedCategory
                self?.group.groupKeywords = selectedTags
            }
            return addKeywordsCell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddCalendarTableViewCell.self), for: indexPath)
            guard let addCalendarCell = cell as? AddCalendarTableViewCell else { return cell }
            addCalendarCell.datePicker.date = self.group.schedules[indexPath.row].date
            addCalendarCell.textField.text =  self.group.schedules[indexPath.row].title
            addCalendarCell.dateHandler  = { [weak self] date in
                self?.group.schedules[indexPath.row].date = date
            }
            addCalendarCell.textHandler = { [weak self] text in
                self?.group.schedules[indexPath.row].title = text
            }
            return addCalendarCell
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddCoverTableViewCell.self), for: indexPath)
            guard let addCoverCell = cell as? AddCoverTableViewCell else { return cell }
            addCoverCell.delegate = self
            addCoverCell.coverImageView.image = coverImage
            return addCoverCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddAddressTableViewCell.self), for: indexPath)
            guard let addAddressCell = cell as? AddAddressTableViewCell else { return cell }
            addAddressCell.delegate = self
            let geoCoder = CLGeocoder()
            addAddressCell.textField.text = group.location.address
            addAddressCell.dataHandler = { [weak self] address in
                self?.group.location.address = address
                geoCoder.geocodeAddressString(address) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location
                    else {
                        print("location not found")
                        return
                    }
                    self?.group.location.latitude = location.coordinate.latitude
                    self?.group.location.longitude = location.coordinate.longitude
                }
            }
            return addAddressCell
        }
    }
    
}

// MARK: Table View Delegate
extension AddGroupViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 300
        } else {
            return  UITableView.automaticDimension
        }
    }
    
}

// MARK: ML Kit
extension AddGroupViewController {
    
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
                print("Self is nil!")
                return
            }
            guard error == nil, let labels = labels, !labels.isEmpty else {
                return
            }
            
            // [START_EXCLUDE]
            resultsText = labels.map { label -> String in
                return "Label: \(label.text), Confidence: \(label.confidence), Index: \(label.index)"
            }.joined(separator: "\n")
            self.group.groupKeywords.append(resultsText)
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
            self.group.groupKeywords.append(resultsText)
            print("xxxxxxxxxx\(resultsText)")
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
extension AddGroupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            coverImage = image
            LKProgressHUD.show()
            self.detectLabels(image: coverImage, shouldUseCustomModel: false)
        }
        addGroupTableView.reloadData()
        picker.dismiss(animated: true)
    }
    
    func deleteButtonDidSelect() {
        coverImage = UIImage(systemName: "magazine")
        addGroupTableView.reloadData()
    }
    
    func buttonDidSelect() {
        let controller = UIAlertController(title: "請上傳封面", message: "", preferredStyle: .alert)
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
            self?.addGroupTableView.reloadData()
        }
    }
    
}

extension AddGroupViewController: UploadDelegate, CafeAddressDelegate {
    func passAddress(_ cafe: Cafe) {
        group.location.address = cafe.address
        group.location.latitude = Double(cafe.latitude) ?? 0
        group.location.longitude = Double(cafe.longitude) ?? 0
        addGroupTableView.reloadData()
    }
        
    func searchCafe() {
        let storyBoard = UIStoryboard(name: "AddContent", bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: "CafeMapViewController") as? CafeMapViewController else { return }
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func selectButton() {
        if group.groupCategory != "" && group.groupContent != ""
            && group.groupTitle != "" && group.groupKeywords != []
            && coverImage != UIImage(systemName: "magazine")
            && group.location.latitude != 0 && group.location.longitude != 0
            && group.location.address != ""
        {
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
        group.enter()
        LKProgressHUD.show()
        guard let image = coverImage else { return }
        GroupManager.shared.uploadPhoto(image: image) { result in
            switch result {
            case .success(let url):
                self.group.groupCover = "\(url)"
                print("\(url)")
            case .failure(let error):
                print("\(error)")
            }
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.global()) {
            GroupManager.shared.createGroup(group: self.group) { result in
                switch result {
                case .success(let groupId):
                    self.fetchAndUpdateUser(groupId: groupId)
                case.failure:
                    print(result)
                }
            }
        }
    }
    
}

// MARK: Fetch and Update User
extension AddGroupViewController {
    func fetchAndUpdateUser(groupId: String) {
        let controller = UIAlertController(title: "上傳成功", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        guard let uid = FirebaseManager.shared.currentUser?.uid else { return }
        UserManager.shared.fetchUser(uid) { result in
            switch result {
            case .success(let user):
                self.user = user
                self.user?.userGroups.append(groupId)
                self.user?.joinedGroups.append(groupId)
                guard let userToBeUpdated = self.user else { return }
                UserManager.shared.updateUser(user: userToBeUpdated, uid: uid) { result in
                    switch result {
                    case .success:
                        let cancelAction = UIAlertAction(title: "確認", style: .destructive) { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                        DispatchQueue.main.async {
                            cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
                            controller.addAction(cancelAction)
                            LKProgressHUD.dismiss()
                            self.present(controller, animated: true, completion: nil)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure:
                self.showBasicConfirmationAlert("上傳失敗", "請檢查網路連線")
            }
        }
    }
}
