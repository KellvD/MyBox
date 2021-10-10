//
//  CDMapViewController.swift
//  MyBox
//
//  Created by changdong on 2020/11/12.
//  Copyright © 2020 changdong. All rights reserved.
//

import UIKit
import MapKit
class CDMapViewController: CDBaseAllViewController,MKMapViewDelegate {

    private var _isNeedUpdate:Bool!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        startLocation()
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.pinView)
        self.view.addSubview(self.locationButton)
         
        
    }
    
    func startLocation(){
//        self.locationManager.startUpdatingLocation()
       let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
       let userRegion = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: span)
        self.mapView.setRegion(userRegion, animated: true)
    }
    
//    func stopLocation(){
//        self.locationManager.stopUpdatingLocation()
//    }

    
    //点击地图定位
    @objc func onTapMap(tap:UITapGestureRecognizer){
        let point = tap.location(in: self.mapView)
        let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
        self.mapView.setCenter(coordinate, animated: true)
    }

    //回到用户位置
    @objc func onSetUserLocation(){
        self.mapView .setCenter(self.mapView.userLocation.coordinate, animated: true)
        _isNeedUpdate = true
    }

    //区域改变
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let coordinate = self.mapView.region.center
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil{
                placemarks?.forEach({ (place) in

                })
            }
        }
    }

    
    
    lazy var mapView: MKMapView = {
        let map = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        map.delegate = self
        map.mapType = .standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.isRotateEnabled = true
        map.showsScale = true
        map.showsCompass = true
        map.showsBuildings = true
        map.showsUserLocation = true
        
        map.setUserTrackingMode(.follow, animated: true)
        map.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapMap(tap:))))
        return map
    }()
    
//    lazy var locationManager: CLLocationManager = {
//        let locationM = CLLocationManager()
//        locationM.distanceFilter = 1000.0
//        locationM.desiredAccuracy = kCLLocationAccuracyBest
//        locationM.requestWhenInUseAuthorization()
//        locationM.startUpdatingLocation()
//        return locationM
//    }()
    lazy var locationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "abc_btn_radio"), for: .normal)
        button.frame = CGRect(x: 15, y: 15 + 84, width: 35, height: 35)
        button.addTarget(self, action: #selector(onSetUserLocation), for: .touchUpInside)
        return button
    }()
    
    lazy var pinView: UIImageView = {
        let pin = UIImageView(frame: CGRect(x: self.mapView.frame.midX - 30, y: self.mapView.frame.midY - 30, width: 60, height: 60))
        pin.image = UIImage(named: "icon_location_blcak")
        return pin
    }()
    

    

}
