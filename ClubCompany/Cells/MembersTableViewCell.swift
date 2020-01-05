//
//  MembersTableViewCell.swift
//  ClubCompany
//
//  Created by Senthil Kumar J on 05/01/20.
//  Copyright © 2020 Senthil Kumar J. All rights reserved.
//

import UIKit

class MembersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var favoriteImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
