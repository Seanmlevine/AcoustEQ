//
//  HomeViewController.swift
//  AcoustEQ
//
//  Created by Sean Levine on 12/7/21.

import SideMenu
import UIKit
import AVFoundation

class HomeViewController: UIViewController, FreqRespViewControllerDelegate {
    // Side Bar Init
    private var sideMenu: SideMenuNavigationController?
    let settingsController = SettingsViewController()
    let infoController = InfoViewController()
    let freqController = FreqRespViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        let menu = MenuController(with: SideMenuItem.allCases)
        menu.delegate = self
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true
        
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        
        addChildControllers()
        didSelectMenuItem(name: SideMenuItem.home)
    }
    
    private func addChildControllers() {
        addChild(settingsController)
        addChild(infoController)
        addChild(freqController)
        
        view.addSubview(settingsController.view)
        view.addSubview(infoController.view)
        view.addSubview(freqController.view)
        
        settingsController.view.frame = view.bounds
        infoController.view.frame = view.bounds
        freqController.view.frame = view.bounds
        
        settingsController.didMove(toParent: self)
        infoController.didMove(toParent: self)
        freqController.didMove(toParent: self)
        freqController.willMove(toParent: self)
        
        settingsController.view.isHidden = true
        infoController.view.isHidden = true
        freqController.view.isHidden = true
    }
    
    @IBAction func didTapMenuButton() {
        present(sideMenu!, animated: true)
    }
    
    func didSelectMenuItem(name: SideMenuItem) {
        sideMenu?.dismiss(animated: true, completion: nil)
            
            title = name.rawValue
            
            switch name {
            case .home:
                settingsController.view.isHidden = true
                infoController.view.isHidden = true
                freqController.view.isHidden = false
            case .info:
                settingsController.view.isHidden = true
                infoController.view.isHidden = false
                freqController.view.isHidden = true
            case .settings:
                settingsController.view.isHidden = false
                infoController.view.isHidden = true
                freqController.view.isHidden = true
            }
    }
}
