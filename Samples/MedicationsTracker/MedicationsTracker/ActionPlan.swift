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

class ActionPlan
{
    var actionPlanInstance: MHVActionPlanInstanceV2?
    
    func getOrCreateActionPlan()
    {
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(
            with: HVFeaturesConfiguration.configuration())
        
        // Get action plan
        findActionPlan(connection: connection, completion:
            {
                (actionPlan) in self.actionPlanInstance = actionPlan
            })
        
        // If the action plan is nil create one
        if self.actionPlanInstance == nil
        {
            let actionPlan = MHVActionPlanV2.init()
            actionPlan.name = "Medication"
            actionPlan.descriptionText = "Track your medication"
            actionPlan.category = "Health"
            actionPlan.imageUrl = "http://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE137sA?ver=e6fc"
            actionPlan.thumbnailImageUrl = "http://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE137sA?ver=e6fc"
            
            // Setup objective
            let objective = MHVObjective.init()
            objective.name = "Take your medication"
            objective.outcomeName = "Medication trends per week"
            objective.outcomeType = "Other"
            actionPlan.objectives = [objective]
            
            connection.remoteMonitoringClient()?.actionPlansCreate(withActionPlan: actionPlan, completion:
                {
                    (actionPlanInstance: MHVActionPlanInstanceV2?, error: Error?) in
                        self.actionPlanInstance = actionPlanInstance
            })

        }
    }
    
    
    func createAndAttachAssociatedTask(task: MHVActionPlanTaskV2, completion: @escaping(MHVActionPlanTaskInstanceV2?) -> Void)
    {
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(
            with: HVFeaturesConfiguration.configuration())
        
        connection.remoteMonitoringClient()?.actionPlanTasksCreate(withActionPlanTask: task, completion:
            { (taskInstance: MHVActionPlanTaskInstanceV2?, error: Error?) in
                self.actionPlanInstance?.associatedTasks?.append(taskInstance!)
                completion(taskInstance)
            })
    }
    
    private func findActionPlan(connection: MHVSodaConnectionProtocol, completion: @escaping(MHVActionPlanInstanceV2?) -> Void)
    {
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(
            with: HVFeaturesConfiguration.configuration())
        
        // Iterate though current action plans, until you find one that matches the app id
        connection.remoteMonitoringClient()?.actionPlansGet(withMaxPageSize: 1000, completion:
            { (actionPlans: MHVActionPlansResponseActionPlanInstanceV2_?, error: Error?) in
                let plans = actionPlans?.plans as! [MHVActionPlanInstanceV2]
                for actionPlan in plans
                {
                    if actionPlan.organizationId == HVFeaturesConfiguration.configuration().masterApplicationId.uuidString
                    {
                        completion(actionPlan)
                    }
                }
                completion(nil)
            })
    }
}
