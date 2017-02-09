//
//  TaskTableViewCell.swift
//  CheckItOff
//
//  Created by Alexandre Proy on 07/02/17.
//  Copyright © 2017 AlexandrePy. All rights reserved.
//

import UIKit

protocol CheckButtonPressedDelegate {
    func userDidTapCheckButton(_ sender: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    var tableView: UITableView!
    var delegate: CheckButtonPressedDelegate? = nil

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tappedOnCheckButton(_ sender: UIButton) {
        if delegate != nil {
            delegate?.userDidTapCheckButton(self)
        }
    }
}
