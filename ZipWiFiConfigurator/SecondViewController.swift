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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.securityTypePicker.dataSource = self;
        self.securityTypePicker.delegate = self;
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
}
			
