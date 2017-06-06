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
        print("in loader for medlistview")
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addMed(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear called")
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
        let medication = meds?[UInt(indexPath.row)]
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "MedTrackerCell")
        }

        cell?.textLabel?.text = medication?.medication().name.text
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editMedController = EditMedicationViewController.init(nibName: "EditMedicationViewController", bundle: nil,
                                                                  medication: meds![UInt(indexPath.row)], builder: builder, searcher: searcher)
        self.navigationController?.pushViewController(editMedController, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
     */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
