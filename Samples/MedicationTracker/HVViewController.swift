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
                print("show med list")
                self.showMedicationList()
            }
        }
    }
    
    func showMedicationList(){
        let medListController = MedicationListViewController.init(nibName: "MedicationListViewController", bundle: nil)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(medListController, animated: true)
            print("pushed controller")
        }

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
