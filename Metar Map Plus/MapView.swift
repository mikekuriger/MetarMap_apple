//
//  MapView.swift
//  Metar Map Plus
//
//  Created by Kuriger, Michael on 2/21/25.
//
import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var metarService = MetarService()
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                ForEach(metarService.metars, id: \.stationId) { metar in
                    Annotation(metar.stationId, coordinate: CLLocationCoordinate2D(latitude: metar.latitude, longitude: metar.longitude)) {
                        VStack {
                            Circle()
                                .fill(flightCategoryColor(metar.flightCategory ?? "hmmm"))
                                .frame(width: 12, height: 12)
                                .overlay(Circle().stroke(Color.black, lineWidth: 1))
//                            Text(metar.flightCategory ?? "hmmm")
//                                .font(.caption)
//                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)

            // ✅ Display message outside of the MapView (so it doesn't break MapContent)
            if metarService.metars.isEmpty {
                VStack {
                    Text("No METARs Loaded")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
            }
        }
        .onAppear {
            metarService.fetchMETARs()
            print("METAR count: \(metarService.metars.count)")
            for metar in metarService.metars {
                print("✅ Adding METAR: \(metar.stationId) at (\(metar.latitude), \(metar.longitude))")
            }
        }
    }

//    func flightCategoryColor(_ category: String) -> Color {
//        switch category.uppercased() {
//        case "VFR": return .green
//        case "MVFR": return .blue
//        case "IFR": return .red
//        case "LIFR": return .purple
//        default: return .gray
//        }
//    }
    func flightCategoryColor(_ category: String?) -> Color {
        guard let category = category?.uppercased() else { return .black } // Handle nil case
        switch category {
            case "VFR": return .green
            case "MVFR": return .blue
            case "IFR": return .red
            case "LIFR": return .purple
            default: return .gray
        }
    }

}
