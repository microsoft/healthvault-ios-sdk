//
//  ViewController.swift
//  MedicationTracker
//
//  Created by Kayla Davis on 5/24/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import UIKit

class HVViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        startApp()
    }
    
    func startApp(){
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: HVFeaturesConfiguration.configuration())
        connection.authenticate(with: self) { (error: Error?) in
            if error != nil {
                print("Could not auth")
            } else{
                self.showMedicationList()
            }
        }
    }
    
    func showMedicationList(){
        let medListController = MedicationListViewController.init(nibName: "MedicationListViewController", bundle: nil)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(medListController, animated: true)
        }

    }

}
