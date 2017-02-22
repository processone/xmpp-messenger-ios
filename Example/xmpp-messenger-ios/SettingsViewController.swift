//
//  SettingsViewController.swift
//  OneChat
//
//  Created by Paul on 19/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import UIKit
import XMPPFramework

class SettingsViewController: UIViewController {
  
  @IBOutlet var usernameTextField: UITextField!
  @IBOutlet var passwordTextField: UITextField!
	@IBOutlet var validateButton: UIButton!
  
  // Mark: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.DismissKeyboard))
    view.addGestureRecognizer(tap)
	
	if OneChat.sharedInstance.isConnected() {
		usernameTextField.isHidden = true
		passwordTextField.isHidden = true
		validateButton.setTitle("Disconnect", for: UIControlState())
	} else {
		if UserDefaults.standard.string(forKey: kXMPP.myJID) != "kXMPPmyJID" {
			usernameTextField.text = UserDefaults.standard.string(forKey: kXMPP.myJID)
			passwordTextField.text = UserDefaults.standard.string(forKey: kXMPP.myPassword)
		}
	}
  }
  
  // Mark: Private Methods
  
  func DismissKeyboard() {
    if usernameTextField.isFirstResponder {
      usernameTextField.resignFirstResponder()
    } else if passwordTextField.isFirstResponder {
      passwordTextField.resignFirstResponder()
    }
  }
  
  // Mark: IBAction
  
  @IBAction func validate(_ sender: AnyObject) {
	if OneChat.sharedInstance.isConnected() {
		OneChat.sharedInstance.disconnect()
		usernameTextField.isHidden = false
		passwordTextField.isHidden = false
		validateButton.setTitle("Validate", for: UIControlState())
	} else {
		OneChat.sharedInstance.connect(username: self.usernameTextField.text!, password: self.passwordTextField.text!) { (stream, error) -> Void in
			if let _ = error {
				let alertController = UIAlertController(title: "Sorry", message: "An error occured: \(error)", preferredStyle: UIAlertControllerStyle.alert)
				alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
					//do something
				}))
				self.present(alertController, animated: true, completion: nil)
			} else {
				self.dismiss(animated: true, completion: nil)
			}
		}
	}
  }
  
  @IBAction func close(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
  }
  
  // Mark: UITextField Delegates
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if passwordTextField.isFirstResponder {
      textField.resignFirstResponder()
      validate(self)
    } else {
      textField.resignFirstResponder()
    }
    
    return true
  }
  
  // Mark: Memory Management
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
