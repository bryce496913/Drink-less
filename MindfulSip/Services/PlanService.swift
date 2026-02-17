import Foundation

struct PlanService {
    let dateService = DateService()

    func autoPickDryDays(count: Int, avoidWeekend: Bool) -> Set<Int> {
        guard count > 0 else { return [] }
        var candidates = Array(0..<7)
        if avoidWeekend {
            candidates = [0, 1, 2, 3, 4] + [5, 6]
        }
        let step = Double(7) / Double(count)
        var chosen = Set<Int>()
        for i in 0..<count {
            var idx = Int(round(Double(i) * step)) % 7
            while chosen.contains(candidates[idx % candidates.count]) { idx = (idx + 1) % 7 }
            chosen.insert(candidates[idx % candidates.count])
        }
        return chosen
    }

    func distributeTarget(weeklyTarget: Int, dryDayIndexes: Set<Int>) -> [Double] {
        var result = Array(repeating: 0.0, count: 7)
        let active = (0..<7).filter { !dryDayIndexes.contains($0) }
        guard !active.isEmpty else { return result }
        let even = weeklyTarget / active.count
        var remainder = weeklyTarget % active.count
        for idx in active {
            result[idx] = Double(even + (remainder > 0 ? 1 : 0))
            remainder -= 1
        }
        return result
    }
}
