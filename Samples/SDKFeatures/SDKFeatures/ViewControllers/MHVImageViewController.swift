//
//  MHVImageViewController.swift
//  MHVLib
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
//

import UIKit

class MHVImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, image: UIImage)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.image = image
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.image = nil
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        imageView.image = self.image
    }
}
