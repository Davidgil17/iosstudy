//
//  SettingsController.swift
//  wgo
//
//  Created by Sharat Sridhar on 11/17/14.
//  Copyright (c) 2014 DJSS. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class SettingsController: UIViewController {
    
    let service = "WGO"
    let userAccount = "WGOUser"
    let key = "wgoAuth"
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad() {
      
        logOutButton.addTarget(self, action: Selector("logOutClick"), forControlEvents: .TouchUpInside)
        super.viewDidLoad()
        
    }
    
    func logOutClick(){
        
        Locksmith.deleteData(forKey: key, inService: service, forUserAccount: userAccount)
    }
    
}