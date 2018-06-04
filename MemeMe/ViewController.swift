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
                self.save()
            }
            self.dismiss(animated: true, completion: nil)
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
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
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
        initializeTextField(textField, "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count == 0 {
            switch textField.tag {
            case 0:
                initializeTextField(textField, "TOP")
            case 1:
                initializeTextField(textField, "BOTTOM")
            default:
                break
            }
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
    
    func save() {
        //Create meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageViewController.image, memedImage: generateMemedImage())
    }

    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        configureBars(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        configureBars(false)
        
        return memedImage
    }
    
    func initializeUIComponent(){
        
        initializeTextField(topTextField, "TOP")
        initializeTextField(bottomTextField, "BOTTOM")
        
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
    
    func configureBars(_ isHidden: Bool){
            topToolbar.isHidden = isHidden
            bottomToolbar.isHidden = isHidden
        
    }
    
    func initializeTextField(_ textField: UITextField, _ withText: String) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.borderStyle = UITextBorderStyle.none
        textField.backgroundColor = UIColor.clear
        textField.autocapitalizationType = .allCharacters
        textField.text = withText
    }
    
    
}

