import Foundation

struct Day {
    let date: Date
    var state: State
}

struct State {
    var isSelected: Bool
    let isCurrent: Bool
    let isPast: Bool
}
