//
//  GifListViewCell.swift
//  GiphyViewer
//
//  Created by Светлана Лобан on 8/12/18.
//  Copyright © 2018 Sviatlana Loban. All rights reserved.
//

import UIKit
import FLAnimatedImage

class GifListViewCell: UICollectionViewCell {
    
    //@IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var animatedImage: FLAnimatedImageView!
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        var frame = attributes.frame
        frame.size.width = layoutAttributes.size.width
        attributes.frame = frame
        return attributes
    }
}
