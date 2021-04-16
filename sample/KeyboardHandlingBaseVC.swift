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
    @IBOutlet weak var numberPad: UITextField! {
        didSet {
            numberPad.addDoneToolbar()
        }
    }
    @IBOutlet weak var emailTF: UITextField! {
        didSet {
            emailTF.addDoneToolbar()
        }
    }
    @IBOutlet weak var urlTF: UITextField! {
        didSet {
            urlTF.addDoneToolbar()
        }
    }
    @IBOutlet weak var passwordTF: UITextField! {
        didSet {
            passwordTF.addDoneToolbar()
        }
    }
    @IBOutlet weak var phoneNumberTF: UITextField! {
        didSet {
            phoneNumberTF.addDoneToolbar()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTF.delegate = self
        numberPad.delegate = self
        passwordTF.delegate = self
        urlTF.delegate = self
        phoneNumberTF.delegate = self
        
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
        
        initializeHideKeyboard()
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

extension UITextField {
    func addDoneToolbar(onPrev: (target: Any, action: Selector)? = nil, onNext: (target: Any, action: Selector)? = nil, onDone: (target: Any, action: Selector)? = nil) {
        let onPrev = onPrev ?? (target: self, action: #selector(onPrevPressed))
        let onNext = onNext ?? (target: self, action: #selector(onNextPressed))
        let onDone = onDone ?? (target: self, action: #selector(onDonePressed))
        
        let bar = UIToolbar()
        
        let prevArrowBtn = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: onPrev.target, action: onPrev.action)
        let nextArrowBtn = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: onNext.target, action: onNext.action)
        let doneBtn = UIBarButtonItem(title: "Xong", style: .plain, target: onDone.target, action: onDone.action)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        bar.items = [prevArrowBtn,nextArrowBtn, flexSpace, doneBtn]
        bar.sizeToFit()
        self.inputAccessoryView = bar
    }
    
    @objc func onPrevPressed() {
        let textTag = self.tag - 1
        // 1st superview contain label and textField; 2nd superview contain other textfield
        let nextResponder = self.superview?.superview?.viewWithTag(textTag)
        if (nextResponder != nil) {
            nextResponder?.becomeFirstResponder()
        } else {
            self.resignFirstResponder()
        }
    }
    
    @objc func onNextPressed() {
        let textTag = self.tag + 1
        // 1st superview contain label and textField; 2nd superview contain other textfield
        let nextResponder = self.superview?.superview?.viewWithTag(textTag)
        if (nextResponder != nil) {
            nextResponder?.becomeFirstResponder()
        } else {
            self.resignFirstResponder()
        }
    }
    
    @objc func onDonePressed() {
        self.resignFirstResponder()
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
    
}
