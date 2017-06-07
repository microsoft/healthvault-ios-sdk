//
//  MedicationListViewController.swift
//  MedicationTracker
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

class MedicationListViewController: UITableViewController
{
    // MARK: Properties

    var meds: MHVThingCollection?
    var builder = MedicationBuilder.init()
    var searcher = MedicationVocabSearcher.init()
    
    // MARK: - Business Logic
    func getMedicationsFromHV(completion: @escaping(MHVThingCollection?) -> Void)
    {
        let filter = MHVThingFilter.init(typeID: MHVMedication.typeID())
        filter!.xpath = "/thing/data-xml/medication[not(date-discontinued)]"
        let query = MHVThingQuery.init(filter: filter)
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: HVFeaturesConfiguration.configuration())
        connection.thingClient()?.getThingsWith(query!, record: connection.personInfo!.selectedRecordID, completion:
            {
                (meds: MHVThingCollection?, error: Error?) in
                print("Medications count ", meds?.count() ?? -1)
                completion(meds)
            })
    }
    
    // Temp function for testing out the ability to add a medication
    func addMed(sender: UIBarButtonItem)
    {
        let addMedController = AddMedicationViewController.init(nibName: "AddMedicationViewController", bundle: nil,
                                                                builder: builder, searcher: searcher)
        self.navigationController?.pushViewController(addMedController, animated: true)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add,
                                                                 target: self, action: #selector(addMed(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        getMedicationsFromHV
            {
                (medications) in
                DispatchQueue.main.async
                    {
                        self.meds = medications
                        self.tableView.reloadData()
                    }
            }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.meds != nil
        {
            return Int(self.meds!.count())
        }
        else
        {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MedTrackerCell")
        let medication = meds?[UInt(indexPath.row)].medication()
        
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "MedTrackerCell")
        }

        cell?.textLabel?.text = medication?.name.text
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let editMedController = EditMedicationViewController.init(nibName: "EditMedicationViewController", bundle: nil,
                                                                  medication: meds![UInt(indexPath.row)],
                                                                  builder: builder, searcher: searcher)
        self.navigationController?.pushViewController(editMedController, animated: true)
    }
}
