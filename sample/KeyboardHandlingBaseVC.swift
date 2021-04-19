//
//  KeyboardHandlingBaseVCViewController.swift
//  sample
//
//  Created by Nguyen Xuan Phu on 4/5/21.
//  Copyright © 2021 Nguyen Xuan Phu. All rights reserved.
//

import UIKit

class KeyboardHandlingBaseVC: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var backgroundSV: UIScrollView!
    @IBOutlet weak var numberPad: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var urlTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTF.delegate = self
        numberPad.delegate = self
        passwordTF.delegate = self
        urlTF.delegate = self
        phoneNumberTF.delegate = self
        
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide))
        
        initializeHideKeyboard()
        
        addInputAccessoryForTextFields(textFields: [numberPad, emailTF, passwordTF, phoneNumberTF, urlTF], dismissable: true, previousNextable: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //        textField.resignFirstResponder()
        
        let textTag = textField.tag + 1
        // 1st superview contain label and textField; 2nd superview contain other textfield
        let nextResponder = textField.superview?.superview?.viewWithTag(textTag)
        if (nextResponder != nil) {
            nextResponder?.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        
        return true
    }
}

// MARK : Keyboard with Toolbar
extension KeyboardHandlingBaseVC {
    func addInputAccessoryForTextFields(textFields: [UITextField], dismissable: Bool = true, previousNextable: Bool = false) {
        for (index, textField) in textFields.enumerated() {
            let toolbar: UIToolbar = UIToolbar()
            toolbar.sizeToFit()
            
            var items = [UIBarButtonItem]()
            
            if previousNextable {
                let previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: nil, action: nil)
                previousButton.width = 30
                
                if textField == textFields.first {
                    previousButton.isEnabled = false
//                    backgroundSV.contentInset.top = 200
                } else {
                    previousButton.target = textFields[index - 1]
                    previousButton.action = #selector(UITextField.becomeFirstResponder)
                }
                
                let nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: nil, action: nil)
                nextButton.width = 30
                
                if textField == textFields.last {
                    nextButton.isEnabled = false
                } else {
                    nextButton.target = textFields[index + 1]
                    nextButton.action = #selector(UITextField.becomeFirstResponder)
                }
                items.append(contentsOf: [previousButton, nextButton])
            }
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Xong", style: .plain, target: view, action: #selector(UIView.endEditing))
            doneButton.width = 30
            
            items.append(contentsOf: [spacer, doneButton])
            
            
            toolbar.setItems(items, animated: false)
            textField.inputAccessoryView = toolbar
        }
    }
}

// MARK : Keyboard Dismissal Handling on Tap
private extension KeyboardHandlingBaseVC {
    
    func initializeHideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
}

// MARK : Textfield Visibility Handling with Scroll
private extension KeyboardHandlingBaseVC {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        
        // Pull a bunch of info out of the notification
        if let scrollView = backgroundSV, let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            
            // Transform the keyboard's frame into our view's coordinate system
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            
            // Find out how much the keyboard overlaps the scroll view
            // We can do this because our scroll view's frame is already in our view's coordinate system
            let marginKeyboardAndTextfield: CGFloat = 20
            let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y + marginKeyboardAndTextfield
            
            // Set the scroll view's content inset to avoid the keyboard
            // Don't forget the scroll indicator too!
            scrollView.contentInset.bottom = keyboardOverlap
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardOverlap
            
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        backgroundSV.contentInset.bottom = contentInsets.bottom + 20
        backgroundSV.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        
        // reset back the content inset to zero after keyboard is gone
        backgroundSV.contentInset = contentInsets
        backgroundSV.scrollIndicatorInsets = contentInsets
    }
}
