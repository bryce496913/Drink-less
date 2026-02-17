import Foundation

struct TipService {
    let tips: [String]

    init() {
        let url = Bundle.main.url(forResource: "tips", withExtension: "json")
        let data = (try? Data(contentsOf: url ?? URL(fileURLWithPath: ""))) ?? Data("[]".utf8)
        tips = (try? JSONDecoder().decode([String].self, from: data)) ?? ["Take a short pause before each drink to check in with your intention."]
    }

    func tip(for date: Date) -> String {
        guard !tips.isEmpty else { return "" }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
        return tips[day % tips.count]
    }
}
