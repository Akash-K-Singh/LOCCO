//
//  CreateReminderVC.swift
//  LOCCO
//
//  Created by Zignuts Technolab on 22/02/24.
//

import UIKit
import MaterialComponents

class CreateReminderVC: UIViewController {
    
    var reminderId: String = ""
    var prevTitle: String = ""
    var prevDate: String = ""
    
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
        if(reminderId != ""){
            // Set the create button text to update button text
            btnCreateReminder.setTitle("Update reminder", for: .normal)
            
            // Set the title
            txtWhereTo.text = prevTitle
            
            // Set the text of txtDate with the formatted date string
            txtDate.text = formatDateString(prevDate)
        }
    }
    
    func formatDateString(_ dateString: String) -> String? {
        // Parse the prevDate string into a Date object
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Use the format of the prevDate string
        
        if let date = dateFormatter.date(from: dateString) {
            // Format the date into the desired format "ddMMyy HHmm"
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm" // Change to the desired format "ddMMyy HHmm"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        } else {
            print("Failed to parse prevDate string into Date object")
            return nil
        }
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
        if(reminderId==""){
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
        } else {
            if SMValidator.isEmptyString(self.currentValue.title) {
                self.currentValue.title = prevTitle
            }
            
            if self.currentValue.date == nil {
                // Create a date formatter
                let dateFormatter = DateFormatter()
                // Set the date format according to the format of the prevDate string
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                // Convert the prevDate string to a Date object
                if let date = dateFormatter.date(from: prevDate) {
                    // Assign the converted date to self.currentValue.date
                    self.currentValue.date = date
                } else {
                    // Handle the case where prevDate string cannot be converted to a Date
                    print("Failed to convert prevDate string to Date")
                }
            }

            
            vmReminder.putReminderToAPI(id: reminderId, title: currentValue.title!, date: currentValue.date!) { success in
                if success {
                    // Handle success case
                    print("Reminder update successfully!")
                } else {
                    // Handle failure case
                    print("Failed to update reminder.")
                }
            }
            
            view.makeToast("Reminder updated successfully!") { didTap in
                self.navigationController?.popViewController(animated: true)
            }
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
