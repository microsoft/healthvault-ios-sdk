//
//  AddMedicationViewController.swift
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

class AddMedicationViewController: UIViewController, UITextFieldDelegate
{
    
    //MARK: Properties
    var medicationBuilder: MedicationBuilder
    
    //MARK: UI Properties
    @IBOutlet weak var nameField: AutocompleteTextField!
    @IBOutlet weak var doseAmountField: MedicationTextField!
    @IBOutlet weak var doseUnitField: PickerTextField!
    @IBOutlet weak var medicationErrorLabel: UILabel!
    @IBOutlet weak var doseAmountErrorLabel: UILabel!
    @IBOutlet weak var doseUnitErrorLabel: UILabel!
    
    //Mark: Initializers
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, builder: MedicationBuilder)
    {
        self.medicationBuilder = builder
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.medicationBuilder = MedicationBuilder.init()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set error labels where needed
        nameField.errorLabel = medicationErrorLabel
        doseAmountField.errorLabel = doseAmountErrorLabel
        doseUnitField.errorLabel = doseUnitErrorLabel
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Setup custom field types
        nameField.setup()
        doseUnitField.setup(pickerData: HVUnitTypes.doseUnits)
        
    }
    
    // MARK: UITextField Delegation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        // Highlight cells that are invalid, but ignore returned value
        let text = textField as! MedicationTextField
        _ = text.isValid()
        
        return true
    }
    
    func makeTestPlanAndTask(medbuild: MedicationBuilder, connection: MHVSodaConnectionProtocol){ //temp
        let ap = ActionPlan.init(connection: connection)
        let ataskbulder = ActionPlanTaskBuilder.init()
        let time = MHVTime.init(hour: 11, minute: 30, second: 0)
        
        // build task
        _ = ataskbulder.updateMedicationTask(med: (medicationBuilder.med)!)
        _ = ataskbulder.updateFrequencyMetric(windowType: ActionPlanWindowType.Daily)
        _ = ataskbulder.updateSchedule(schedules: (ataskbulder.actionPlanTask.schedules as? [MHVScheduleV2] ?? [MHVScheduleV2]()),
                                 reminderState: ReminderState.OnTime, scheduledDays: [ScheduledDays.Everyday], time: time!)
        
        //get action plan and attach a task to it's accociated tasks
        ap.getOrCreateActionPlan
            {
                (actionPlanInstance, error) in
                guard error == nil else
                {
                    // bubble up error to ui
                    return
                }
                
                let (task, _ ) = ataskbulder.constructActionPlanTask()
                ap.createAndAttachAssociatedTask(task: task, plan: actionPlanInstance!)
                {
                    (taskInstance, error) in
                    // attach task's thing ID to medicatio
                    _ = medbuild.updateTaskConnection(taskThingId: (taskInstance?.identifier)!,
                                                      relationshipType: TaskRelationship.MedTask)
                }
            }
    }
    
    // MARK: Actions
    @IBAction func addMedication(_ sender: UIButton)
    {
        if(FormSubmission.canSubmit(subviews: self.view.subviews))
        {
            let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(
                with: HVFeaturesConfiguration.configuration())
            
            guard medicationBuilder.buildMedication(mhvThing:  MHVMedication.newThing()),
                medicationBuilder.updateNameIfNotNil(name: nameField.text!) else
            {
                // This is considered an error, bubble it up to the UI
                return
            }

            _ = medicationBuilder.updateDoseIfNotNil(amount: doseAmountField.text!, unit: doseUnitField.text!)
            
            makeTestPlanAndTask(medbuild: medicationBuilder, connection: connection) // temp
            let (medication, contructedProperly) = medicationBuilder.constructMedication()
            guard contructedProperly else
            {
                // This is an error, bubble up to user
                return
            }
            
            connection.thingClient()?.createNewThing(medication,  record: connection.personInfo!.selectedRecordID)
                {
                    (error: Error?) in
                }
        }
    }
}
