//
//  SecondViewController.swift
//  ZipWiFiConfigurator
//
//  Created by Ferhat Hajdarpasic on 8/06/2016.
//  Copyright © 2016 Ferhat Hajdarpasic. All rights reserved.
//

import UIKit

class ConfigWiFiViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var pickerDataSource = ["Open", "WPA/WPA2", "WEP"];
    
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
        let hostname = defaults.stringForKey("hostname_preference")
        let port = defaults.integerForKey("port_preference")
        let client:TCPClient = TCPClient(addr: hostname!, port: port)
        
        var (success, errmsg) = client.connect(timeout: 10000)
        if(success) {
            var (success, errmsg) = client.send(data:command.getBytes())
        } else {
            
        }
        client.close()
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
        self.configureWiFIButton.enabled = checkEnabledConfiguration()
        self.proxyStackView.hidden = true
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
}

