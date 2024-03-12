//
//  TestLoad.swift
//  Intervision
//
//  Created by Reuben on 09/02/2024.
//

import Foundation

struct TestLoad {
    static func testLoad() {
        if let filePath = Bundle.main.path(forResource: "Simpsons_MultiPart", ofType: "musicxml") {
            MusicXMLDataService.readXML(filePath) { score in
                
            }
        } else {
            print("File not found")
        }
    }
}
