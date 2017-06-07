    //
//  MedicationListViewController.swift
//  MedicationTracker
//
//  Created by Kayla Davis on 5/25/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import UIKit

class MedicationListViewController: UITableViewController {
    var meds: MHVThingCollection?
    var builder = MedicationBuilder.init()
    var searcher = MedicationVocabSearcher.init()
    
    // MARK: - Business Logic
    func getMedicationsFromHV(completion: @escaping(MHVThingCollection?) -> Void){
        let query = MHVThingQuery.init(typeID: MHVMedication.typeID())
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: HVFeaturesConfiguration.configuration())
        connection.thingClient()?.getThingsWith(query!, record: connection.personInfo!.selectedRecordID, completion: { (meds: MHVThingCollection?, error: Error?) in
            print("Medications count ", meds?.count() ?? -1)
            completion(meds)
        })
    }
    
    // Temp function for testing out the ability to add a medication
    func addMed(sender: UIBarButtonItem){
        let addMedController = AddMedicationViewController.init(nibName: "AddMedicationViewController", bundle: nil, builder: builder, searcher: searcher)
        self.navigationController?.pushViewController(addMedController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addMed(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMedicationsFromHV { (medications) in
            DispatchQueue.main.async {
                self.meds = medications
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.meds != nil {
            return Int(self.meds!.count())
        } else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MedTrackerCell")
        let medication = meds?[UInt(indexPath.row)].medication()
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "MedTrackerCell")
        }

        cell?.textLabel?.text = medication?.name.text
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editMedController = EditMedicationViewController.init(nibName: "EditMedicationViewController", bundle: nil,
                                                                  medication: meds![UInt(indexPath.row)], builder: builder, searcher: searcher)
        self.navigationController?.pushViewController(editMedController, animated: true)
    }
}
