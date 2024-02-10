//
//  MusicXMLDataService.swift
//  Intervision
//
//  Created by Reuben on 09/02/2024.
//

import Foundation

struct MusicXMLDataService {
    static func readFile(_ filePath: String) -> String? {
        guard let file = FileManager.default.contents(atPath: filePath),
              let contentString = String(data: file, encoding: .utf8) else {
            return nil
        }
        
        return contentString
    }
    
    static func getLines(_ contentString: String) -> [String] {
        let lines = contentString.components(separatedBy: "\n")
        
        let trimmedLines = lines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        return trimmedLines
    }
    
    static func isPartwise(_ lines: [String]) -> Bool {
        for line in lines {
            if line.contains("<score-partwise") {
                return true
            } else if line.contains("<score-timewise") {
                return false
            }
        }
        
        return false
    }
    
    static func getTitle(_ lines: [String]) -> String? {
        for line in lines {
            if line.contains("<work-title") {
                return extractContent(fromTag: line)
            }
        }
        
        return nil
    }
    
    static func getComposer(_ lines: [String]) -> String? {
        for line in lines {
            if line.contains("<creator type=\"composer\"") {
                return extractContent(fromTag: line)
            }
        }
        
        return nil
    }
    
    static func getParts(_ lines: [String]) -> [Part]? {
        var parts: [Part] = [Part]()
        var partIds: [String] = [String]()
        var partNames: [String] = [String]()
        var partAbbreviations: [String] = [String]()
        
        for line in lines {
            if line.contains("<score-part id") {
                if let id = extractFirstAttributeValue(fromTag: line) {
                    partIds.append(id)
                }
            }
            
            if line.contains("<part-name") {
                if let name = extractContent(fromTag: line) {
                    partNames.append(name)
                }
            }
            
            if line.contains("<part-abbreviation") {
                if let abbreviation = extractContent(fromTag: line) {
                    partAbbreviations.append(abbreviation)
                }
            }
        }
        
        if !(partIds.count == partNames.count && partNames.count == partAbbreviations.count) { return nil }
        
        for i in 0..<partIds.count {
            parts.append(Part(name: partNames[i], abbreviation: partAbbreviations[i], identifier: partIds[i], bars: [[Bar]]()))
        }
        
        return parts
    }
    
