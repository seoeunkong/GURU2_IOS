//
//  NMFMapView.swift
//  GURU2Project
//
//  Created by apple on 2022/01/30.
//

import UIKit
import NMapsMap
class NMFMapView:UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)
    }
}
