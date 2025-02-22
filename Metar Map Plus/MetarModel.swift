//
//  MetarModel.swift
//  Metar Map Plus
//
//  Created by Kuriger, Michael on 2/21/25.
//
import Foundation

// METAR Model
struct METAR: Identifiable, Codable {
    let id: UUID
    let stationId: String
    let observationTime: String
    let latitude: Double
    let longitude: Double
    let tempC: Double?
    let dewpointC: Double?
    let windDirDegrees: Int?
    let windSpeedKt: Int?
    let windGustKt: Int?
    let visibility: String?
    let altimeterInHg: Double?
    let skyCover1: String?
    let cloudBase1: Int?
    let flightCategory: String?

    // ✅ Custom initializer to assign a UUID automatically for new METARs
    init(
        stationId: String,
        observationTime: String,
        latitude: Double,
        longitude: Double,
        tempC: Double? = nil,
        dewpointC: Double? = nil,
        windDirDegrees: Int? = nil,
        windSpeedKt: Int? = nil,
        windGustKt: Int? = nil,
        visibility: String? = nil,
        altimeterInHg: Double? = nil,
        skyCover1: String? = nil,
        cloudBase1: Int? = nil,
        flightCategory: String? = nil
    ) {
        self.id = UUID() // ✅ This assigns a new UUID only for newly created METARs
        self.stationId = stationId
        self.observationTime = observationTime
        self.latitude = latitude
        self.longitude = longitude
        self.tempC = tempC
        self.dewpointC = dewpointC
        self.windDirDegrees = windDirDegrees
        self.windSpeedKt = windSpeedKt
        self.windGustKt = windGustKt
        self.visibility = visibility
        self.altimeterInHg = altimeterInHg
        self.skyCover1 = skyCover1
        self.cloudBase1 = cloudBase1
        self.flightCategory = flightCategory
    }
}


