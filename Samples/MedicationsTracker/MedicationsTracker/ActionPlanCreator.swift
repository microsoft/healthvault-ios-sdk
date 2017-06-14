//
//  ActionPlanCreator.swift
//  MedicationsTracker
//
//  Created by Kayla Davis on 6/13/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

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
                (actionPlan) in
                DispatchQueue.main.async
                    {
                        self.actionPlanInstance = actionPlan
                    }
            
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
            objective.outcomeName = "Medicationtrends per week"
            objective.outcomeType = "Other"
            actionPlan.objectives = [objective]
            
            connection.remoteMonitoringClient()?.actionPlansCreate(withActionPlan: actionPlan, completion:
                {
                    (actionPlanInstance: MHVActionPlanInstanceV2?, error: Error?) in
                    DispatchQueue.main.async {
                        self.actionPlanInstance = actionPlanInstance
                    }
            })

        }
    }
    
    func createAndAttachAssociatedTask(task: MHVActionPlanTaskV2) -> MHVActionPlanTaskInstanceV2?
    {
        var taskInsanceToReturn: MHVActionPlanTaskInstanceV2? = nil
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(
            with: HVFeaturesConfiguration.configuration())
        
        connection.remoteMonitoringClient()?.actionPlanTasksCreate(withActionPlanTask: task, completion:
            { (taskInstance: MHVActionPlanTaskInstanceV2?, error: Error?) in
                self.actionPlanInstance?.associatedTasks?.append(taskInstance!)
                //TODO: handle update failure
                taskInsanceToReturn = taskInstance
            })
        return taskInsanceToReturn
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
