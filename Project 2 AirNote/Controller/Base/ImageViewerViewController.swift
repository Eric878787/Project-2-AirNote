//
//  ImageViewerViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/5.
//

import UIKit
import Kingfisher

class ImageViewerViewController: UIViewController {
    
    private var scView = UIScrollView()
    private var pageControl = UIPageControl()
    let thePadding:CGFloat = 0
    var theOffset:CGFloat = 0
    var currentPage = 0
    
    // Data Source
    var images: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        scView.delegate = self
        view.backgroundColor = .white
        layoutScrollView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let offset = CGPoint(x: (scView.frame.width) * CGFloat(currentPage), y: 0)
        scView.setContentOffset(offset, animated: false)
        
    }
    
}

extension ImageViewerViewController: UIScrollViewDelegate {
    
    private func layoutScrollView() {
        
        scView.translatesAutoresizingMaskIntoConstraints = false
        scView.isPagingEnabled = true
        view.addSubview(scView)
        
        NSLayoutConstraint.activate([
            scView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            scView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor),
            
        ])
        
        scView.backgroundColor = UIColor.white
        scView.translatesAutoresizingMaskIntoConstraints = false
        
        layoutImageViews()
        
        scView.contentSize = CGSize(width: theOffset, height: scView.frame.height)
    }
    
    private func layoutImageViews() {
        
        for image in images {
            let url = URL(string: image)
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url)
            scView.addSubview(imageView)
            imageView.frame = CGRect(x: theOffset,
                                     y: CGFloat(thePadding),
                                     width: (view.safeAreaLayoutGuide.layoutFrame.size.width),
                                     height: (view.safeAreaLayoutGuide.layoutFrame.size.height))
            theOffset = (theOffset + imageView.frame.size.width)
        }
        
        configurePageControl()
        
    }
    
    func configurePageControl() {
        pageControl.numberOfPages = images.count
        pageControl.currentPage = currentPage
        pageControl.addTarget(self, action: #selector(pageChanged), for: .valueChanged)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        pageControl.currentPage = Int(page)
    }
    
    @objc func pageChanged() {
        let offset = CGPoint(x: (scView.frame.width) * CGFloat(pageControl.currentPage), y: 0)
        scView.setContentOffset(offset, animated: true)
    }
    
}
