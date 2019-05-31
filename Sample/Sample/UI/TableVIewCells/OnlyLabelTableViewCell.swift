//
//  OnlyLabelTableViewCell.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 12/19/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit

class OnlyLabelTableViewCell: UITableViewCell {
    
    var entity: OnlyLabelEntity? {
        didSet {
            update()
        }
    }
    var binding:((OnlyLabelEntity)->())?
    
    @IBOutlet weak var label: UILabel!
    
    private func update() {
        label.text = entity?.info
    }
}

extension OnlyLabelTableViewCell: NibProvider {
    static var nib: UINib {
        return UINib(nibName: "OnlyLabelTableViewCell", bundle: Bundle(for: self))
    }
    
    static var reuseIdentifier: String {
        return "OnlyLabelTableViewCellReuseID"
    }
}

extension OnlyLabelTableViewCell: BindingView {
    typealias T = OnlyLabelEntity
}
