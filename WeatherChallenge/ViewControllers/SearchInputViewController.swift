//
//  SearchInputViewController.swift
//  WeatherChallenge
//
//  Created by Ilias Basha on 7/7/23.
//

import UIKit

protocol SearchInputViewControllerDelegate: AnyObject {
    /// Notifies the main view controller of the text that was entered on this screen
    func searchViewControllerDidEnterLocation(input: String)
    /// Notifies the main view controller that it should fetch the users current location
    func searchViewControllerDidTriggerCurrentLocation()
}

class SearchInputViewController: UIViewController {
    
    weak var delegate: SearchInputViewControllerDelegate?
    
    // UI Components
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter city, state, or country code"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let useCurrentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Use Current Location", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("X", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the views
        view.addSubview(searchTextField)
        view.addSubview(confirmButton)
        view.addSubview(useCurrentLocationButton)
        view.addSubview(closeButton)
        
        self.view.backgroundColor = .white
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        useCurrentLocationButton.addTarget(self, action: #selector(useCurrentLocationButtonTapped), for: .touchUpInside)
        
        setupLayout()
    }
    
    @objc func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func confirmButtonTapped() {
        if let text = searchTextField.text, !text.isEmpty {
            delegate?.searchViewControllerDidEnterLocation(input: text)
            dismiss(animated: true)
        } else {
            searchTextField.shake()
        }
    }
    
    @objc func useCurrentLocationButtonTapped() {
        delegate?.searchViewControllerDidTriggerCurrentLocation()
        dismiss(animated: true)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            searchTextField.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            confirmButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            confirmButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            useCurrentLocationButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 16),
            useCurrentLocationButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            useCurrentLocationButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}

protocol Shakable {
    func shake()
}
// allow all UIView children to be animated
extension Shakable where Self: UIView {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.03
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}

extension UITextField: Shakable {}
