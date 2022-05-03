//
//  Annotations.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/25.
//

import MapKit

class Annotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let groupId: String?
    
    init(
        coordinate: CLLocationCoordinate2D,
        title: String,
        subtitle: String,
        groupId: String
    ) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.groupId = groupId
    }
}
