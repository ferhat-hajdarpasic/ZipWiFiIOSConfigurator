//
//  SecondViewController.swift
//  ZipWiFiConfigurator
//
//  Created by Ferhat Hajdarpasic on 8/06/2016.
//  Copyright © 2016 Ferhat Hajdarpasic. All rights reserved.
//

import UIKit

class ConfigWiFiViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    var pickerDataSource = ["Open", "WPA/WPA2", "WEP"];
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var proxyStackView: UIStackView!
    @IBOutlet weak var securityTypePicker: UIPickerView!
    @IBOutlet weak var showPasswordSwitch: UISwitch!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var domainNameTextField: UITextField!
    @IBOutlet weak var configureProxySwitch: UISwitch!
    @IBOutlet weak var proxyHostTextField: UITextField!
    @IBOutlet weak var proxyPortTextField: UITextField!
    @IBOutlet weak var proxyUserNameTextField: UITextField!
    @IBOutlet weak var proxyPasswordTextField: UITextField!
    @IBOutlet weak var configureWiFIButton: UIButton!
    
    var activeField:UITextField!
    
    @IBAction func configureProxySwitchChanged(sender: UISwitch) {
        self.proxyStackView.hidden = !sender.on
        self.proxyHostTextField.enabled = sender.on
        self.proxyPortTextField.enabled = sender.on
        self.proxyUserNameTextField.enabled = sender.on
        self.proxyPasswordTextField.enabled = sender.on
    }
    
    @IBAction func passwordEditingChanged(sender: AnyObject) {
        self.configureWiFIButton.enabled = self.checkEnabledConfiguration()
    }
    @IBAction func domainNameEditingChanged(sender: AnyObject) {
        self.configureWiFIButton.enabled = self.checkEnabledConfiguration()
    }
    @IBAction func passwordEditingEnded(sender: AnyObject) {
        self.configureWiFIButton.enabled = self.checkEnabledConfiguration()
    }
    @IBAction func domainNameEditingEnded(sender: AnyObject) {
        self.configureWiFIButton.enabled = self.checkEnabledConfiguration()
    }
    
    
    @IBAction func configureWiFIButtonClicked(sender: AnyObject) {
        let selectedSecurityTypeIndex = self.securityTypePicker.selectedRowInComponent(0);
        
        let command = ConfigureWiFiCommand(
            SecurityType: selectedSecurityTypeIndex,
            Domain: self.domainNameTextField.text!,
            Password: self.passwordTextField.text!,
            proxyHostname: self.proxyHostTextField.text!,
            proxyPort: self.proxyPortTextField.text!,
            proxyUsername: self.proxyUserNameTextField.text!,
            proxyPassword: self.proxyPasswordTextField.text!)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var hostname = defaults.stringForKey("hostname_preference")
        if(hostname == nil) {
            hostname = "192.168.1.1"
        }
        var port = defaults.integerForKey("port_preference")
        if(port == 0) {
            port = 9001
        }
        
        self.activityIndicatorView.hidden = false
        self.activityIndicatorView.startAnimating()
        self.configureWiFIButton.enabled = false
        
        defaults.setValue(self.domainNameTextField.text!, forKey: "wifiDomain_preference")
        defaults.setValue(self.passwordTextField.text!, forKey: "configPassword_preference")
        defaults.setValue(self.proxyHostTextField.text!, forKey: "proxyHostname_preference")
        defaults.setValue(self.proxyPortTextField.text!, forKey: "proxyPort_preference")
        defaults.setValue(self.proxyUserNameTextField.text!, forKey: "proxyUsername_preference")
        defaults.setValue(self.proxyPasswordTextField.text!, forKey: "proxyPassword_preference")
        
        var backgroundQueue = NSOperationQueue()
        backgroundQueue.addOperationWithBlock() {
            var message = "Successfully Configured"
            let client:TCPClient = TCPClient(addr: hostname!, port: port)
            var (success, errmsg) = client.connect(timeout: 10)
            if(success) {
                var (success, errmsg) = client.send(data:command.getBytes())
                if(success) {
                    client.read(2, timeout: 2)
                } else {
                    message = errmsg
                }
            } else {
                message = errmsg
            }
            defer {
                client.close()
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                defer {
                    self.activityIndicatorView.hidden = true
                    self.activityIndicatorView.stopAnimating()
                }
                
                NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(self.delayedAction), userInfo: nil, repeats: false)
                
                defer {
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.configureWiFIButton.enabled = true
                }
            }
        }
    }
    
    func delayedAction() {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func proxyPasswordSwitchChanged(sender: UISwitch) {
        if(sender.on) {
            proxyPasswordTextField.secureTextEntry = false
        } else {
            proxyPasswordTextField.secureTextEntry = true
        }
    }
    
    @IBOutlet weak var showProxyPasswordSwitch: UISwitch!
    @IBAction func showPasswordSwitchChanged(sender: UISwitch) {
        if(sender.on) {
            passwordTextField.secureTextEntry = false
        } else {
            passwordTextField.secureTextEntry = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.securityTypePicker.dataSource = self;
        self.securityTypePicker.delegate = self;
        self.securityTypePicker.layer.cornerRadius = 5.0
        self.securityTypePicker.clipsToBounds = true
        self.proxyStackView.hidden = true
        self.activityIndicatorView.hidden = true
        
        let defaults = NSUserDefaults.standardUserDefaults()
        self.domainNameTextField.text = defaults.stringForKey("wifiDomain_preference")
        self.passwordTextField.text = defaults.stringForKey("configPassword_preference")
        self.proxyHostTextField.text = defaults.stringForKey("proxyHostname_preference")
        self.proxyPortTextField.text = defaults.stringForKey("proxyPort_preference")
        self.proxyUserNameTextField.text = defaults.stringForKey("proxyUsername_preference")
        self.proxyPasswordTextField.text = defaults.stringForKey("proxyPassword_preference")
        
        self.passwordTextField.delegate = self
        self.domainNameTextField.delegate = self
        self.proxyHostTextField.delegate = self
        self.proxyPortTextField.delegate = self
        self.proxyUserNameTextField.delegate = self
        self.proxyPasswordTextField.delegate = self
        
        self.registerForKeyboardNotifications()
        
        self.configureWiFIButton.enabled = checkEnabledConfiguration()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    private func checkEnabledConfiguration() ->Bool {
        let selectedSecurityTypeIndex = self.securityTypePicker.selectedRowInComponent(0);
        let enableButton:Bool =
            (selectedSecurityTypeIndex >= 0) && (self.domainNameTextField.text?.isEmpty == false) && (self.passwordTextField.text?.isEmpty == false)
        return enableButton
    }
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConfigWiFiViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConfigWiFiViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.scrollEnabled = true
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeFieldPresent = activeField
        {
            if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
        
        
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.scrollEnabled = false
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField!)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField!)
    {
        activeField = nil
    }
    
}

