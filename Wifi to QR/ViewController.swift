//
//  ViewController.swift
//  Wifi to QR
//
//  Created by Eugen on 07.05.18.
//  Copyright © 2018 Eugen. All rights reserved.
//

import UIKit
import DTTextField

class ViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
    private let notificationCenter = NotificationCenter.default
    
    @IBOutlet weak var nameTextfield: DTTextField!
    @IBOutlet weak var passwordTextField: DTTextField!
    @IBOutlet weak var encryptionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextfield.delegate = self
        nameTextfield.borderColor = .darkGray
        nameTextfield.canShowBorder = true
        nameTextfield.dtborderStyle = .rounded
        nameTextfield.placeholder = "Wifi Name"
        nameTextfield.tag = 0
        nameTextfield.becomeFirstResponder()
        
        passwordTextField.delegate = self
        passwordTextField.borderColor = .darkGray
        passwordTextField.canShowBorder = true
        passwordTextField.dtborderStyle = .rounded
        passwordTextField.placeholder = "Wifi Password"
        passwordTextField.tag = 1
        
        qrImageView.contentMode = .scaleAspectFit
        
        notificationCenter.addObserver(self, selector: #selector(ViewController.didShowKeyboard), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.didHideKeyboard), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        let tapPressRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ViewController.export))
        qrImageView.addGestureRecognizer(tapPressRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ViewController.export))
        qrImageView.addGestureRecognizer(longPressRecognizer)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            nameTextfield.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
            return false
        default:
            passwordTextField.resignFirstResponder()
            nameTextfield.becomeFirstResponder()
            return false
        }
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.sourceView = qrImageView
        popoverPresentationController.canOverlapSourceViewRect = true
        popoverPresentationController.sourceRect = qrImageView.frame
        popoverPresentationController.permittedArrowDirections = [.any]
    }
    
    @objc func export(){
        passwordTextField.resignFirstResponder()
        nameTextfield.resignFirstResponder()
        
        let exportImage = view.makeScreenshot()
        let activityViewController = UIActivityViewController(activityItems: [exportImage], applicationActivities: nil)
        activityViewController.popoverPresentationController?.delegate = self
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func didShowKeyboard(_ notification: Notification){
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            self.bottomConstrain.constant = 20 + keyboardFrame.cgRectValue.height
            self.qrImageView.setNeedsUpdateConstraints()
            self.qrImageView.setNeedsLayout()
        }
    }
    
    @objc func didHideKeyboard(){
        self.bottomConstrain.constant = 20
        self.qrImageView.setNeedsUpdateConstraints()
        self.qrImageView.setNeedsLayout()
    }
    
    @IBAction func onValueChangedName(_ sender: Any) {
        update()
    }
    
    @IBAction func onValueChangedPassword(_ sender: Any) {
        update()
    }
    
    @IBAction func onValueChangedSegment(_ sender: Any) {
        update()
    }
    
    func update(){
        guard let encodedString = buildString(),
            let image = generateQRCode(from: encodedString) else {
                return
        }
        qrImageView.image = image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func buildString() -> String? {
        guard let wifiNameString = nameTextfield.text,
            let passwordString = passwordTextField.text,
            let encryptionType = encryptionSegmentedControl.titleForSegment(at: encryptionSegmentedControl.selectedSegmentIndex) else {
                return nil
        }
        
        return "WIFI:S:\(wifiNameString);T:\(encryptionType);P:\(passwordString);;"
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 20, y: 20)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
}
