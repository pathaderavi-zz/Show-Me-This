//
//  CustomCell.swift
//  Show Me This
//
//  Created by Ravikiran Pathade on 6/20/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var customCellImageView: UIImageView!
    @IBOutlet weak var textDetails: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
