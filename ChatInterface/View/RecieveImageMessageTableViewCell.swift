//
//  RecieveImageMessageTableViewCell.swift
//  ChatInterface
//
//  Created by EthanLin on 2018/4/16.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import UIKit

class RecieveImageMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mateAvatarImageView: UIImageView!
    @IBOutlet weak var labelOutsideView: UIView!
    @IBOutlet weak var messageImage: UIImageView!
    
    func updateUI(receiveImageMessage:Message){
        self.mateAvatarImageView.image = UIImage(named: receiveImageMessage.speaker)
        self.mateAvatarImageView.layer.masksToBounds = true
        self.mateAvatarImageView.layer.cornerRadius = self.mateAvatarImageView.frame.width / 2

        
        let mateMessageImage = UIImage(named: receiveImageMessage.messageImage!)
        let size = CGSize(width: 160, height: (mateMessageImage?.size.height)! * 160 / (mateMessageImage?.size.width)!)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        mateMessageImage?.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let modifiedImage = UIImageJPEGRepresentation(resizeImage!, 0.8) else {return}
        self.messageImage.image = UIImage(data: modifiedImage)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        labelOutsideView.layer.masksToBounds = true
        labelOutsideView.layer.cornerRadius = 5
        labelOutsideView.backgroundColor = .groupTableViewBackground
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
