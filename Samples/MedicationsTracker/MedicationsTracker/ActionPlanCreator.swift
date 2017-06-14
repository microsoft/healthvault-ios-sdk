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
    var actionPlan: MHVActionPlanV2
    init()
    {
        // Setup action plan
        actionPlan = MHVActionPlanV2.init()
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
    }
    
    func createActionPlan()
    {
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(
            with: HVFeaturesConfiguration.configuration())
        if(connection.remoteMonitoringClient()?)
        connection.remoteMonitoringClient()?.actionPlansCreate(withActionPlan: actionPlan, completion:
            {
                (actionPlanInstance: MHVActionPlanInstanceV2?, error: Error?) in
        })
    }
}
