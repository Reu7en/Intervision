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
            if let score = MusicXMLDataService.readXML(filePath) {
                print("Success!")
                print(score)
                
//                var piano: Part? = nil
//                
//                if let parts = score.parts {
//                    for part in parts {
//                        if let name = part.name {
//                            if name == "Piano" {
//                                piano = part
//                            }
//                        }
//                    }
//                }
//                
//                if let p = piano {
//                    print(p.bars.count)
//                    print(p.bars[0][0])
//                    print(p.bars[1][0])
//                    print(p.bars[1][0])
//                    print(p.bars[1][1])
//                }
            }
        } else {
            print("File not found")
        }
    }
}
