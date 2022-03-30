//
//  NavBarController.swift
//  AcoustEQ
//
//  Created by Sean Levine on 3/29/22.
//
import UIKit
class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
        self.delegate = self
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // Create Tab one
//        let tabOne = FreqRespViewController()
//        tabOne.title = "FFT"
//        let tabOneBarItem = UITabBarItem(title: "FFT", image: UIImage(systemName: "waveform.circle"), selectedImage: UIImage(systemName: "waveform.circle.fill") )
//
//
//        tabOne.tabBarItem = tabOneBarItem
//
//
//        // Create Tab two
//        let tabTwo = SettingsViewController2()
//        tabTwo.title = "Settings"
//        let tabTwoBarItem2 = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear.circle"), selectedImage: UIImage(systemName: "gear.circle.fill"))
//
//        tabTwo.tabBarItem = tabTwoBarItem2
//
//
//        self.viewControllers = [tabOne, tabTwo]
//    }
  


    // alternate method if you need the tab bar item
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // ...
    }
}
