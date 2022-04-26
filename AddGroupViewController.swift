//
//  AddGroupViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/18.
//

import UIKit
import PhotosUI
import CoreLocation

class AddGroupViewController: UIViewController {
    
    // MARK: Table View
    private var addGroupTableView = UITableView(frame: .zero)
    
    // MARK: Properties
    private var group = Group(schedules: [],
                              createdTime: Date(),
                              groupCategory: "",
                              groupKeywords: [],
                              groupContent: "",
                              groupCover: "",
                              groupId: "",
                              groupMembers: [],
                              groupOwner: "",
                              groupTitle: "",
                              location: Location(address: "", latitude: 0, longitude: 0))
    
    private var room = ChatRoom (chatRoomId: "", groupId: "", messages: [], roomTitle: "", ownerId: "", createdTime: Date())
    
    // MARK: Cover Image
    private let imagePickerController = UIImagePickerController()

    private var coverImage = UIImage(systemName: "magazine")
    
    // MARK: Data Manager
    private var groupManager = GroupManager()
    private var chatRoomManager = ChatRoomManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        navigationItem.title = "新增讀書會"
        
        // Image Picker
        imagePickerController.delegate = self
        
        // Set up Tableview
        configureAddGroupTableView ()
    }
    
}

// MARK: Configure Add Group Tableview
extension AddGroupViewController {
    
    func configureAddGroupTableView () {
        
        addGroupTableView.registerCellWithNib(identifier: String(describing: AddTitleTableViewCell.self), bundle: nil)
        addGroupTableView.registerCellWithNib(identifier: String(describing: AddContentTableViewCell.self), bundle: nil)
        addGroupTableView.registerCellWithNib(identifier: String(describing: AddKeywordsTableViewCell.self), bundle: nil)
        addGroupTableView.registerCellWithNib(identifier: String(describing: AddCalendarTableViewCell.self), bundle: nil)
        addGroupTableView.registerCellWithNib(identifier: String(describing: AddCoverTableViewCell.self), bundle: nil)
        addGroupTableView.registerCellWithNib(identifier: String(describing: AddAddressTableViewCell.self), bundle: nil)
        addGroupTableView.dataSource = self
        addGroupTableView.delegate = self
        addGroupTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addGroupTableView)
        
        addGroupTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        addGroupTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        addGroupTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        addGroupTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
}

// MARK: Table View DataSource
extension AddGroupViewController: UITableViewDataSource, CoverDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddTitleTableViewCell.self), for: indexPath)
            guard let addTitleCell = cell as? AddTitleTableViewCell else { return cell }
            addTitleCell.dataHandler = { [weak self] title in
                self?.group.groupTitle = title
                self?.room.roomTitle = title
            }
            return addTitleCell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddContentTableViewCell.self), for: indexPath)
            guard let addContentCell = cell as? AddContentTableViewCell else { return cell }
            addContentCell.dataHandler = {  [weak self] content in
                self?.group.groupContent = content
            }
            return addContentCell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddKeywordsTableViewCell.self), for: indexPath)
            guard let addKeywordsCell = cell as? AddKeywordsTableViewCell else { return cell }
            addKeywordsCell.dataHandler = { [weak self] selectedTags, selectedCategory in
                self?.group.groupCategory = selectedCategory
                self?.group.groupKeywords = selectedTags
            }
            return addKeywordsCell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddCalendarTableViewCell.self), for: indexPath)
            guard let addCalendarCell = cell as? AddCalendarTableViewCell else { return cell }
            addCalendarCell.calendarHandler = { [weak self] dateArray, textArray in
                
                self?.group.schedules = []
                
                for date in dateArray {
                    let schedule = Schedule(date: date, title: "")
                    self?.group.schedules.append(schedule)
                }
                
                for title in 0..<textArray.count {
                    self?.group.schedules[title].title = textArray[title]
                }
                
            }
            return addCalendarCell
        } else if indexPath.row == 4{
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
//        if indexPath.row == 0 {
//            return 100
//        } else if indexPath.row == 1 {
//            return 300
//        } else if indexPath.row == 2 {
//            return 165
//        } else if indexPath.row == 3{
//            return 500
//        } else {
//            return 500
//        }
    
        if indexPath.row == 1 {
            return 300
        } else {
            return  UITableView.automaticDimension
        }
    }
    
}

// MARK: UIIMagePicker Delegate
extension AddGroupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
                
                coverImage = image
            
        }
        
        addGroupTableView.reloadData()
        
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
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "CafeMapViewController") as? CafeMapViewController else { return }
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
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
        let controller = UIAlertController(title: "上傳成功", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        group.enter()
        guard let image = coverImage else { return }
        self.groupManager.uploadPhoto(image: image) { result in
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
            self.groupManager.createGroup(group: self.group) { result in
                switch result {
                case .success(let groupId):
                    self.room.groupId = groupId
                    self.chatRoomManager.createChatRoom(chatRoom: self.room) { result in
                        switch result {
                        case .success:
                            let cancelAction = UIAlertAction(title: "確認", style: .destructive) { _ in
                                self.navigationController?.popViewController(animated: true)
                            }
                            DispatchQueue.main.async {
                                controller.addAction(cancelAction)
                                self.present(controller, animated: true, completion: nil)
                            }
                        case.failure:
                            print(result)
                        }
                    }
                case.failure:
                    print(result)
                }
            }
        }
    }
}
