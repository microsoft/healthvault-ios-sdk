//
//  CreateActionPlanViewController.swift
//  MedicationsTracker
//
//  Created by Kayla Davis on 6/13/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import UIKit

class CreateActionPlanViewController: UIViewController
{
    var actionPlanTaskBuilder: ActionPlanTaskBuilder?

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func createActionPlan()
    {         
        let actionPlan = actionPlanTaskBuilder?.constructActionPlanTask()

    }
}
