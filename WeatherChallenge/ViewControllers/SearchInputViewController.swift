//
//  SearchInputViewController.swift
//  WeatherChallenge
//
//  Created by Ilias Basha on 7/7/23.
//

import UIKit

protocol SearchInputViewControllerDelegate: AnyObject {
    func searchViewController(_ viewController: SearchInputViewController, didEnterLocation input: String)
    func searchViewControllerDidTriggerCurrentLocation(_ viewController: SearchInputViewController)
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
        if let text = searchTextField.text {
            delegate?.searchViewController(self, didEnterLocation: text)
        } else {
            // highlight the textfield?
        }
        dismiss(animated: true)
    }
    
    @objc func useCurrentLocationButtonTapped() {
        delegate?.searchViewControllerDidTriggerCurrentLocation(self)
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
