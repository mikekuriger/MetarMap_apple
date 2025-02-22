//
//  MetarService.swift
//  Metar Map Plus
//
//  Created by Kuriger, Michael on 2/21/25.
//
import Foundation
import zlib

class MetarService: ObservableObject {
    @Published var metars: [METAR] = []
    
    func fetchMETARs() {
        let metarURL = URL(string: "https://aviationweather.gov/data/cache/metars.cache.csv.gz")!
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("metars.cache.csv")
        
        let task = URLSession.shared.dataTask(with: metarURL) { data, response, error in
            guard let compressedData = data, error == nil else {
                print("METAR Download Error:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if let decompressedData = self.decompressGzip(data: compressedData) {
                do {
                    try decompressedData.write(to: destinationURL)
                    DispatchQueue.main.async {
                        self.metars = self.parseMetarCsv(fileURL: destinationURL)
                    }
                } catch {
                    print("METAR Parsing Error:", error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    // Decompress GZIP Data
    private func decompressGzip(data: Data) -> Data? {
        guard !data.isEmpty else { return nil }
        var stream = z_stream()
        var status: Int32
        
        status = inflateInit2_(&stream, 16 + MAX_WBITS, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { return nil }
        
        var decompressedData = Data()
        let bufferSize = 4096
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        
        data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            stream.next_in = UnsafeMutablePointer<UInt8>(mutating: bytes.bindMemory(to: UInt8.self).baseAddress!)
            stream.avail_in = uInt(data.count)
        }
        
        repeat {
            let count = buffer.count
            buffer.withUnsafeMutableBytes { (outputPointer: UnsafeMutableRawBufferPointer) in
                stream.next_out = outputPointer.bindMemory(to: UInt8.self).baseAddress!
                stream.avail_out = uInt(count)
                
                status = inflate(&stream, Z_SYNC_FLUSH)
                if status == Z_STREAM_END || status == Z_OK {
                    let decompressedSize = count - Int(stream.avail_out)
                    decompressedData.append(outputPointer.bindMemory(to: UInt8.self).baseAddress!, count: decompressedSize)
                }
            }
        } while status == Z_OK && stream.avail_out == 0
        
        inflateEnd(&stream)
        return decompressedData
    }
    
    // Parse METAR CSV
    private func parseMetarCsv(fileURL: URL) -> [METAR] {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            print("❌ Failed to read METAR CSV file from \(fileURL.path)")
            return []
        }

        let lines = content.split(separator: "\n").dropFirst()
        print("✅ METAR CSV loaded, total lines: \(lines.count)")

        if lines.isEmpty {
            print("❌ No METAR data found in file")
            return []
        }

        print("🔹 First 5 lines of CSV:")
        for line in lines.prefix(5) {
            print(line)
        }

        var metars: [METAR] = []

        for line in lines {
            //let fields = line.split(separator: ",").map { String($0) }
            let fields = line.split(separator: ",", omittingEmptySubsequences: false).map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }

            if fields.count < 43 {  // Ensure minimum required fields exist
                print(fields.count, " - ⚠️ Skipping malformed line (critical fields missing): \(line)")
                continue
            }
            
            
            // ✅ Only process airports that start with "K"
            if !fields[1].hasPrefix("K") {
                continue
            }

            // Safely extract values, using `nil` or defaults for missing data
            let metar = METAR(
                stationId: fields.getOrNil(1) ?? "UNKNOWN",
                observationTime: fields.getOrNil(2) ?? "UNKNOWN",
                latitude: Double(fields.getOrNil(3) ?? "0.0") ?? 0.0,
                longitude: Double(fields.getOrNil(4) ?? "0.0") ?? 0.0,
                tempC: Double(fields.getOrNil(5) ?? ""),
                dewpointC: Double(fields.getOrNil(6) ?? ""),
                windDirDegrees: Int(fields.getOrNil(7) ?? ""),
                windSpeedKt: Int(fields.getOrNil(8) ?? ""),
                windGustKt: Int(fields.getOrNil(9) ?? ""),
                visibility: fields.getOrNil(10) ?? "N/A",
                altimeterInHg: Double(fields.getOrNil(11) ?? ""),
                skyCover1: fields.getOrNil(22),
                cloudBase1: fields.getOrNil(23)?.toInt(),
                flightCategory: fields.getOrNil(30) ?? "UNKNOWN"
            )


            metars.append(metar)
        }

        print("✅ Successfully parsed \(metars.count) METARs")
        if let firstMetar = metars.first {
            print("🔹 Sample METAR: \(firstMetar.stationId), Lat: \(firstMetar.latitude), Lon: \(firstMetar.longitude)")
        }

        return metars
    }

}

// Helper functions
//extension Array {
//    func getOrNil(_ index: Int) -> String? {
//        return index < self.count ? self[index] as? String : nil
//    }
//}

extension Array where Element == String {
    func getOrNil(_ index: Int) -> String? {
        guard index < self.count else { return nil }
        let value = self[index].trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value  // ✅ Convert empty strings to `nil`
    }
}


extension String {
    func toInt() -> Int? {
        return Int(self)
    }
}
