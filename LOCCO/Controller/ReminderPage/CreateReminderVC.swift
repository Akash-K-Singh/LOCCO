//
//  CreateReminderVC.swift
//  LOCCO
//
//  Created by Zignuts Technolab on 22/02/24.
//

import UIKit
import MaterialComponents

class CreateReminderVC: UIViewController {
    
    @IBOutlet weak var txtWhereTo: MDCOutlinedTextField!
    @IBOutlet weak var txtDate: MDCOutlinedTextField!
    @IBOutlet weak var viewDPBase: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var btnDPOk: SMButton!
    @IBOutlet weak var btnDPCancel: SMButton!
    @IBOutlet weak var btnCancel: SMButton!
    @IBOutlet weak var btnCreateReminder: SMButton!
    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var scrollViewMain: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet var createRemainderButtonStack: UIStackView!
    fileprivate var currentValue:(date:Date?, title:String?) = (nil, nil)

    //MARK: - Properties
    let vmReminder = ViewModelReminder()
    
    var isShowDatepicker:Bool = false {
        didSet {
            updateDatePicker()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: - Actions
    @IBAction func pickDateClicked(_ sender: Any) {
        self.view.endEditing(true)
        isShowDatepicker = true
    }
    
    @IBAction func dpOKClicked(_ sender: Any) {
        currentValue.date = datePicker.date
        txtDate.text = currentValue.date?.formatedWithtime()
        isShowDatepicker = false
    }
    
    @IBAction func dpCancelClicked(_ sender: Any) {
        isShowDatepicker = false
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCreateClicked(_ sender: Any) -> Void {
        self.currentValue.title = txtWhereTo.text
        if SMValidator.isEmptyString(self.currentValue.title) {
            view.makeToast("Please enter where to")
            return
        }
        
        if self.currentValue.date == nil {
            view.makeToast("Please select date")
            return
        }
        
        vmReminder.pushReminderToAPI(title: currentValue.title, date: currentValue.date) { success in
            if success {
                // Handle success case
                print("Reminder pushed successfully!")
            } else {
                // Handle failure case
                print("Failed to push reminder.")
            }
        }
        
        view.makeToast("Reminder added successfully!") { didTap in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Helper
    
    func initialSetup() {
        headerView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 32)
        scrollViewMain.contentInset.top = 40
        lblNavTitle.text = "reminder_page_new_reminder-title".translated.uppercased()
        btnDPOk.setTitle("e-mail_registration_password-strength-ok".translated.uppercased(), for: .normal)
        btnDPCancel.setTitle("cancel-button".translated, for: .normal)
        btnCreateReminder.setTitle("reminder_page_empty_button".translated, for: .normal)
        btnCancel.setTitle("cancel-button".translated, for: .normal)
        
        txtWhereTo.accessibilityIdentifier =  "description"
        txtWhereTo.label.text = "reminder_page_new_reminder-input-field".translated
        txtWhereTo.themeWhiteFill()
        
        txtDate.accessibilityIdentifier =  "date"
        txtDate.label.text = "reminder_page_new_reminder-date-picker".translated
        txtDate.themeWhiteFill()
        
        txtWhereTo.delegate = self
    }
    
    func updateDatePicker() {
        self.createRemainderButtonStack.isHidden = self.isShowDatepicker
        UIView.animate(withDuration: 0.2) {
            self.viewDPBase.isHidden = !self.isShowDatepicker
        }
    }
    
    
    /// execute when textfield editing changed
    @objc func textFieldTextChanged(_ textfield:MDCOutlinedTextField) {
       
    }

}

extension CreateReminderVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
}
