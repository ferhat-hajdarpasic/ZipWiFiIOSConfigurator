//
//  WiFiDomain.swift
//  ZipWiFiConfigurator
//
//  Created by Ferhat Hajdarpasic on 16/06/2016.
//  Copyright © 2016 Ferhat Hajdarpasic. All rights reserved.
//

import UIKit

class WiFiDomain: NSObject {
    var ssid:String
    var connectionStatus:String
    init(ssid: String, connectionStatus: String) {
        self.ssid = ssid
        self.connectionStatus = connectionStatus
    }
}
