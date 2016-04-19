//
//  ImageViewController.swift
//  ImageViewController
//
//  Created by luojie on 16/4/18.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    private struct Constants {
        static let CacheImagesCount = 1
    }
    
    // MARK: - Public
    
    var imageURLs = [NSURL]()
    var currentIndex: Int?
    
    // MARK: - Private

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    private var imageScrollViews = [ImageScrollView]()
    
    private var _currentIndex: Int! {
        didSet {
            titleLabel.text = "\(_currentIndex + 1) / \(imageURLs.count)"
            lazilyGetImages()
            resetImageScrollViewAtIndex(oldValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadImageViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateFrames()
    }
    
    private func reloadData() {
        reloadImageViews()
        updateFrames()
    }
    
    private func reloadImageViews() {
        scrollView.subviews.removeFromSuperview()
        imageScrollViews.removeAll(keepCapacity: true)
        for imageURL in imageURLs {
            let imageScrollView = viewFromNibWithType(ImageScrollView)!
            imageScrollView.imageURL = imageURL
            scrollView.addSubview(imageScrollView)
            imageScrollViews.append(imageScrollView)
        }
        _currentIndex = currentIndex ?? 0
        currentIndex = nil
    }
    
    private func updateFrames() {
        let size = CGSize(width: CGFloat(imageURLs.count) * scrollView.bounds.width, height: scrollView.bounds.height)
        scrollView.contentSize = size
        for (index, imageScrollView) in scrollView.subviews.enumerate() {
            let origin = CGPoint(x: scrollView.bounds.width * CGFloat(index), y: 0)
            imageScrollView.frame = CGRect(origin: origin, size: scrollView.bounds.size)
        }
        let point = CGPoint(x: CGFloat(_currentIndex) * scrollView.bounds.width, y: 0)
        scrollView.setContentOffset(point, animated: false)
    }
    
    private func resetImageScrollViewAtIndex(index: Int!) {
        guard let index = index,
            scrollView = imageScrollViews.elementAtIndex(index)?.scrollView
            else { return }
        scrollView.zoomScale = scrollView.minimumZoomScale
    }
    
    private func lazilyGetImages() {
        let minIndex = _currentIndex - ImageViewController.Constants.CacheImagesCount
        let maxIndex = _currentIndex + ImageViewController.Constants.CacheImagesCount
        for index in minIndex...maxIndex {
            imageScrollViews.elementAtIndex(index)?.getImageIfNeeded()
        }
    }
    
    
    @IBAction func dismiss(sender: UIButton) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UIScrollViewDelegate

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print(#function)
        _currentIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffsetX = CGFloat(_currentIndex) * scrollView.bounds.width
        scrollView.pagingEnabled = !scrollView.contentOffset.x.isAround(currentOffsetX)
    }
    
    // MARK: - Update UI

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension CGFloat {
    func isAround(y: CGFloat) -> Bool {
        return y - 10 < self && self < y + 10
    }
}

