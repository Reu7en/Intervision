//
//  TestLoad.swift
//  Intervision
//
//  Created by Reuben on 09/02/2024.
//

import Foundation

struct TestLoad {
    static func testLoad() {
        if let filePath = Bundle.main.path(forResource: "ShortTestScore", ofType: "musicxml") {
            if let score = MusicXMLDataService.readXML(filePath) {
                print("Success!")
                print(score.title)
                print(score.composer)
                print(score.parts?.count)
                print(score.parts)
            }
        } else {
            print("File not found")
        }
    }
}
