//
//  NoteDetailViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/21.
//

import UIKit
import Kingfisher

class NoteDetailViewController: UIViewController {
    
    @IBOutlet weak var noteDetailCollectionView: UICollectionView!
    
    @IBOutlet weak var commentTextFiled: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    // Data
    var note = Note(authorId: "",
                    comments: [],
                    createdTime: Date(),
                    likes: [],
                    category: "",
                    clicks: [],
                    content: "",
                    cover: "",
                    noteId: "",
                    images: [],
                    keywords: [],
                    title: "")
    
    var users: [User] = []
    
    var currentUser: User?
    
    var editButton = UIBarButtonItem()
    
    // Data Manager
    private var noteManager = NoteManager()
    private var userManager = UserManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register Cell
        registerCell()
        
        // CollectionView DataSource
        noteDetailCollectionView.dataSource = self
        
        // CollectionView Layout
        noteDetailCollectionView.collectionViewLayout = configureLayout()
        
        // Edit Button
        editButton  = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(toEditPage))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //  Edit Button Enable
        if note.authorId == currentUser?.uid {
            self.navigationItem.rightBarButtonItem = editButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    @IBAction func sendComment(_ sender: Any) {
        
        guard let content = commentTextFiled.text else {
            sendButton.isEnabled = false
            return
        }
        
        let newComment = Comment(content: content, createdTime: Date(), uid: FirebaseManager.shared.currentUser?.uid ?? "")
        note.comments.append(newComment)
        note.comments.sort{
            ( $0.createdTime ) < ( $1.createdTime )
        }
        
        noteManager.updateNote(note: self.note, noteId: self.note.noteId) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.noteDetailCollectionView.reloadData()
                    if self?.note.comments != [] {
                        self?.noteDetailCollectionView.scrollToItem(at: [3, (self?.note.comments.count ?? 1) - 1], at: .right, animated: true)
                    }
                }
            case .failure(let error):
                print("fetchData.failure: \(error)")
            }
        }
    }
}

