//
//  HVFeaturesConfiguration.swift
//  MedicationTracker
//
//  Created by Kayla Davis on 5/24/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import UIKit

class HVFeaturesConfiguration: NSObject {
    
    class func configuration() -> MHVConfiguration {
        let config = MHVConfiguration.init()
    
        config.masterApplicationId = UUID.init(uuidString: "708995a6-4fba-42de-97a8-5feb54e944e8")
        config.defaultHealthVaultUrl = URL.init(string: "https://platform.healthvault-ppe.com/platform")
        config.defaultShellUrl = URL.init(string: "https://account.healthvault-ppe.com")
    
        return config
    }
}
