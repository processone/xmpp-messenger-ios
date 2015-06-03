//
//  SettingsViewController.swift
//  OneChat
//
//  Created by Paul on 19/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  
  @IBOutlet var usernameTextField: UITextField!
  @IBOutlet var passwordTextField: UITextField!
  
  // Mark: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tap = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
    view.addGestureRecognizer(tap)
    
    usernameTextField.text = NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myJID)
    passwordTextField.text = NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myPassword)
  }
  
  // Mark: Private Methods
  
  func setField(field: UITextField, forKey key: String) {
    if let text = field.text {
      NSUserDefaults.standardUserDefaults().setObject(text, forKey: key)
    } else {
      NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    }
  }
  
  func DismissKeyboard() {
    if usernameTextField.isFirstResponder() {
      usernameTextField.resignFirstResponder()
    } else if passwordTextField.isFirstResponder() {
      passwordTextField.resignFirstResponder()
    }
  }
  
  // Mark: IBAction
  
  @IBAction func validate(sender: AnyObject) {
    setField(usernameTextField, forKey: kXMPP.myJID)
    setField(passwordTextField, forKey: kXMPP.myPassword)
    
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func close(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // Mark: UITextField Delegates
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if passwordTextField.isFirstResponder() {
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
