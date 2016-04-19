//
//  ViewController.swift
//  ImageViewController
//
//  Created by luojie on 16/4/18.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

class ViewController: ImageViewController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageURLs = [photo1, photo2]
        currentIndex = 0
    }
}

