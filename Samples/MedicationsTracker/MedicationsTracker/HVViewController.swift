//
//  ViewController.swift
//  MedicationTracker
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

class HVViewController: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        startApp()
    }
    
    func startApp()
    {
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: HVFeaturesConfiguration.configuration())
        connection.authenticate(with: self)
        {
            (error: Error?) in
            if error != nil
            {
                print("Could not auth")
            }
            else
            {
                self.showMedicationList()
            }
        }
    }
    
    func showMedicationList()
    {
        let medListController = MedicationListViewController.init(nibName: "MedicationListViewController", bundle: nil)
        DispatchQueue.main.async
            {
                self.navigationController?.pushViewController(medListController, animated: true)
            }
    }

}
