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
        self.mateAvatarImageView.layer.masksToBounds = true
        self.mateAvatarImageView.layer.cornerRadius = self.mateAvatarImageView.frame.width / 2
        guard let imageURL = URL(string: receiveImageMessage.imageURL) else { return }
        
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if error != nil{
                print(error?.localizedDescription)
                return
            }
            guard let imageData = data, let downloadedImage = UIImage(data: imageData) else {return}
            print("接收圖片資料:\(imageData)")
            let adjustedImage = downloadedImage.scale(newWidth: 160)
            DispatchQueue.main.async {
                self.messageImage.image = adjustedImage
            }
        }
        task.resume()
//        DispatchQueue.main.async {
//            
//            
//            do {
//                let recieveImageData = try Data(contentsOf: imageURL)
//                let receiveImage = UIImage(data: recieveImageData)
//                //調整該照片比例
//                let adjustedImage = receiveImage?.scale(newWidth: 160)
//                self.messageImage.image = #imageLiteral(resourceName: "s1")
//                
////                self.layoutIfNeeded()
////                self.layoutSubviews()
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
        
        
        
////        let size = CGSize(width: 160, height: (mateMessageImage?.size.height)! * 160 / (mateMessageImage?.size.width)!)
////        UIGraphicsBeginImageContextWithOptions(size, false, 0)
////        mateMessageImage?.draw(in: CGRect(origin: CGPoint.zero, size: size))
//        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        guard let modifiedImage = UIImageJPEGRepresentation(resizeImage!, 0.8) else {return}
//        self.messageImage.image = UIImage(data: modifiedImage)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        messageImage.contentMode = .scaleAspectFill
        labelOutsideView.layer.masksToBounds = true
        labelOutsideView.layer.cornerRadius = 5
        labelOutsideView.backgroundColor = .groupTableViewBackground
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
