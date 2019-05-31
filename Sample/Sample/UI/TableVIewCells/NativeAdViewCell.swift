//
//  NativeAdViewCell.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 11/30/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine

class NativeAdViewCell: UITableViewCell, BDMNativeAdView {
    
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var descriptionLab: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var callToActionLab: UILabel!
    
    func titleLabel() -> UILabel {
        return titleLab
    }
    func descriptionLabel() -> UILabel {
        return descriptionLab
    }
    func iconView() -> UIImageView {
        return icon
    }
    func mediaContainerView() -> UIView {
        return mediaContainer
    }
    func callToActionLabel() -> UILabel {
        return callToActionLab
    }
    
}


extension NativeAdViewCell: NibProvider {
    static var nib: UINib {
        return UINib(nibName: "NativeAdViewCell", bundle: Bundle(for: self))
    }
    
    static var reuseIdentifier: String {
        return "NativeAdViewCellReuseID"
    }
}
