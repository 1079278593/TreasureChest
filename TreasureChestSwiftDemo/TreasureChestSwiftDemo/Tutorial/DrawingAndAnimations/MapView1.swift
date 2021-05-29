//
//  MapView.swift
//  TreasureChestSwiftDemo
//
//  Created by ming on 2021/5/6.
//  Copyright © 2021 xiao ming. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView1: View {
    /**
     深圳：东经113°46′至114°37′，北纬22°24′至22°52′之间
     */
    let someLocation = CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868)
    let coordShenZhen = CLLocationCoordinate2DMake(22.24, 113.46)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )

    var body: some View {
        if #available(iOS 14.0, *) {
            VStack {
                Map(coordinateRegion: $region)
//                Button(action: changePlace, label: {
//                    Text("Button")
//                })
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    private func changePlace() {
        region = MKCoordinateRegion(
            center: self.coordShenZhen,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            )
    }
}

struct MapView1_Previews: PreviewProvider {
    static var previews: some View {
        MapView1()
    }
}
