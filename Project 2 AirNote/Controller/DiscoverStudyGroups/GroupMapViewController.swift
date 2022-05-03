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
    
    let locationManager = CLLocationManager()
    
    // MARK: Groups Data
    var groups: [Group] = []
    
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
    }
}

// MARK: User's Location
extension GroupMapViewController {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        bringToUserLocation()
    }
    
    func bringToUserLocation() {
        let location = groupMapView.userLocation
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        groupMapView.setRegion(region, animated: true)
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
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func layoutGroup() {
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
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
