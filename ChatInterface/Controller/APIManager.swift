//
//  APIManager.swift
//  ChatInterface
//
//  Created by EthanLin on 2018/4/28.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import Foundation
import UIKit

class APIManager {
    
    let imageCache = NSCache<NSURL, UIImage>()
    
    static let shared = APIManager()
    
    func downloadImageMessage(of urlString:String, completion: @escaping (UIImage?) -> Void){
        guard let url = URL(string: urlString) else {
            completion(nil)
            return }
        //設定Cache
        //如果cache裡面是有圖片的就從裡面拿圖片
        if let imageFromCache = imageCache.object(forKey: url as NSURL){
            completion(imageFromCache)
        }else{
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                guard let imageData = data, let downloadedImage = UIImage(data: imageData) else {
                    completion(nil)
                    return}
                //把新抓下來的圖片放到cache，並回傳此image
                self.imageCache.setObject(downloadedImage, forKey: url as NSURL)
                completion(downloadedImage)
            }
            task.resume()
        }
    }
}
