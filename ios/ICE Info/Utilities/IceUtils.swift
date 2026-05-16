import Foundation

func getIceClass(tzn: String) -> String {
    guard let number = Int(tzn.filter(\.isNumber)) else { return "" }

    switch number {
    case 0...199: return "ICE 1"
    case 200...399: return "ICE 2"
    case 400...599: return "ICE 3"
    case 600...799: return "ICE 3neo"
    case 800...899: return "ICE T"
    case 900...999: return "ICE 4"
    default: return "ICE"
    }
}

func getIceDrawableName(tzn: String) -> String {
    let iceClass = getIceClass(tzn: tzn)
    switch iceClass {
    case "ICE 1": return "ice1"
    case "ICE 2": return "ice2"
    case "ICE 3": return "ice3"
    case "ICE 3neo": return "ice3neo"
    case "ICE 4": return "ice4"
    case "ICE T": return "icet"
    default: return "ice"
    }
}
