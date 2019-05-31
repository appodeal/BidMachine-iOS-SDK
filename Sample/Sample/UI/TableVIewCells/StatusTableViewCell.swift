//
//  LabelAndImageTableViewCell.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 12/6/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit

class StatusTableViewCell: UITableViewCell {
    var entity: StatusEntity? {
        didSet {
            update()
        }
    }
    
    var binding:((StatusEntity)->())?
    
    @IBOutlet weak var statusOptionLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        update()
    }
    
    private func update() {
        statusOptionLabel.text = entity?.info
        statusImageView.image = entity?.value ?? false ? UIImage(named: "Correct") : UIImage(named: "Incorrect")
    }
}

extension StatusTableViewCell: NibProvider {
    static var nib: UINib {
        return UINib(nibName: "StatusTableViewCell", bundle: Bundle(for: self))
    }
    
    static var reuseIdentifier: String {
        return "StatusTableViewCellReuseID"
    }
}

extension StatusTableViewCell: BindingView {
    typealias T = StatusEntity
}
