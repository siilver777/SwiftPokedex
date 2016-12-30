//
//  SettingsTableViewController.swift
//  PokeStats
//
//  Created by Jason Pierna on 30/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clearCache() {
        if let documentsURL = FileManager.documentsURL() {
            if let files = try? FileManager.default.contentsOfDirectory(atPath: documentsURL.path) {
                let filesToDelete = files.filter { $0.contains(".png") || $0.contains(".mp3") }
                
                for file in filesToDelete {
                    do {
                        try FileManager.default.removeItem(at: documentsURL.appendingPathComponent(file, isDirectory: false))
                    }
                    catch {
                        print(error)
                    }
                }
            }
        }
        
    }
}
