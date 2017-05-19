//
// MHVRecordListrViewController.swift
// SDKFeatures
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
//

import UIKit

class MHVRecordListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    // The current connection, which has personInfo records
    let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: MHVFeaturesConfiguration.configuration())
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Select Person", comment: "Title to select person to view");
    }
    
    // MARK: UITableViewDelegate and UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let personInfo = self.connection.personInfo
        {
            return Int(personInfo.records.count())
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView .dequeueReusableCell(withIdentifier: "MHVRecordCell")
        if cell == nil
        {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "MHVRecordCell")
        }
        
        if let personInfo = self.connection.personInfo
        {
            if let record = personInfo.records .object(at: UInt(indexPath.row))
            {
                cell?.textLabel?.text = record.displayName;
            }
        }
        
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView .deselectRow(at: indexPath, animated: true)
        
        guard let personInfo = self.connection.personInfo else {
            return
        }

        guard let record = personInfo.records .object(at: UInt(indexPath.row)) else {
            return
        }
        
        personInfo.selectedRecordID = record.id
        
        let typeListController = MHVTypeListViewController.init()
        
        self.navigationController?.pushViewController(typeListController, animated: true)        
    }
}
