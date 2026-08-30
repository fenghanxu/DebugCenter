//
//  AViewController.swift
//  DebugCenter_Example
//
//  Created by imac on 2026/8/30.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit

class AViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now()+1.0) {
            DispatchQueue.main.async {
//                self.navigationController?.pushViewController(AViewController(), animated: true)
                        self.present(BViewController(), animated: true)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
