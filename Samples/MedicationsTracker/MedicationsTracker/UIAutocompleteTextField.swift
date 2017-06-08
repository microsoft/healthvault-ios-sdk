//
//  UIAutocompleteTextField.swift
//  MedicationsTracker
//
//  Created by Kayla Davis on 6/7/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import UIKit

class UIAutocompleteTextField: UIMedicationTextField, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
    // MARK: Properties
    var autoComplete: MHVVocabularyCodeItemCollection?
    var tableView: UITableView?
    var tableHight: CGFloat = 44 * 4
    var searcher = MedicationVocabSearcher.init()
    
    func setup()
    {
        if tableView != nil
        {
            let tableFrame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height,
                                         width: self.frame.size.width, height: self.tableHight)
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
