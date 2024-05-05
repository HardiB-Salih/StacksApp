//
//  PanelViewController.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/5/24.
//

import UIKit

class PanelViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let grabberView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        grabberView.backgroundColor = .label
        view.addSubview(grabberView)
        grabberView.center = CGPoint(x: view.center.x, y: 5)
        grabberView.layer.cornerRadius = 5
        grabberView.layer.cornerCurve = .continuous
        
        view.backgroundColor = .secondarySystemBackground
        
    }

}