    static func getBars(_ partContents: [String]) -> [[Bar]] {
        var bars: [[Bar]] = []
        
        let barData: [[String]] = extractContentsBetweenTags(partContents, startTag: "<measure number=", endTag: "</measure")
        
        var currentTempo: Bar.Tempo = Bar.Tempo.quarter(bpm: 0)
        var currentClefs: [Bar.Clef] = []
        var currentTimeSignature: Bar.TimeSignature = Bar.TimeSignature.common
        var currentKeySignature: Bar.KeySignature = Bar.KeySignature.CMajor
        
        var clefData: [[String]] = []
        var currentStaves: Int = 1
        var currentDivisons: Int? = nil
        
        for bar in barData {
            for line in bar {
                if line.contains("<time") {
                    let time = extractContentsBetweenTags(bar, startTag: "<time", endTag: "</time")
                    var beats: Int = -1
                    var noteValue: Int = -1
                    
                    for subLine in time[0] {
                        if subLine.contains("<beats") {
                            beats = Int(extractContent(fromTag: subLine) ?? "-1") ?? -1
                        }
                        
                        if subLine.contains("<beat-type") {
                            noteValue = Int(extractContent(fromTag: subLine) ?? "-1") ?? -1
                        }
                    }
                    
                    if beats != -1 && noteValue != -1 {
                        currentTimeSignature = Bar.TimeSignature.custom(beats: beats, noteValue: noteValue)
                    }
                }
                
                if line.contains("<metronome") {
                    let metronome = extractContentsBetweenTags(bar, startTag: "<metronome", endTag: "</metronome")
                    var time: String? = nil
                    var bpm: Int = -1
                    
                    for subLine in metronome[0] {
                        if subLine.contains("<beat-unit") {
                            time = extractContent(fromTag: subLine)
                        }
                        
                        if subLine.contains("<per-minute") {
                            bpm = Int(extractContent(fromTag: subLine) ?? "-1") ?? -1
                        }
                    }
                    
                    if time != nil && bpm != -1 {
                        switch time {
                        case "half":
                            currentTempo = Bar.Tempo.half(bpm: bpm)
                            break
                        case "quarter":
                            currentTempo = Bar.Tempo.quarter(bpm: bpm)
                            break
                        case "eighth":
                            currentTempo = Bar.Tempo.eighth(bpm: bpm)
                            break
                        default:
                            break
                        }
                    }
                }
                
                if (line.contains("<key")) {
                    let key = extractContentsBetweenTags(bar, startTag: "<key", endTag: "</key")
                    var fifths: Int? = nil
                    
                    for subLine in key[0] {
                        if subLine.contains("<fifths") {
                            if let fifthsText = extractContent(fromTag: subLine) {
                                fifths = Int(fifthsText)
                            }
                        }
                    }
                    
                    if fifths != nil {
                        switch fifths {
                        case -7:
                            currentKeySignature = Bar.KeySignature.CFlatMajor
                            break
                        case -6:
                            currentKeySignature = Bar.KeySignature.GFlatMajor
                            break
                        case -5:
                            currentKeySignature = Bar.KeySignature.DFlatMajor
                            break
                        case -4:
                            currentKeySignature = Bar.KeySignature.AFlatMajor
                            break
                        case -3:
                            currentKeySignature = Bar.KeySignature.EFlatMajor
                            break
                        case -2:
                            currentKeySignature = Bar.KeySignature.BFlatMajor
                            break
                        case -1:
                            currentKeySignature = Bar.KeySignature.FMajor
                            break
                        case 0:
                            currentKeySignature = Bar.KeySignature.CMajor
                            break
                        case 1:
                            currentKeySignature = Bar.KeySignature.GMajor
                            break
                        case 2:
                            currentKeySignature = Bar.KeySignature.DMajor
                            break
                        case 3:
                            currentKeySignature = Bar.KeySignature.AMajor
                            break
                        case 4:
                            currentKeySignature = Bar.KeySignature.EMajor
                            break
                        case 5:
                            currentKeySignature = Bar.KeySignature.BMajor
                            break
                        case 6:
                            currentKeySignature = Bar.KeySignature.FSharpMajor
                            break
                        case 7:
                            currentKeySignature = Bar.KeySignature.CSharpMajor
                            break
                        default:
                            break
                        }
                    }
                }
                
                if line.contains("<clef") {
                    clefData = extractContentsBetweenTags(bar, startTag: "<clef", endTag: "</clef")
                }
            }
            
            var clefs: [Bar.Clef] = []
            
            for clef in clefData {
                var sign: String? = nil
                var line: String? = nil
                
                for subLine in clef {
                    if subLine.contains("<sign") {
                        sign = extractContent(fromTag: subLine)
                    }
                    
                    if subLine.contains("<line") {
                        line = extractContent(fromTag: subLine)
                    }
                }
                
                if sign != nil && line != nil {
                    if sign == "G" && line == "2" {
                        clefs.append(Bar.Clef.Treble)
                    } else if sign == "F" && line == "4" {
                        clefs.append(Bar.Clef.Bass)
                    }
                }
            }
            
            if !clefs.isEmpty {
                currentClefs = clefs
            }
        }
        
        for line in barData[0] {
            if line.contains("<staves") {
                let staves = Int(extractContent(fromTag: line) ?? "1") ?? 1
                currentStaves = staves
                break
            }
            
            currentStaves = 1
        }
        
        for line in barData[0] {
            if line.contains("<divisions") {
                let div = Int(extractContent(fromTag: line) ?? "-1") ?? -1
                
                if div != -1 {
                    currentDivisons = div
                }
            }
        }
        
        for bar in barData {
            let notes = extractContentsBetweenTags(bar, startTag: "<note", endTag: "</note")
            var currentBars: [Bar] = []
            var currentStave: Int = 1
            
            for i in 0..<currentStaves {
                currentBars.append(Bar(chords: [], tempo: currentTempo, clef: currentClefs[i], timeSignature: currentTimeSignature, repeat: Bar.Repeat.None, doubleLine: false, volta: nil, keySignature: currentKeySignature))
            }
            
            var chord: Chord = Chord(notes: [])
            
            for note in notes {
                var pitch: Note.Pitch? = nil
                var accidental: Note.Accidental? = nil
                var octave: Note.Octave? = nil
                var duration: Note.Duration? = nil
                var isRest: Bool = false
                var isDotted: Bool = false
                var isMeasureRest: Bool = false
                
                for line in note {
                    if line.contains("<rest measure=") {
                        chord.notes.append(Note(duration: Note.Duration.bar, isRest: true, isDotted: false, hasAccent: false))
                        currentBars[currentStave - 1].chords.append(chord)
                        chord = Chord(notes: [])
                        isMeasureRest = true
                    }
                }
                
                if isMeasureRest {
                    continue
                }
                
                for line in note {
                    if line.contains("<staff") {
                        let staff = Int(extractContent(fromTag: line) ?? "1") ?? 1
                        currentStave = staff
                    }
                    
                    if line.contains("<dot") {
                        isDotted = true
                    }
                }
                
                for line in note {
                    if line.contains("<duration") {
                        let dur = Int(extractContent(fromTag: line) ?? "-1") ?? -1
                        var factor: Double = -1
                        
                        if let div = currentDivisons {
                            if dur != -1 && div != -1 {
                                factor = Double(dur) / Double(div)
                                
                                if isDotted {
                                    factor /= 1.5
                                }
                            }
                        }
                        
                        switch factor {
                        case 4:
                            duration = Note.Duration.whole
                            break
                        case 2:
                            duration = Note.Duration.half
                            break
                        case 1:
                            duration = Note.Duration.quarter
                            break
                        case 0.5:
                            duration = Note.Duration.eighth
                            break
                        case 0.25:
                            duration = Note.Duration.sixteenth
                            break
                        case 0.125:
                            duration = Note.Duration.thirtySecond
                            break
                        case 0.0625:
                            duration = Note.Duration.sixtyFourth
                            break
                        case -1:
                            break
                        default:
                            break
                        }
                    }
                    
                    if line.contains("<rest/") {
                        isRest = true
                    }
                    
                    if line.contains("<step") {
                        let step = extractContent(fromTag: line)
                        
                        switch step {
                        case "C":
                            pitch = Note.Pitch.C
                            break
                        case "D":
                            pitch = Note.Pitch.D
                            break
                        case "E":
                            pitch = Note.Pitch.E
                            break
                        case "F":
                            pitch = Note.Pitch.F
                            break
                        case "G":
                            pitch = Note.Pitch.G
                            break
                        case "A":
                            pitch = Note.Pitch.A
                            break
                        case "B":
                            pitch = Note.Pitch.B
                            break
                        default:
                            break
                        }
                    }
                    
                    if line.contains("<octave") {
                        let o = extractContent(fromTag: line)
                        
                        switch o {
                        case "0":
                            octave = Note.Octave.subContra
                            break
                        case "1":
                            octave = Note.Octave.contra
                            break
                        case "2":
                            octave = Note.Octave.great
                            break
                        case "3":
                            octave = Note.Octave.small
                            break
                        case "4":
                            octave = Note.Octave.oneLine
                            break
                        case "5":
                            octave = Note.Octave.twoLine
                            break
                        case "6":
                            octave = Note.Octave.threeLine
                            break
                        case "7":
                            octave = Note.Octave.fourLine
                            break
                        case "8":
                            octave = Note.Octave.fiveLine
                            break
                        default:
                            break
                        }
                    }
                    
                    if line.contains("<alter") {
                        let alter = Int(extractContent(fromTag: line) ?? "0") ?? 0
                        
                        switch alter {
                        case -2:
                            accidental = Note.Accidental.DoubleFlat
                            break
                        case -1:
                            accidental = Note.Accidental.Flat;
                            break
                        case 1:
                            accidental = Note.Accidental.Sharp;
                            break
                        case 2:
                            accidental = Note.Accidental.DoubleSharp;
                            break
                        default:
                            break
                        }
                    }
                    
                    if line.contains("<accidental") {
                        let acc = extractContent(fromTag: line)
                        
                        switch acc {
                        case "flat-flat":
                            accidental = Note.Accidental.DoubleFlat
                            break
                        case "flat":
                            accidental = Note.Accidental.Flat
                            break
                        case "natural":
                            accidental = Note.Accidental.Natural
                            break
                        case "sharp":
                            accidental = Note.Accidental.Sharp
                            break
                        case "double-sharp":
                            accidental = Note.Accidental.DoubleSharp
                            break
                        default:
                            break
                        }
                    }
                }
                
                if isRest {
                    if let d = duration {
                        chord.notes.append(Note(duration: d, isRest: true, isDotted: isDotted, hasAccent: false))
                        currentBars[currentStave - 1].chords.append(chord)
                        chord = Chord(notes: [])
                    }
                } else if !isRest && pitch != nil && octave != nil {
                    if let d = duration {
                        chord.notes.append(Note(pitch: pitch, accidental: accidental, octave: octave, duration: d, dynamic: nil, graceNotes: nil, isRest: false, isDotted: isDotted, hasAccent: false))
                    }
                }
                 
                for line in note {
                    if !line.contains("<chord") {
                        if !chord.notes.isEmpty {
                            currentBars[currentStave - 1].chords.append(chord)
                        }
                        
                        chord = Chord(notes: [])
                    }
                }
            }
            
            bars.append(currentBars)
        }
        
        return bars
    }
    
