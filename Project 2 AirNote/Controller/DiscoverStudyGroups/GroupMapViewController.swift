//
//  GroupMapViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/25.
//

import UIKit
import MapKit
import CoreLocation

class GroupMapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var groupMapView: MKMapView!
    
    @IBOutlet weak var bringToUserLocationButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    
    // MARK: Groups Data
    var groups: [Group] = []
    
    var users: [User] = []
    
    var user: User?
    
    var userToBeBlocked = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Navigation Item
        navigationItem.title = "附近的讀書會"
        
        // Set Up Map View
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 20.0
        
        
        // Set up group annotation
        groupMapView.delegate = self
        layoutGroup()
        configButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bringToUserLocationButton.layer.cornerRadius =  bringToUserLocationButton.frame.height / 2
    }
}

// MARK: User's Location
extension GroupMapViewController {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if groupMapView.userLocation.coordinate.latitude != 0.0 || groupMapView.userLocation.coordinate.longitude != 0.0 {
        bringToUserLocation()
        } else {
            return
        }
    }
    
    @objc func bringToUserLocation() {
        locationManager.startUpdatingLocation()
        let location = groupMapView.userLocation
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        groupMapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func configButton() {
        
        //  Button
        bringToUserLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        bringToUserLocationButton.tintColor = .myDarkGreen
        bringToUserLocationButton.backgroundColor = .white
        bringToUserLocationButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        bringToUserLocationButton.addTarget(self, action: #selector(bringToUserLocation), for: .touchUpInside)
        
    }
    
}

// MARK: Annotation Location
extension GroupMapViewController: MKMapViewDelegate {
    
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        
        guard let annotation = annotation as? Annotation else {
            return nil
        }
        
        let identifier = "group"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            button.setImage(UIImage(systemName: "plus.magnifyingglass"), for: .normal)
            button.tintColor = .myDarkGreen
            view.rightCalloutAccessoryView = button
        }
        return view
    }
    
    func layoutGroup() {
        
        var tag = 0
        
        for group in groups {
            let coordinate = CLLocationCoordinate2D(latitude: group.location.latitude, longitude: group.location.longitude)
            let title = group.groupTitle
            let subtitle = group.location.address
            let groupId = group.groupId
            
            let annotation = Annotation(
                coordinate: coordinate,
                title: title,
                subtitle: subtitle,
                groupId: groupId)

            groupMapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as? Annotation
        let group = groups.filter { $0.groupId == annotation?.groupId}
        
        let storyBoard = UIStoryboard(name: "GroupDetail", bundle: nil)
        guard let vc =  storyBoard.instantiateViewController(withIdentifier: "GroupDetailViewController") as? GroupDetailViewController else { return }
        vc.group = group[0]
        vc.users = users
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
