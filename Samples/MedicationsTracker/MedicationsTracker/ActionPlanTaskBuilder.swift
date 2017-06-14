//
//  ActionPlanTaskBuilder.swift
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

class ActionPlanTaskBuilder
{
    private(set) var actionPlanTask: MHVActionPlanTaskV2?
    
    func buildActionPlanTask(med: MHVMedication) -> ActionPlanTaskBuilder
    {
        let takeMed = "Take \(med.name.text)"
        
        // Set up tasks
        actionPlanTask = MHVActionPlanTaskV2.init()
        actionPlanTask!.name = takeMed
        if (med.dose.displayText ?? "").isEmpty
        {
            actionPlanTask?.signupName = takeMed
        }
        else
        {
             actionPlanTask?.signupName =  "Take \(med.dose.displayText) of \(med.name)"
        }
        actionPlanTask!.shortDescription = "Remember to take your medication"
        actionPlanTask!.longDescription = "Taking your medication on time can help maintain your health"
        actionPlanTask!.taskType = "Other"
        actionPlanTask!.imageUrl = "http://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE13a3S?ver=884e"
        actionPlanTask!.thumbnailImageUrl = "http://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE12EQP?ver=cba6"
        actionPlanTask!.data.common.relatedthing
        actionPlanTask!.trackingPolicy = createTrackingPolicy(med.name.text)
        
        return self
    }
    
    func updateFrequencyMetric(windowType: String) -> Bool
    {
        let freqMetric = MHVActionPlanFrequencyTaskCompletionMetricsV2.init()
        freqMetric.windowType = windowType
        
        actionPlanTask!.frequencyTaskCompletionMetrics = freqMetric
        return true
    }
    
    func updateSchedule(schedules: [MHVScheduleV2], reminderState: String, scheduledDays: [String], time: MHVTime) -> Bool
    {
        let schedule = MHVScheduleV2.init()
        schedule.reminderState = reminderState
        schedule.scheduledDays = scheduledDays
        schedule.scheduledTime = time
        
        actionPlanTask!.schedules =  schedules + [schedule]
        return true
    }
    
    func constructActionPlanTask() -> MHVActionPlanTaskV2
    {
        return actionPlanTask!
    }
    
    private func createTrackingPolicy(_ medName: String) -> MHVActionPlanTrackingPolicy
    {
        let trackingPolicy = MHVActionPlanTrackingPolicy.init()
        let targetEvent = MHVActionPlanTaskTargetEvent.init()
        
        targetEvent.elementXPath = "/thing/data-xml/medication/name/text"
        targetEvent.elementValues =  [medName]
        targetEvent.isNegated = false
        
        trackingPolicy.isAutoTrackable = true
        trackingPolicy.targetEvents = [targetEvent]
        
        return trackingPolicy

    }
    
}

