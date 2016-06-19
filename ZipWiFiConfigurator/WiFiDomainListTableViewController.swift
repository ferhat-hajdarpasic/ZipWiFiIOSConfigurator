//
//  WiFiDomainListTableViewController.swift
//  ZipWiFiConfigurator
//
//  Created by Ferhat Hajdarpasic on 16/06/2016.
//  Copyright © 2016 Ferhat Hajdarpasic. All rights reserved.
//

import UIKit
import NetworkExtension

class WiFiDomainListTableViewController: UITableViewController {

    //Mark properties
    var wiFiDomains = [WiFiDomain]()
    let cellidentifier = "WiFiDomainTableViewCell"
    
    func loadSampleWiFiDomains() {
        let domain1 = WiFiDomain(ssid: "BigPond223456", connectionStatus: "CONNECTED")
        let domain2 = WiFiDomain(ssid: "ZIP-223456", connectionStatus: "CONNECTED")
        let domain3 = WiFiDomain(ssid: "AnotherBigPond", connectionStatus: "DISCONNECTED")
        
        wiFiDomains += [domain1, domain2, domain3]

        //UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        let networkInterfaces = NEHotspotHelper.supportedNetworkInterfaces()
        
        let myQueue: dispatch_queue_t = dispatch_queue_create("com.myApp.com", DISPATCH_QUEUE_SERIAL)
        
        let boolResp = NEHotspotHelper.registerWithOptions(["Hotspot": kNEHotspotHelperOptionDisplayName], queue: myQueue) { (cmd) in
            
            if let list = cmd.networkList where ((cmd.commandType == .Evaluate)  || (cmd.commandType == .FilterScanList)) {
                var networks = [NEHotspotNetwork]()
                for network in list {
                    networks.append(network)
                }
                let response = cmd.createResponse(.Success)
                response.setNetworkList(networks)
                response.deliver()
            }
        }
        var networks = [NEHotspotNetwork]()
        for network in networks {
            if network.SSID.hasPrefix("BTVNET") {
                network.setPassword("12345678")
                network.setConfidence(.High)
                networks.append(network)
            }  
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSampleWiFiDomains()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wiFiDomains.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellidentifier, forIndexPath: indexPath) as! WiFiDomainTableViewCell
        let wiFiDomain = wiFiDomains[indexPath.row]
        
        cell.domainNameLabel.text = wiFiDomain.ssid
        cell.connectionStatusLabel.text = wiFiDomain.connectionStatus

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