// MARK: To edit page
extension NoteDetailViewController {
    @objc private func toEditPage() {
        let storyBoard = UIStoryboard(name: "AddContent", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "EditNoteViewController") as? EditNoteViewController else { return }
        vc.note = self.note
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: CollectionView Register Cell
extension NoteDetailViewController {
    private func registerCell() {
        noteDetailCollectionView.register(NoteCarouselCollectionViewCell.self, forCellWithReuseIdentifier: NoteCarouselCollectionViewCell.reuseIdentifer)
        noteDetailCollectionView.registerCellWithNib(identifier: String(describing: NoteTitleCollectionViewCell.self), bundle: nil)
        noteDetailCollectionView.register(NoteContentCollectionViewCell.self, forCellWithReuseIdentifier: NoteContentCollectionViewCell.reuseIdentifer)
        noteDetailCollectionView.registerCellWithNib(identifier: String(describing: NoteCommentCollectionViewCell.self), bundle: nil)
        noteDetailCollectionView.register(TitleSupplementaryView.self,
                                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                          withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    }
}

// MARK: Save Note
extension NoteDetailViewController: NoteTitleDelegate {
    
    func saveNote(_ selectedCell: NoteTitleCollectionViewCell) {
        
        guard let currentUser = FirebaseManager.shared.currentUser else {
            
            guard let vc = UIStoryboard.auth.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            
            vc.modalPresentationStyle = .overCurrentContext
            
            self.tabBarController?.present(vc, animated: false, completion: nil)
            
            return
            
        }
        
        if selectedCell.saveButton.imageView?.image == UIImage(systemName: "suit.heart") {
            
            self.note.likes.append(currentUser.uid)
            
        } else {
            
            self.note.likes = self.note.likes.filter{ $0 != currentUser.uid }
            
        }
        
        NoteManager.shared.updateNote(note: note, noteId: note.noteId) { result in
            
            switch result {
                
            case .success:
                
                self.fetchNote()
                
                var userToBeUpdated: User?
                
                for user in self.users where user.uid == FirebaseManager.shared.currentUser?.uid{
                    
                    userToBeUpdated = user
                    
                }
                
                if selectedCell.saveButton.imageView?.image == UIImage(systemName: "suit.heart") {
                    
                    let user = userToBeUpdated
                    
                    userToBeUpdated?.savedNotes =  user?.savedNotes.filter{ $0 != "\(self.note.noteId)" } ?? []
                    
                    userToBeUpdated?.savedNotes.append(self.note.noteId)
                    
                } else {
                    
                    let user = userToBeUpdated
                    
                    userToBeUpdated?.savedNotes =  user?.savedNotes.filter{ $0 != "\(self.note.noteId)" } ?? []
                    
                }
                
                guard let userToBeUpdated = userToBeUpdated else {
                    return
                }
                
                self.userManager.updateUser(user: userToBeUpdated, uid: userToBeUpdated.uid) { result in
                    
                    switch result {
                        
                    case .success:
                        
                        self.noteDetailCollectionView.reloadData()
                        
                        print("收藏成功")
                        
                    case .failure:
                        
                        print("收藏失敗")
                        
                    }
                }
                
            case .failure:
                
                print("收藏失敗")
            }
            
        }
        
    }
    
    func fetchNote() {
        
        NoteManager.shared.fetchNote(self.note.noteId) { result in
            
            switch result {
                
            case .success(let note):
                
                self.note = note
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
            
        }
        
    }
    
}


// MARK: CollectionView DataSource
extension NoteDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return note.images.count ?? 0
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return note.comments.count ?? 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCarouselCollectionViewCell.reuseIdentifer, for: indexPath)
                    as? NoteCarouselCollectionViewCell else { return UICollectionViewCell()}
            let url = URL(string: note.images[indexPath.item])
            cell.photoView.kf.indicatorType = .activity
            cell.photoView.kf.setImage(with: url)
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: NoteTitleCollectionViewCell.self), for: indexPath)
                    as? NoteTitleCollectionViewCell else { return UICollectionViewCell()}
            cell.delegate = self
            cell.viewsLabel.text = "\(note.clicks.count)"
            cell.commentCountsLabel.text = "\(note.comments.count)"
            
            // Highlight saved note
            cell.saveButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            for like in note.likes {
                if like == FirebaseManager.shared.currentUser?.uid {
                    cell.saveButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
                }
            }
            
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteContentCollectionViewCell.reuseIdentifer, for: indexPath)
                    as? NoteContentCollectionViewCell else { return UICollectionViewCell()}
            cell.contentLabel.text = note.content
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: NoteCommentCollectionViewCell.self), for: indexPath)
                    as? NoteCommentCollectionViewCell else { return UICollectionViewCell()}
            cell.commentLabel.text = note.comments[indexPath.item].content
            
            // querying users' name & avatar
            for user in users where user.uid == note.comments[indexPath.item].uid {
                cell.nameLabel.text = user.userName
                let url = URL(string: user.userAvatar)
                cell.avatarImageView.kf.indicatorType = .activity
                cell.avatarImageView.kf.setImage(with: url)
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath)
                as? TitleSupplementaryView else { return UICollectionReusableView() }
        
        switch indexPath.section {
        case 0:
            header.textLabel.text = ""
            return header
        case 1:
            header.textLabel.text = note.title
            return header
        case 2:
            header.textLabel.text = "內容"
            return header
        case 3:
            header.textLabel.text = "評論"
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

// MARK: CollectionView Compositional Layout
extension NoteDetailViewController {
    
    private func configureLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            switch sectionIndex {
            case 0:
                return self.configLargeSection()
            case 1, 2 :
                return self.configMidiumSection()
            case 3:
                return self.configCommentSection()
                
            default:
                return self.configLargeSection()
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func configLargeSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .fractionalHeight(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func configMidiumSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(300), heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func configCommentSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(300), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
}
