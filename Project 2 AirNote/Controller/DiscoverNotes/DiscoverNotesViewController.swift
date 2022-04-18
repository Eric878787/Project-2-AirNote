//
//  Discover Notes View Controller.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/9.
//

import UIKit
import Kingfisher

class DiscoverNotesViewController: UIViewController {
    
    // MARK: CollecitonView Properties
    var categoryCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        var categoryCollecitonView = UICollectionView(
            frame: CGRect.zero,
            collectionViewLayout: layout
        )
        categoryCollecitonView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        categoryCollecitonView.registerCellWithNib(identifier: String(describing: CategoryCollectionViewCell.self), bundle: nil)
        categoryCollecitonView.backgroundColor = .clear
        return categoryCollecitonView
    }()
    
    private var notesCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        var notesCollectionView = UICollectionView(
            frame: CGRect.zero,
            collectionViewLayout: layout
        )
        notesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        notesCollectionView.registerCellWithNib(identifier: String(describing: NotesCollectionViewCell.self), bundle: nil)
        notesCollectionView.backgroundColor = .clear
        return notesCollectionView
    }()
    
    // MARK: Category
    private var selectedCategoryIndex = 0
    var category: [String] = ["所有筆記", "投資理財", "運動健身", "語言學習", "人際溝通", "廣告行銷", "生活風格", "藝文娛樂"]
    
    // MARK: Data Provider
    private var noteManager = NoteManager()
    var userManager = UserManager()
    
    // MARK: Notes Data
    private var notes: [Note] = []
    private var filterNotes: [Note] = []
    
    // MARK: Users Data
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        navigationItem.title = "探索筆記"
        
        // Set Up Category CollectionView
        configureCategoryCollectionView()
        
        // Set Up Notes CollecitonView
        configureNotesCollectionView()
        
        // Search Button
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(toSearchPage))
        self.navigationItem.rightBarButtonItem = searchButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Fetch Notes Data
        fetchNotes()
        
        // Fetch Users Data
        fetchUsers()
        
    }
}

// MARK: Fetch Data
extension DiscoverNotesViewController {
    
    private func fetchNotes() {
        self.noteManager.fetchNotes { [weak self] result in
            
            switch result {
                
            case .success(let existingNote):
                
                DispatchQueue.main.async {
                    self?.notes = existingNote
                    self?.filterNotes = self?.notes ?? existingNote
                    self?.notesCollectionView.reloadData()
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    private func fetchUsers() {
        self.userManager.fetchUsers { [weak self] result in
            
            switch result {
                
            case .success(let existingUser):
                
                DispatchQueue.main.async {
                    self?.users = existingUser
                    self?.notesCollectionView.reloadData()
                }
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    
}

// MARK: To Next Page
extension DiscoverNotesViewController {
    
    @objc private func toSearchPage() {
        let storyBoard = UIStoryboard(name: "SearchContent", bundle: nil)
        guard let vc =  storyBoard.instantiateViewController(withIdentifier: "SearchContentViewController") as? SearchContentViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: Configure Category CollectionView
extension DiscoverNotesViewController {
    
    private func configureCategoryCollectionView() {
        
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        view.addSubview(categoryCollectionView)
        
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        categoryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        categoryCollectionView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/10).isActive = true
        categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
}

// MARK: Configure Notes CollecitonView
extension DiscoverNotesViewController {
    
    private func configureNotesCollectionView() {
        notesCollectionView.dataSource = self
        notesCollectionView.delegate = self
        
        view.addSubview(notesCollectionView)
        
        notesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        notesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        notesCollectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor).isActive = true
        notesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        notesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
}

// MARK: CollectionView DataSource
extension DiscoverNotesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return category.count
        } else {
            return filterNotes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let categoryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath)
            guard let cell = categoryCollectionViewCell as? CategoryCollectionViewCell else {return categoryCollectionViewCell}
            cell.categoryLabel.text = category[indexPath.item]
            if selectedCategoryIndex == indexPath.item {
                cell.categoryLabel.textColor = .black
            } else {
                cell.categoryLabel.textColor = .systemGray2
            }
            cell.isMultipleTouchEnabled = false
            return cell
        } else {
            let notesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCollectionViewCell", for: indexPath)
            guard let cell = notesCollectionViewCell as? NotesCollectionViewCell else {return notesCollectionViewCell}
            let url = URL(string: filterNotes[indexPath.item].noteCover)
            cell.coverImage.kf.indicatorType = .activity
            cell.coverImage.kf.setImage(with: url)
            cell.titleLabel.text = filterNotes[indexPath.item].noteTitle
            
            // querying users' name & avatar
            for user in users where user.userId == filterNotes[indexPath.item].authorId {
                cell.authorNameLabel.text = user.userName
                let url = URL(string: user.userAvatar)
                cell.userAvatarImage.kf.indicatorType = .activity
                cell.userAvatarImage.kf.setImage(with: url)
            }
            return cell
        }
    }
}

// MARK: CollectionView Delegate
extension DiscoverNotesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else {return}
            selectedCategoryIndex = indexPath.item
            collectionView.reloadData()
            
            if cell.categoryLabel.text != "所有筆記" {
                filterNotes = notes.filter { $0.noteCategory == cell.categoryLabel.text }
            } else {
                filterNotes = notes
            }
            notesCollectionView.reloadData()
            
        } else {
            let notesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCollectionViewCell", for: indexPath)
            guard let cell = notesCollectionViewCell as? NotesCollectionViewCell else {return}
        }
    }
}


// MARK: CollectionView FlowLayout
extension DiscoverNotesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            return CGSize(width: 100, height: 30)
        } else {
            let maxWidth = UIScreen.main.bounds.width
            let numberOfItemsPerRow = CGFloat(2)
            let interItemSpacing = CGFloat(0)
            let itemWidth = (maxWidth - interItemSpacing) / numberOfItemsPerRow
            let itemHeight = itemWidth * 1.8
            return CGSize(width: itemWidth, height: itemHeight)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            if collectionView == categoryCollectionView {
                return 0
            } else {
                return 0
            }
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == categoryCollectionView {
            return 0
        } else {
            return 0
        }
    }
}
