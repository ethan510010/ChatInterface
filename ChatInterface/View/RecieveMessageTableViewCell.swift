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
    @IBOutlet weak var labelOutsideView: UIView!
    
    
    func updateUI(recieveMessage:Message){
        self.recieveMessageContent.text = recieveMessage.text
//        self.mateAvatar.image = UIImage(named: recieveMessage.speaker)
    }
    
    func makeCircleAvatar(){
        self.mateAvatar.layer.masksToBounds = true
        self.mateAvatar.layer.cornerRadius = self.mateAvatar.frame.width / 2
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.recieveMessageContent.backgroundColor = .groupTableViewBackground
        self.recieveMessageContent.textColor = .black
        self.labelOutsideView.layer.masksToBounds = true
        self.labelOutsideView.layer.cornerRadius = 5
        self.labelOutsideView.backgroundColor = .groupTableViewBackground
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
