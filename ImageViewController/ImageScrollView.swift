//
//  ImageScrollView.swift
//  ImageViewController
//
//  Created by luojie on 16/4/18.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

class ImageScrollView: UIView, UIScrollViewDelegate {
    
    var imageURL: NSURL!
    
    func getImageIfNeeded() {
        guard !imageGetted && imageURL != nil else { return }
        imageGetted = true
        getImage()
    }
    
    private var imageGetted = false

    private func getImage() {
        guard let url = imageURL else { return }
        spinner.startAnimating()
        Queue.UserInitiated.execute {
            let imageData = NSData(contentsOfURL: url)
            Queue.Main.execute { [weak self] in
                if url == self?.imageURL {
                    self?.image = imageData.flatMap(UIImage.init)
                }
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.addSubview(imageView)
        }
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    lazy private var imageView = UIImageView()
    
    private var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView.contentSize = imageView.frame.size
            scrollView.scaleAspectFit()
            spinner.stopAnimating()
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        print(#function)
        scrollView.centerContentView()
    }
    
    @IBAction func autoResize(sender: UITapGestureRecognizer) {
        if scrollView.zoomScale != scrollView.minimumZoomScale {
            return UIView.animateWithDuration(0.3, animations: { self.scrollView.zoomScale = self.scrollView.minimumZoomScale })
        }
        
        let pointInView = sender.locationInView(imageView)
        var newZoomScale = scrollView.zoomScale * 2
        
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
        
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        scrollView.zoomToRect(rectToZoomTo, animated: true)
    }
    
}

extension UIScrollView {
    func scaleAspectFit() {
        let scaleWidth = frame.size.width / contentSize.width
        let scaleHeight = frame.size.height / contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        minimumZoomScale = minScale
        maximumZoomScale = 1.0
        zoomScale = minScale
        print(frame.size.width)
        print(contentSize.width)
        print(minimumZoomScale)
        print(zoomScale)
        centerContentView()
    }
    
    func centerContentView() {
        guard let contentView = subviews.first else { return }
        let boundsSize = bounds.size
        var contentsFrame = contentView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        contentView.frame = contentsFrame
    }
}

