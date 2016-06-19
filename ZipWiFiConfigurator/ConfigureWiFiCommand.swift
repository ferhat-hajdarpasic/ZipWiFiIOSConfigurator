//
//  ConfigureWiFiCommand.swift
//  ZipWiFiConfigurator
//
//  Created by Ferhat Hajdarpasic on 19/06/2016.
//  Copyright © 2016 Ferhat Hajdarpasic. All rights reserved.
//

import Foundation

extension String
{
    func trim() -> String
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

public class ConfigureWiFiCommand {
    //private static final String TAG = ConfigureWiFiCommand.class.getSimpleName();
    var SecurityType: Int
    var Domain: String
    var Password: String
    var proxyHostname:String
    var proxyPort:String
    var proxyUsername:String
    var proxyPassword:String
    
    init(SecurityType: Int, Domain: String, Password: String, proxyHostname:String, proxyPort:String, proxyUsername:String, proxyPassword:String) {
        self.SecurityType = SecurityType
        self.Domain = Domain
        self.Password = Password
        self.proxyHostname = proxyHostname
        self.proxyPort = proxyPort
        self.proxyUsername = proxyUsername
        self.proxyPassword = proxyPassword
    }
    
    public func getBytes() -> [UInt8]
    {
        var stringPayload = "\(self.SecurityType)\0\(self.Domain.trim())\0\(self.Password.trim())"
        if(!self.proxyHostname.isEmpty) {
            stringPayload += "\0\(self.proxyHostname.trim())\0\(self.proxyPort.trim())"
            if(!self.proxyUsername.isEmpty) {
                stringPayload += "\0\(self.proxyUsername.trim())\0\(self.proxyPassword.trim())"
            }
        }
        
        let payload:[UInt8] = [UInt8](stringPayload.utf8)
        let msgLength = 2 + payload.count
        let msg:[UInt8] = [UInt8(ascii:"h"), UInt8(msgLength) ]
        let result = msg + payload
        return result
    }
}