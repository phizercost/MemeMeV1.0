//
//  ViewController.swift
//  MemeMe
//
//  Created by Phizer Cost on 5/17/18.
//  Copyright © 2018 Phizer Cost. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    // MARK: Outlets
    
    @IBOutlet weak var imageViewController: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    // MARK: Actions
    
    @IBAction func pickImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        switch sender.tag {
        case 0:
            imagePicker.sourceType = .camera
        case 1:
            imagePicker.sourceType = .photoLibrary
        default:
            break
        }
        present(imagePicker, animated: true, completion: nil)
        allowUIEdit()
    }
    
    
    
    
    @IBAction func cancelAction(_ sender: Any) {
        initializeUIComponent()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        
        let meme = generateMemedImage()
        let activity = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        
        activity.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.present(activity, animated: true, completion: nil)
        
    }
    
    // MARK: Constants
    
    // Meme Text Attributes
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "Impact", size: 20)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3.5]

    let imagePickerView = UIImagePickerController()
    
    
    // MARK: Meme Structure
    struct Meme {
        var topText: String?
        var bottomText: String?
        var originalImage: UIImage?
        var memedImage: UIImage
    }
    
    // MARK: Overriden Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUIComponent()
    }

    
    // MARK: Keyboard Functions
    
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    // MARK: Functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageViewController.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setTextFields(textField, "reset")
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            subscribeToKeyboardNotifications()
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count == 0 {
            setTextFields(textField, "setInitials")
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    

    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        hideToolbars()
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        showToolbars()
        
        return memedImage
    }
    
    func initializeUIComponent(){
        
        self.topTextField.delegate = self
        self.bottomTextField.delegate = self
        
        setTextFields(topTextField, "setInitials")
        setTextFields(bottomTextField, "setInitials")
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
        topTextField.borderStyle = UITextBorderStyle.none
        topTextField.backgroundColor = UIColor.clear
        
        bottomTextField.borderStyle = UITextBorderStyle.none
        bottomTextField.backgroundColor = UIColor.clear
        
        self.topTextField.autocapitalizationType = .allCharacters
        self.bottomTextField.autocapitalizationType = .allCharacters
        
        
        if(!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            cameraButton.isEnabled = false
        }
        topTextField.isEnabled = false
        bottomTextField.isEnabled = false
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
        
        imageViewController.image = nil
    }
    
    func allowUIEdit(){
        shareButton.isEnabled = true
        cancelButton.isEnabled = true
        topTextField.isEnabled = true
        bottomTextField.isEnabled = true
    }
    
    func hideToolbars(){
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true
    }
    
    func showToolbars(){
        topToolbar.isHidden = false
        bottomToolbar.isHidden = false
    }
    
    func setTextFields(_ textField: UITextField, _ action: String){
        switch action {
        case "setInitials":
            switch textField.tag {
            case 0:
                textField.text = "TOP"
            case 1:
                textField.text = "BOTTOM"
            default:
                break
            }
        case "reset":
            switch textField.tag {
            case 0:
                textField.text = ""
            case 1:
                textField.text = ""
            default:
                break
            }
       default:
            break
        }
    }
    
   
    
    
    
}

