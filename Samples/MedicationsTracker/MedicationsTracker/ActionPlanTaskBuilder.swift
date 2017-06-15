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
    let actionPlanTask =  MHVActionPlanTaskV2.init()
    
    func updateMedicationTask(med: MHVMedication) -> Bool
    {
        let takeMed = "Take \(med.name.text)"
        
        // Set up task basics
        actionPlanTask.name = takeMed
        if (med.dose.displayText ?? "").isEmpty
        {
            actionPlanTask.signupName = takeMed
        }
        else
        {
             actionPlanTask.signupName =  "Take \(med.dose.displayText) of \(med.name)"
        }
        actionPlanTask.shortDescription = "Remember to take your medication"
        actionPlanTask.longDescription = "Taking your medication on time can help maintain your health"
        actionPlanTask.taskType = "Other"
        actionPlanTask.imageUrl = "http://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE13a3S?ver=884e"
        actionPlanTask.thumbnailImageUrl = "http://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE12EQP?ver=cba6"
        actionPlanTask.trackingPolicy = createMedTrackingPolicy(med.name.text)
        
        return true
    }
    
    func updateTimeSlotTask(med: MHVMedication) -> Bool
    {
        ///
        /// TODO: Change these values for the new task type
        ///
        let takeMed = "Take \(med.name.text)"
        
        // Set up task basics
        actionPlanTask.name = takeMed
        if (med.dose.displayText ?? "").isEmpty
        {
            actionPlanTask.signupName = takeMed
        }
        else
        {
            actionPlanTask.signupName =  "Take \(med.dose.displayText) of \(med.name)"
        }
        actionPlanTask.shortDescription = "Remember to take your medication"
        actionPlanTask.longDescription = "Taking your medication on time can help maintain your health"
        actionPlanTask.taskType = "Other"
        actionPlanTask.imageUrl = "http://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE13a3S?ver=884e"
        actionPlanTask.thumbnailImageUrl = "http://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE12EQP?ver=cba6"
        actionPlanTask.trackingPolicy = createMedTrackingPolicy(med.name.text)
        
        return true
    }
    
    func updateFrequencyMetric(windowType: ActionPlanWindowType) -> Bool
    {
        let freqMetric = MHVActionPlanFrequencyTaskCompletionMetricsV2.init()
        freqMetric.windowType = windowType.rawValue
        
        actionPlanTask.frequencyTaskCompletionMetrics = freqMetric
        return true
    }
    
    func updateSchedule(schedules: [MHVScheduleV2], reminderState: ReminderState,
                        scheduledDays: [ScheduledDays], time: MHVTime) -> Bool
    {
        let schedule = MHVScheduleV2.init()
        schedule.reminderState = reminderState.rawValue
        schedule.scheduledDays = scheduledDays.map{$0.rawValue}
        schedule.scheduledTime = time
        
        actionPlanTask.schedules =  schedules + [schedule]
        return true
    }
    
    func constructActionPlanTask() -> (MHVActionPlanTaskV2, contructedProperly: Bool)
    {
        guard actionPlanTask.taskType != nil, actionPlanTask.frequencyTaskCompletionMetrics?.windowType != nil,
            let sched = actionPlanTask.schedules, !sched.isEmpty else
        {
            return(actionPlanTask, false)
        }
        
        return (actionPlanTask, true)
    }
    
    private func createMedTrackingPolicy(_ medName: String) -> MHVActionPlanTrackingPolicy
    {
        let (tracking, target, _) = createTrackingPolicy()
        
        // Set the med name specifically as the target
        target.elementValues =  [medName]
        tracking.targetEvents = [target]
        
        return tracking

    }
    
    private func createTrackingPolicy() -> (trackingPolicy: MHVActionPlanTrackingPolicy,
        targetEvent: MHVActionPlanTaskTargetEvent, occurenceMetrics: MHVActionPlanTaskOccurrenceMetrics)
    {
        let trackingPolicy = MHVActionPlanTrackingPolicy.init()
        let targetEvent = MHVActionPlanTaskTargetEvent.init()
        let occurenceMetrics = MHVActionPlanTaskOccurrenceMetrics.init()
        
        targetEvent.elementXPath = "/thing/data-xml/medication/name/text"
        targetEvent.isNegated = false
        
        occurenceMetrics.evaluateTargets = false
        occurenceMetrics.targets = nil
        
        trackingPolicy.isAutoTrackable = true
        trackingPolicy.targetEvents = [targetEvent]
        trackingPolicy.occurrenceMetrics = occurenceMetrics
        
        return (trackingPolicy, targetEvent, occurenceMetrics)
    }
    
}

