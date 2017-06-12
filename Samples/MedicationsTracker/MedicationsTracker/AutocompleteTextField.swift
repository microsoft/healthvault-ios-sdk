//
//  AutocompleteTextField.swift
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

import UIKit

class AutocompleteTextField: MedicationTextField, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
    // MARK: Properties
    var autoComplete: MHVVocabularyCodeItemCollection?
    var tableView: UITableView?
    var tableHeight: CGFloat = 44 * 4
    var searcher = MedicationVocabSearcher.init()
    
    func setup()
    {
        if tableView == nil
        {
            let tableFrame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height,
                                         width: self.frame.size.width, height: self.tableHeight)
            self.tableView = UITableView.init(frame: tableFrame)
            self.tableView?.delegate = self
            self.tableView?.dataSource = self
            self.tableView?.isHidden = true
            self.delegate = self
            self.superview?.addSubview(self.tableView!)
        }
    }
    
    // MARK: UITableView Delagation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel!.text = autoComplete![UInt(indexPath.row)].displayText
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.autoComplete != nil
        {
            return Int(self.autoComplete!.count())
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        self.text = selectedCell.textLabel!.text!
        self.tableView?.isHidden = true
        
    }
    
    // MARK: UITextField Delegation
    override func resignFirstResponder() -> Bool
    {
        self.tableView?.isHidden = true
        return super.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,replacementString string: String) -> Bool
    {
        // Get substring and check if we the min size for searching was reached
        let substring = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if substring.characters.count >= searcher.minSearchSize
        {
            // Show autocomplete contents (for medications) in table view
            searcher.searchForMeds(searchValue: substring, completion:
                {
                    autocompleteContents in
                    DispatchQueue.main.async
                        {
                            self.autoComplete = autocompleteContents
                            self.tableView?.isHidden = autocompleteContents == nil
                            self.tableView?.reloadData()
                        }
                })
        }
        else
        {
            self.tableView?.isHidden = true
        }
        
        return true
    }
}
