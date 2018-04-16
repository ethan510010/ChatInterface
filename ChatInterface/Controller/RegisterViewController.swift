//
//  RegisterViewController.swift
//  ChatInterface
//
//  Created by EthanLin on 2018/4/16.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import UIKit
import Firebase


class RegisterViewController: UIViewController {
    
    @IBOutlet weak var userAccountDataView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    func showAlertController(message:String){
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "確定", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func emailSignIn(_ sender: UIButton) {
        //登入功能
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        if email != "" && password != ""{
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil{
                    self.showAlertController(message: error!.localizedDescription)
                    return
                }
                let alert = UIAlertController(title: "提示", message: "登入成功", preferredStyle: .alert)
                let action = UIAlertAction(title: "確定", style: .default, handler: { (action) in
                    self.performSegue(withIdentifier: "goToFriendTable", sender: nil)
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
            }
        }else{
            self.showAlertController(message: "請確定帳號及密碼皆已正確填入")
        }
    }
    
    
    @IBAction func forgetPassword(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        if email == ""{
            self.showAlertController(message: "請輸入郵件地址")
            return
        }
        //寄送重設密碼郵件
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil{
                self.showAlertController(message: error!.localizedDescription)
                return
            }
            self.showAlertController(message: "重設密碼郵件已寄到您的信箱")
        }
    }
    
    @IBAction func createUser(_ sender: UIButton) {
        //創建email登入帳號
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        
        if email != "" && password != ""{
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if error != nil{
                    self.showAlertController(message: "註冊失敗，請稍後再試")
                    return
                }
                self.showAlertController(message: "註冊成功")
            }
        }else{
            self.showAlertController(message: "請確定帳號及密碼皆已正確填入")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        userAccountDataView.layer.masksToBounds = true
        userAccountDataView.layer.cornerRadius = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
