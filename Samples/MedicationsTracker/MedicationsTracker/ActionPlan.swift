//
//  ActionPlan.swift
//  MedicationsTracker
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

import Foundation

enum ActionPlanError: Error
{
    case CreationFailure
}

class ActionPlan
{
    private var connection: MHVSodaConnectionProtocol
    
    init(connection: MHVSodaConnectionProtocol)
    {
        self.connection = connection
    }
    
    func getOrCreateActionPlan(completion: @escaping(MHVActionPlanInstanceV2?, Error?) -> Void)
    {
        // Get action plan
        findActionPlan(connection: connection)
            {
                (actionPlan, error) in
                // Check for errors in finding the plan
                guard error == nil else
                {
                    completion(nil, error)
                    return
                }
                
                // Check for data
                if actionPlan == nil
                {
                    self.createMedicationPlan
                        {
                            (newActionPlan, error) in
                            // Check for errors in creating a plan
                            guard error == nil else
                            {
                                completion(nil, error)
                                return
                            }
                            
                            completion(newActionPlan!, nil)
                        }
                }
                else
                {
                    completion(actionPlan!, nil)
                }
            }
    }
    
    func createMedicationPlan(completion: @escaping(MHVActionPlanInstanceV2?, Error?) -> Void)
    {
        let actionPlan = MHVActionPlanV2.init()
        actionPlan.name = "Medication"
        actionPlan.descriptionText = "Track your medication"
        actionPlan.category = "Health"
        actionPlan.imageUrl = "http://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE137sA?ver=e6fc"
        actionPlan.thumbnailImageUrl = "http://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE137sA?ver=e6fc"
        
        let objective = MHVObjective.init()
        objective.name = "Take your medication"
        objective.outcomeName = "Medication trends per week"
        objective.outcomeType = "Other"
        actionPlan.objectives = [objective]
        
        connection.remoteMonitoringClient()?.actionPlansCreate(withActionPlan: actionPlan, completion:
            {
                (actionPlanInstance: MHVActionPlanInstanceV2?, error: Error?) in
                // Check for errors in action plan creation
                guard error == nil else
                {
                    completion(nil, error)
                    return
                }
                
                completion(actionPlanInstance, nil)
        })
    }
    
    func createAndAttachAssociatedTask(task: MHVActionPlanTaskV2, plan: MHVActionPlanInstanceV2,
                                       completion: @escaping(MHVActionPlanTaskInstanceV2?, Error?) -> Void)
    {
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(
            with: HVFeaturesConfiguration.configuration())
        
        connection.remoteMonitoringClient()?.actionPlanTasksCreate(withActionPlanTask: task, completion:
            { (taskInstance: MHVActionPlanTaskInstanceV2?, error: Error?) in
                // Check for errors in task creation
                guard error == nil else
                {
                    completion(nil, error)
                    return
                }
                
                plan.associatedTasks?.append(taskInstance!)
                completion(taskInstance, nil)
            })
    }
    
    private func findActionPlan(connection: MHVSodaConnectionProtocol,
                                completion: @escaping(MHVActionPlanInstanceV2?, Error?) -> Void)
    {
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(
            with: HVFeaturesConfiguration.configuration())
        
        let appId = HVFeaturesConfiguration.configuration().masterApplicationId.uuidString
        
        // Iterate though current action plans, until you find one that matches the app id
        connection.remoteMonitoringClient()?.actionPlansGet(withMaxPageSize: 1000, completion:
            { (actionPlans: MHVActionPlansResponseActionPlanInstanceV2_?, error: Error?) in
                // Check for errors in plans get
                guard error == nil else
                {
                    completion(nil, error)
                    return
                }
                
                let plans = actionPlans?.plans as? [MHVActionPlanInstanceV2]
                plans?.forEach
                    { actionPlan in
                        if actionPlan.organizationId == appId
                        {
                            completion(actionPlan, nil)
                            return
                        }
                    }
            })
    }
}
