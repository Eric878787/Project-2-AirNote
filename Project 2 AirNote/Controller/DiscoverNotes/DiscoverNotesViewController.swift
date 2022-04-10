//
//  Discover Notes View Controller.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/9.
//

import UIKit

class DiscoverNotesViewController: UIViewController {
    
    // MARK: CollectionView Properties
    @IBOutlet weak var discoverNotesCollectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        navigationItem.title = "探索筆記"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Config Search Bar
        configSearchBar()
        
        // Set Up CollectionView
        setUpCollectionView()
        createDataSource()
        createSnapshot()
    }
    
    private func configSearchBar () {
        let searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "輸入關鍵字"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
}

extension DiscoverNotesViewController {
    
    private func setUpCollectionView () {
        let discoverNotesItemNib = UINib(nibName: "HotNotesCollectionViewCell", bundle: nil)
        self.discoverNotesCollectionView.register( discoverNotesItemNib, forCellWithReuseIdentifier: "HotNotesCollectionViewCell")
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: discoverNotesCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = self.discoverNotesCollectionView.dequeueReusableCell(withReuseIdentifier: "HotNotesCollectionViewCell", for: indexPath) as? HotNotesCollectionViewCell ?? UICollectionViewCell()
            return cell
        })
    }
    
    private func createSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        snapshot.appendItems(Array(0...99))
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}
