//
//  WiFiDomainTableViewCell.swift
//  ZipWiFiConfigurator
//
//  Created by Ferhat Hajdarpasic on 16/06/2016.
//  Copyright © 2016 Ferhat Hajdarpasic. All rights reserved.
//

import UIKit

class WiFiDomainTableViewCell: UITableViewCell {

    //Mark properties
    
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var domainNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
