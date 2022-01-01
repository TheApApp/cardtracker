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

    @State private var region: MKCoordinateRegion

    init(region: MKCoordinateRegion) {
        self.region = region
    }

    var body: some View {
        Map(coordinateRegion: $region)
    }
}
