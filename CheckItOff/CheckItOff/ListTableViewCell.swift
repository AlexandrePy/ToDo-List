//
//  ListTableViewCell.swift
//  CheckItOff
//
//  Created by Alexandre Proy on 11/02/17.
//  Copyright © 2017 AlexandrePy. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
