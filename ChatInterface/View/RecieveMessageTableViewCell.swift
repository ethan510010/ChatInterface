//
//  RecieveMessageTableViewCell.swift
//  ChatInterface
//
//  Created by EthanLin on 2018/4/14.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import UIKit

class RecieveMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mateAvatar: UIImageView!
    @IBOutlet weak var recieveMessageContent: UILabel!
    
    func updateUI(recieveMessage:Message){
        self.recieveMessageContent.text = recieveMessage.content
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.recieveMessageContent.backgroundColor = .groupTableViewBackground
        self.recieveMessageContent.textColor = .black
        self.recieveMessageContent.layer.masksToBounds = true
        self.recieveMessageContent.layer.cornerRadius = 10
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
