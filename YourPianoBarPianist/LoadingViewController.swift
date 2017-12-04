//
//  LoadingViewController.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 12/3/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// configure activity indicator?
		
		let realmSet = NotificationCenter.default.addObserver(forName: NSNotification.Name("realm set"), object: nil, queue: OperationQueue.main) { (notification) in
			self.performSegue(withIdentifier: "Show Request List", sender: nil)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let rtvc = segue.destination as? RequestsTableViewController {
			rtvc.realm = YPB.realmSynced
		}
	}
}
