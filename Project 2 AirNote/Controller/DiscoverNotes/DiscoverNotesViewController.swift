//
//  Discover Notes View Controller.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/9.
//

import UIKit

class DiscoverNotesViewController: UIViewController {
    
    // MARK: CollecitonView Properties
    var categoryCollecitonView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        var categoryCollecitonView = UICollectionView(
            frame: CGRect.zero,
            collectionViewLayout: layout
        )
        categoryCollecitonView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let nib = UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
        categoryCollecitonView.register(nib, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        categoryCollecitonView.backgroundColor = .clear
        return categoryCollecitonView
    }()
    
    var notesCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        var notesCollectionViewCell = UICollectionView(
            frame: CGRect.zero,
            collectionViewLayout: layout
        )
        notesCollectionViewCell = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let nib = UINib(nibName: "NotesCollectionViewCell", bundle: nil)
        notesCollectionViewCell.register(nib, forCellWithReuseIdentifier: "NotesCollectionViewCell")
        notesCollectionViewCell.backgroundColor = .clear
        return notesCollectionViewCell
    }()
    
    // MARK: Mock Data
    var category: [String] = ["所有筆記", "投資理財", "運動健身", "語言學習", "人際溝通", "廣告行銷", "生活風格", "藝文娛樂"]
    var notes: [String] = ["所有筆記1", "投資理財2", "運動健身3", "語言學習4", "人際溝通5", "廣告行銷6", "生活風格7", "藝文娛樂8","所有筆記2", "投資理財3", "運動健身4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        navigationItem.title = "探索筆記"
        
        // Set Up Category CollectionView
        configureCategoryCollectionView()
        
        // Set Up Notes CollecitonView
        configureNotesCollectionView()
        
    }
    
}

// MARK: Configure Category CollectionView
extension DiscoverNotesViewController {
    
    private func configureCategoryCollectionView() {
        
        categoryCollecitonView.dataSource = self
        categoryCollecitonView.delegate = self
        
        view.addSubview(categoryCollecitonView)
        
        categoryCollecitonView.translatesAutoresizingMaskIntoConstraints = false
        categoryCollecitonView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        categoryCollecitonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        categoryCollecitonView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        categoryCollecitonView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
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
        notesCollectionView.topAnchor.constraint(equalTo: categoryCollecitonView.bottomAnchor).isActive = true
        notesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        notesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
}

// MARK: CollectionView DataSource
extension DiscoverNotesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollecitonView {
            return category.count
        } else {
            return notes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollecitonView {
            let categoryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath)
            guard let cell = categoryCollectionViewCell as? CategoryCollectionViewCell else {return categoryCollectionViewCell}
            cell.categoryLabel.text = category[indexPath.item]
            cell.isMultipleTouchEnabled = false
            return cell
        } else {
            let notesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCollectionViewCell", for: indexPath)
            guard let cell = notesCollectionViewCell as? NotesCollectionViewCell else {return notesCollectionViewCell}
            return cell
        }
    }
}


// MARK: CollectionView Delegate
extension DiscoverNotesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollecitonView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else {return}
            cell.categoryLabel.textColor = .black
            print(indexPath)
        } else {
            let notesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCollectionViewCell", for: indexPath)
            guard let cell = notesCollectionViewCell as? NotesCollectionViewCell else {return}
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollecitonView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else {return}
            cell.categoryLabel.textColor = .systemGray2
        } else {
            let notesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCollectionViewCell", for: indexPath)
            guard let cell = notesCollectionViewCell as? NotesCollectionViewCell else {return}
        }
    }
}


// MARK: CollectionView FlowLayout
extension DiscoverNotesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollecitonView {
            return CGSize(width: 100, height: 30)
        } else {
            let maxWidth = UIScreen.main.bounds.width
            let numberOfItemsPerRow = CGFloat(2)
            let interItemSpacing = CGFloat(5)
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
        if collectionView == categoryCollecitonView {
            return 0
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == categoryCollecitonView {
            return 0
        } else {
            return 0
        }
    }
}
