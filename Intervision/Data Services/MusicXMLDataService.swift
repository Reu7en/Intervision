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
        }
        
        if !(partIds.count == partNames.count) { return nil }
        
        for i in 0..<partIds.count {
            parts.append(Part(name: partNames[i], identifier: partIds[i], bars: [[Bar]]()))
        }
        
        return parts
    }
    
    static func getBars(_ partContents: [String]) -> [[Bar]] {
        var bars: [[Bar]] = []
        
        let barData: [[String]] = extractContentsBetweenTags(partContents, startTag: "<measure number=", endTag: "</measure")
        
        var currentTempo: Bar.Tempo? = nil
        var currentClefs: [Bar.Clef] = []
        var currentTimeSignature: Bar.TimeSignature = Bar.TimeSignature.common
        var currentKeySignature: Bar.KeySignature = Bar.KeySignature.CMajor
        var clefData: [[String]] = []
        var currentStaves: Int = 1
        
        for bar in barData {
            if barData.count > 0 {
                for line in barData[0] {
                    if line.contains("<staves") {
                        let staves = Int(extractContent(fromTag: line) ?? "1") ?? 1
                        currentStaves = staves
                        break
                    }
                    
                    currentStaves = 1
                }
            }
            
            for line in bar {
                if line.contains("<metronome") {
                    let metronome = extractContentsBetweenTags(bar, startTag: "<metronome", endTag: "</metronome")
                    var time: String? = nil
                    var bpm: Int = -1
                    
                    if metronome.count > 0 {
                        for subLine in metronome[0] {
                            if subLine.contains("<beat-unit") {
                                time = extractContent(fromTag: subLine)
                            }
                            
                            if subLine.contains("<per-minute") {
                                bpm = Int(extractContent(fromTag: subLine) ?? "-1") ?? -1
                            }
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
                    
                    if key.count > 0 {
                        for subLine in key[0] {
                            if subLine.contains("<fifths") {
                                if let fifthsText = extractContent(fromTag: subLine) {
                                    fifths = Int(fifthsText)
                                }
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
            }
        }
        
        for bar in barData {
            let notes = extractContentsBetweenTags(bar, startTag: "<note", endTag: "</note")
            var currentBars: [Bar] = []
            var currentStave: Int = 1
            var currentRepeat: Bar.Repeat? = nil
            var currentVolta: Int? = nil
            var hasDoubleBarline: Bool = false
            var currentDynamics: [[Bar.Dynamic]?] = Array.init(repeating: nil, count: currentStaves)
            var changeDynamics: [(Note.ChangeDynamic, Int)] = []
            var noteCount = 0
            
            for line in bar {
                if line.contains("<clef") {
                    clefData = extractContentsBetweenTags(bar, startTag: "<clef", endTag: "</clef")
                    let measureNumber = Int(extractFirstAttributeValue(fromTag: line) ?? "-1") ?? -1
                    
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
                        
                        var pClef = Bar.Clef.Treble
                        
                        switch (sign, line) {
                        case ("G", _):
                            pClef = (Bar.Clef.Treble)
                            break
                        case ("F", _):
                            pClef = (Bar.Clef.Bass)
                            break
                        case ("C", "1"):
                            pClef = (Bar.Clef.Soprano)
                            break
                        case ("C", "3"):
                            pClef = (Bar.Clef.Alto)
                            break
                        case ("C", "4"):
                            pClef = (Bar.Clef.Tenor)
                            break
                        default:
                            pClef = (Bar.Clef.Neutral)
                            break
                        }
                        
                        if currentClefs.count < currentStaves {
                            currentClefs.append(pClef)
                        } else {
                            currentClefs[measureNumber == -1 ? 0 : measureNumber - 1] = pClef
                        }
                    }
                }
                
                if line.contains("<note") {
                    noteCount += 1
                }
                
                if line.contains("<wedge") {
                    let wedge = extractFirstAttributeValue(fromTag: line)
                    
                    switch wedge {
                    case "crescendo":
                        changeDynamics.append((.Crescendo, noteCount))
                    case "diminuendo":
                        changeDynamics.append((.Decrescendo, noteCount))
                    case "stop":
                        changeDynamics.append((.Stop, noteCount - 1))
                    default:
                        break
                    }
                }
            }
            
            for line in bar {
                if line.contains("<time") {
                    let time = extractContentsBetweenTags(bar, startTag: "<time", endTag: "</time")
                    var beats: Int = -1
                    var noteValue: Int = -1
                    
                    if time.count > 0 {
                        for subLine in time[0] {
                            if subLine.contains("<beats") {
                                beats = Int(extractContent(fromTag: subLine) ?? "-1") ?? -1
                            }
                            
                            if subLine.contains("<beat-type") {
                                noteValue = Int(extractContent(fromTag: subLine) ?? "-1") ?? -1
                            }
                        }
                    }
                    
                    if beats != -1 && noteValue != -1 {
                        currentTimeSignature = Bar.TimeSignature.custom(beats: beats, noteValue: noteValue)
                    }
                }
                
                if line.contains("<repeat") {
                    let `repeat` = extractFirstAttributeValue(fromTag: line)
                    
                    switch `repeat` {
                    case "forward":
                        currentRepeat = Bar.Repeat.RepeatStart
                        break
                    case "backward":
                        currentRepeat = Bar.Repeat.RepeatEnd
                        break
                    default:
                        break
                    }
                }
                
                if line.contains("<bar-style") {
                    let barStyle = extractContent(fromTag: line)
                    
                    if barStyle == "light-light" {
                        hasDoubleBarline = true
                    }
                }
                
                if line.contains("<ending") {
                    let ending = Int(extractFirstAttributeValue(fromTag: line) ?? "-1") ?? -1
                    
                    if ending != -1 {
                        currentVolta = ending
                    }
                }
            }
            
            for line in bar {
                if line.contains("<dynamics") {
                    var currentDynamic: Bar.Dynamic?
                    let dynamic = extractContentsBetweenTags(bar, startTag: "<dynamics", endTag: "</direction>")
                    var stave = 1
                    
                    if dynamic.count > 0 {
                        for subLine in dynamic {
                            if subLine.count > 0 {
                                switch subLine[0] {
                                case "<fff/>":
                                    currentDynamic = .Fortississimo
                                    break
                                case "<ff/>":
                                    currentDynamic = .Fortissimo
                                    break
                                case "<f/>":
                                    currentDynamic = .Forte
                                    break
                                case "<mf/>":
                                    currentDynamic = .MezzoForte
                                    break
                                case "<mp/>":
                                    currentDynamic = .MezzoPiano
                                    break
                                case "<p/>":
                                    currentDynamic = .Piano
                                    break
                                case "<pp/>":
                                    currentDynamic = .Pianissimo
                                    break
                                case "<ppp/>":
                                    currentDynamic = .Pianississimo
                                    break
                                case "<sfz/>":
                                    currentDynamic = .Sforzando
                                    break
                                default:
                                    break
                                }
                                
                                if let current = currentDynamic, currentDynamics.count > 0 {
                                    if subLine.count > 3 {
                                        stave = Int(extractContent(fromTag: subLine[3]) ?? "1") ?? 1
                                        
                                        if currentDynamics[stave - 1] == nil {
                                            currentDynamics[stave - 1] = []
                                        }
                                        
                                        currentDynamics[stave - 1]?.append(current)
                                    } else {
                                        if currentDynamics[0] == nil {
                                            currentDynamics[0] = []
                                        }
                                        
                                        currentDynamics[0]?.append(current)
                                    }
                                }
                            }
                        }
                    }
                    
                    break
                }
            }
            
            var chords: [Chord] = []
            
            for i in 0..<currentStaves {  
                currentBars.append(Bar(chords: [], tempo: currentTempo, clef: currentClefs[i], timeSignature: currentTimeSignature, repeat: currentRepeat, doubleLine: hasDoubleBarline, volta: currentVolta, keySignature: currentKeySignature, dynamics: currentDynamics[i]))
                chords.append(Chord(notes: []))
            }
            
            for (noteIndex, note) in notes.enumerated() {
                var pitch: Note.Pitch? = nil
                var accidental: Note.Accidental? = nil
                var octave: Note.Octave? = nil
                var duration: Note.Duration? = nil
                var isRest: Bool = false
                var isDotted: Bool = false
                var isMeasureRest: Bool = false
                var hasAccent: Bool = false
                var timeModification: Note.TimeModification? = nil
                var changeDynamic: Note.ChangeDynamic? = nil
                var tie: Note.Tie? = nil
                var slur: Note.Slur? = nil
                
                for change in changeDynamics {
                    if change.1 == noteIndex {
                        changeDynamic = change.0
                    }
                }
                
                for line in note {
                    if line.contains("<staff") {
                        let staff = Int(extractContent(fromTag: line) ?? "1") ?? 1
                        currentStave = staff
                    }
                }
                
                for line in note {
                    if line.contains("<rest measure=") {
                        let barRest: Note = Note(
                            duration: Note.Duration.bar,
                            isRest: true,
                            isDotted: false,
                            hasAccent: false
                        )
                        
                        if !chords[currentStave - 1].notes.isEmpty {
                            print("This shouldn't happen!")
                            currentBars[currentStave - 1].chords.append(chords[currentStave - 1])
                        }
                        
                        currentBars[currentStave - 1].chords.append(Chord(notes: [barRest]))
                        
                        isMeasureRest = true
                    }
                }
                
                if isMeasureRest {
                    continue
                }
                
                for line in note {
                    if line.contains("<dot") {
                        isDotted = true
                    }
                    
                    if line.contains("<accent") {
                        hasAccent = true
                    }
                }
                
                for line in note {
                    if line.contains("<tie") {
                        let t = extractFirstAttributeValue(fromTag: line)
                        
                        switch t {
                        case "start":
                            tie = .Start
                            break
                        case "stop":
                            tie = .Stop
                            break
                        default:
                            break
                        }
                    }
                    
                    if line.contains("<slur") {
                        let s = extractFirstAttributeValue(fromTag: line)
                        
                        switch s {
                        case "start":
                            slur = .Start
                            break
                        case "stop":
                            slur = .Stop
                            break
                        default:
                            break
                        }
                    }
                    
                    if line.contains("<type") {
                        let type = extractContent(fromTag: line)
                        
                        switch type {
                        case "breve":
                            duration = Note.Duration.breve
                            break
                        case "whole":
                            duration = Note.Duration.whole
                            break
                        case "half":
                            duration = Note.Duration.half
                            break
                        case "quarter":
                            duration = Note.Duration.quarter
                            break
                        case "eighth":
                            duration = Note.Duration.eighth
                            break
                        case "16th":
                            duration = Note.Duration.sixteenth
                            break
                        case "32nd":
                            duration = Note.Duration.thirtySecond
                            break
                        case "64th":
                            duration = Note.Duration.sixtyFourth
                            break
                        default:
                            break
                        }
                    }
                    
                    if line.contains("<time-modification") {
                        let timeMod = extractContentsBetweenTags(note, startTag: "<time-modification", endTag: "</time-modification")
                        var actual: Int = -1
                        var normal: Int = -1
                        var normalType: Note.Duration? = duration
                        
                        if timeMod.count > 0 {
                            for subLine in timeMod[0] {
                                if subLine.contains("<actual-notes") {
                                    actual = Int(extractContent(fromTag: subLine) ?? "-1") ?? -1
                                }
                                
                                if subLine.contains("<normal-notes") {
                                    normal = Int(extractContent(fromTag: subLine) ?? "-1") ?? -1
                                }
                                
                                if subLine.contains("<normal-type") {
                                    let normalTypeVerbose = extractContent(fromTag: subLine)
                                    
                                    switch normalTypeVerbose {
                                    case "breve":
                                        normalType = Note.Duration.breve
                                        break
                                    case "whole":
                                        normalType = Note.Duration.whole
                                        break
                                    case "half":
                                        normalType = Note.Duration.half
                                        break
                                    case "quarter":
                                        normalType = Note.Duration.quarter
                                        break
                                    case "eighth":
                                        normalType = Note.Duration.eighth
                                        break
                                    case "16th":
                                        normalType = Note.Duration.sixteenth
                                        break
                                    case "32nd":
                                        normalType = Note.Duration.thirtySecond
                                        break
                                    case "64th":
                                        normalType = Note.Duration.sixtyFourth
                                        break
                                    default:
                                        break
                                    }
                                }
                            }
                        }
                        
                        if actual != -1 && normal != -1 {
                            timeModification = Note.TimeModification.custom(actual: actual, normal: normal, normalDuration: normalType ?? .bar)
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
                
                var pNote: Note? = nil
                
                if let d = duration {
                    pNote = Note(
                        pitch: pitch,
                        accidental: accidental,
                        octave: octave,
                        duration: d,
                        timeModification: timeModification,
                        changeDynamic: changeDynamic,
                        graceNotes: nil,
                        tie: tie,
                        slur: slur,
                        isRest: isRest,
                        isDotted: isDotted,
                        hasAccent: hasAccent
                    )
                }
                
                var chordTag: Bool = false
                
                for line in note {
                    if line.contains("<chord") {
                        chordTag = true
                    }
                }
                
                if let n = pNote {
                    if n.isRest || (!n.isRest && n.pitch != nil && n.octave != nil) {
                        if chordTag {
                            chords[currentStave - 1].notes.append(n)
                        } else {
                            if !chords[currentStave - 1].notes.isEmpty {
                                currentBars[currentStave - 1].chords.append(chords[currentStave - 1])
                            }
                            
                            chords[currentStave - 1] = Chord(notes: [])
                            chords[currentStave - 1].notes.append(n)
                        }
                    }
                }
            }
            
            for i in 0..<currentStaves {
                if !chords[i].notes.isEmpty {
                    currentBars[i].chords.append(chords[i])
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
    
    static func readXML(_ filePath: String, completion: @escaping (Score?) -> Void) {
        DispatchQueue.global().async {
            guard let content = readFile(filePath) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                
                return
            }
            
            let lines = getLines(content)
            
            guard isPartwise(lines) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                
                return
            }
            
            let title: String? = getTitle(lines)
            let composer: String? = getComposer(lines)
            var partData: [Part]? = getParts(lines)
            let partContents = extractContentsBetweenTags(lines, startTag: "<part id=", endTag: "</part")
            
            if !(partContents.isEmpty) {
                for i in 0..<(partData?.count ?? 0) {
                    let bars: [[Bar]] = getBars(partContents[i])
                    partData?[i].bars = bars
                }
            }
            
            let score = Score(title: title, composer: composer, parts: partData)
            score.parts = purgePercussion(parts: score.parts)
            
            DispatchQueue.main.async {
                completion(score)
            }
        }
    }

    static func purgePercussion(parts: [Part]?) -> [Part]? {
        if let oldParts = parts {
            var newParts: [Part] = []
            
            for part in oldParts {
                if part.bars.count > 0 && part.bars[0].first?.clef == .Neutral {
                    continue
                } else {
                    newParts.append(part)
                }
            }
            
            return newParts
        } else {
            return parts
        }
    }
}