    static func extractContentsBetweenTags(_ lines: [String], startTag: String, endTag: String) -> [[String]] {
        var extractedContents: [[String]] = []
        var currentContents: [String] = []
        var isInsideTag: Bool = false

        for line in lines {
            if line.contains(startTag) {
                isInsideTag = true
                currentContents = []
                continue
            }

            if line.contains(endTag) {
                if isInsideTag {
                    extractedContents.append(currentContents)
                    isInsideTag = false
                }
                continue
            }

            if isInsideTag {
                currentContents.append(line)
            }
        }

        return extractedContents
    }
    
    static func extractContent(fromTag tagString: String) -> String? {
        guard let startRange = tagString.range(of: ">"),
              let endRange = tagString.range(of: "</", options: .backwards, range: startRange.upperBound..<tagString.endIndex) else {
            return nil
        }
        
        let content = String(tagString[startRange.upperBound..<endRange.lowerBound])
        return content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    static func extractFirstAttributeValue(fromTag tagString: String) -> String? {
        let pattern = #"(?<=\=")[^"]*(?=")"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: tagString, options: [], range: NSRange(location: 0, length: tagString.utf16.count)),
              let range = Range(match.range, in: tagString) else {
            return nil
        }
        
        return String(tagString[range])
    }
    
    static func readXML(_ filePath: String) -> Score? {
        guard let content = readFile(filePath) else { return nil }
        let lines = getLines(content)
        
        if !isPartwise(lines) { return nil }
        let title: String? = getTitle(lines)
        let composer: String? = getComposer(lines)
        var partData: [Part]? = getParts(lines)
        let partContents = extractContentsBetweenTags(lines, startTag: "<part id=", endTag: "</part")
        
        for i in 0..<(partData?.count ?? 0) {
            let bars: [[Bar]] = getBars(partContents[i])
            partData?[i].bars = bars
        }
        
        var score: Score = Score(title: title, composer: composer, parts: partData)
        
        return score
    }
}
