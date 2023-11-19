//
//  MapView.swift
//  Card Tracker
//
//  Created by Joseph Wardell on 1/1/22.
//  Copyright © 2022 Michael Rowe. All rights reserved.
//

import SwiftUI
import MapKit

/// a very simple view that just presents a  Map given a MKCoordinateRegion
struct MapView: View {

    struct Place: Identifiable {
        let id = UUID()
        let name: String
        var latitude: Double
        var longitude: Double
        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    @State private var region: MKCoordinateRegion
    var places = [
        Place(name: "", latitude: 0.0, longitude: 0.0  )
    ]
    
    init(region: MKCoordinateRegion) {
        self.region = region
        self.region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.1), longitudeDelta: CLLocationDegrees(0.1))
        places[0].longitude = region.center.longitude
        places[0].latitude = region.center.latitude
    }

    var body: some View {
        Map  {
            Annotation (
                "\(places[0].name)",
                coordinate: places[0].coordinate,
                anchor: .bottom
            ) {
                Image(systemName: "house")
                    .padding(4)
                    .foregroundStyle(.white)
                    .background(Color.green)
                    .cornerRadius(4)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .onMapCameraChange { context in
            region = context.region
        }
    }
}
