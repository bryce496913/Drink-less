import SwiftUI

struct GuidanceView: View {
    @EnvironmentObject var container: AppContainer

    @State private var showDailySupport = false
    @State private var showAdvice = false
    @State private var showPraise = false
    @State private var showRecommendation = false

    private let dailySupportMessages: [String] = [
        "Today is a fresh start. Whatever happened yesterday or earlier this week, you can make one choice right now that supports the version of yourself you want to become.",
        "Reducing alcohol is not about being perfect. It is about paying attention, learning your patterns, and making more intentional decisions one day at a time.",
        "Even a small pause before your first drink is progress. That moment of awareness helps build control, and control grows stronger with practice.",
        "You do not need to figure out the whole week today. Focus on this moment, this evening, or the next hour, and let small wins carry you forward.",
        "Some days will feel easier than others. A difficult day does not mean you are failing — it means you are doing something that takes real effort and honesty.",
        "Your goal is allowed to matter, even if no one else sees the work behind it. Every mindful choice you make is a quiet investment in your health and peace of mind.",
        "Cravings, habits, and routines can feel powerful, but they are temporary. Give yourself a little time, a little space, and a little kindness before reacting automatically.",
        "Progress often looks ordinary from the outside. Choosing one less drink, delaying a decision, or checking in with yourself all count more than you think.",
        "You are building trust with yourself. Each time you follow through, even in a small way, you strengthen the belief that you can do hard things.",
        "There is no need to shame yourself into changing. Support, honesty, and patience will take you further than guilt ever will.",
        "A better relationship with alcohol starts with awareness, not pressure. Noticing what you want, what you feel, and what you need is meaningful progress.",
        "If today feels messy, keep going anyway. Growth is rarely neat, and one imperfect day does not cancel out the effort you have already made.",
        "You are allowed to protect your energy today. Saying no, leaving early, drinking slowly, or choosing not to drink at all are all valid ways to care for yourself.",
        "It helps to remember that urges rise and fall like waves. You do not have to obey every impulse — sometimes you only need to outlast it.",
        "Your goals deserve support from your daily choices. Keep it simple today: drink water, eat something nourishing, and check in with how you actually feel.",
        "You are not behind. Change happens through repetition, reflection, and small decisions that add up over time.",
        "This is a practice, not a test. There is nothing to pass or fail today — only a chance to learn more about what helps you feel your best.",
        "Choosing moderation or a break can be an act of self-respect. It means you are listening to yourself instead of drifting on autopilot.",
        "No matter how this week has gone, today still gives you room to reset. One grounded choice can shift the rest of your day in a better direction.",
        "You are doing more than tracking numbers. You are building awareness, resilience, and a healthier relationship with yourself, and that matters."
    ]

    private let adviceMessages: [String] = [
        "Before having a drink, pause and ask yourself what you want from it. If the answer is relief, comfort, or escape, there may be another way to support yourself first.",
        "Try slowing the pace of your drinking by adding a full glass of water between drinks. This creates space, helps you stay aware, and often changes the night more than expected.",
        "If evenings are your hardest time, plan them on purpose. A meal, a walk, a show, a workout, or an early bedtime can reduce the chance of drinking out of habit.",
        "Set a clear number before the first drink rather than deciding as you go. A goal made in advance is easier to follow than one made in the middle of the moment.",
        "If you usually drink while stressed, create a short replacement ritual. Tea, sparkling water, a shower, music, or ten minutes away from your phone can interrupt the pattern.",
        "Pay attention to the situations that make drinking feel automatic. Once you identify the trigger, you have a much better chance of choosing your response.",
        "Eating before or while drinking can make a big difference. Hunger lowers your resistance and can lead to decisions that do not match your goals.",
        "Keep alcohol a little less convenient. Not stocking as much at home can make mindful choices easier and impulsive choices harder.",
        "Practice a simple phrase for social settings, like “I’m taking it easy tonight” or “I’m good for now.” Having the words ready reduces pressure in the moment.",
        "If your goal feels too big, shrink it. Aim for one fewer drink, one alcohol-free night, or one delayed decision instead of trying to change everything at once.",
        "Notice the first moment you start negotiating with yourself. That is often the best time to step back, reset, and return to the plan you made earlier.",
        "Try tracking how you feel the next morning after lighter drinking days. Better sleep, clearer thinking, and steadier energy can become powerful motivation.",
        "Make your first drink later than usual. Even a delay of thirty to sixty minutes can reduce the total amount you drink without feeling like a major sacrifice.",
        "Build in rewards that are not alcohol-related. Good food, a movie, a coffee outing, or saving money toward something meaningful can reinforce your progress.",
        "If weekends are harder, decide on your boundaries before they begin. A loose plan often disappears under social pressure, while a specific one is easier to keep.",
        "Watch out for all-or-nothing thinking. If you go over your target once, that is a signal to reset — not a reason to give up for the rest of the day or week.",
        "Let someone you trust know what you are working on. Support does not have to be dramatic; even one person knowing your goal can help you stay grounded.",
        "Replace the habit, not just the drink. If alcohol is tied to relaxing, celebrating, or unwinding, it helps to create new versions of those same moments.",
        "Keep your reason visible. Whether it is better sleep, better health, saving money, or feeling more in control, reminding yourself why can strengthen your choices.",
        "Be honest about what “just one more” usually leads to. Clarity about your own patterns is one of the most useful tools you can have."
    ]

    private let praiseMessages: [String] = [
        "You checked in today, and that matters. Self-awareness is not always easy, and showing up for yourself is a meaningful step.",
        "Tracking your drinks takes honesty. That honesty is a strength, because real change starts when you are willing to see things clearly.",
        "Every mindful choice you make deserves credit. Even if it seems small, it reflects effort, intention, and growth.",
        "Taking a break or cutting back is not easy in a world that often normalizes overdrinking. Choosing a different path shows courage and self-respect.",
        "You are doing important work, even on the quiet days. Progress is often built through small, steady decisions that no one else sees.",
        "It is worth noticing how much intention you are bringing to this. You are not just reacting — you are learning, adjusting, and trying again.",
        "Giving attention to your habits is a powerful act of self-care. It shows that your well-being is worth protecting.",
        "You have already done something positive by reflecting on today. Awareness may seem simple, but it is one of the strongest foundations for change.",
        "It takes discipline to pause and be honest with yourself. That kind of self-leadership will help you far beyond this one goal.",
        "If today went better than expected, take that in. Let yourself feel proud of the choices you made and the control you practiced.",
        "If today was difficult and you still came back to track it, that is still a win. Accountability in hard moments is a real sign of strength.",
        "You are proving that change does not require perfection. It requires consistency, honesty, and the willingness to keep showing up.",
        "Reducing your drinking is not just about saying no. It is about saying yes to clarity, health, energy, and a life that feels more intentional.",
        "Each time you follow your goal, you strengthen your confidence. The more evidence you give yourself, the easier it becomes to trust your own choices.",
        "You are building momentum, whether it feels dramatic or not. Healthy change often begins quietly and grows through repetition.",
        "It is admirable that you are paying attention to your week as a whole, not just one moment. That bigger-picture thinking helps create lasting progress.",
        "Choosing to reflect instead of avoid is something to be proud of. It shows maturity, courage, and a genuine commitment to yourself.",
        "You are making space for better habits, and that takes effort. Give yourself credit for the work you are doing beneath the surface.",
        "Every drink you skip, delay, or replace is evidence that you are capable of change. That capability is already in you.",
        "No matter where you are in the process, you deserve recognition for trying. Trying with honesty and intention is never something small."
    ]

    private let recommendationMessages: [String] = [
        "Consider making tonight a slower night. Eat well, keep water nearby, and give yourself permission to choose ease over pressure.",
        "A good next step may be to set a simple limit for the rest of today. Clear, realistic boundaries are often easier to follow than vague intentions.",
        "Try planning one alcohol-free activity this week that you genuinely enjoy. The more rewarding your alternatives feel, the easier change becomes.",
        "It may help to keep a favorite non-alcoholic drink available. Having a satisfying substitute can reduce the feeling that you are missing out.",
        "Consider checking in with your strongest trigger this week. Stress, boredom, celebration, and social pressure all call for different strategies.",
        "A useful focus right now could be pacing. Slowing down often creates more control without making the experience feel overly restrictive.",
        "It might be a good time to create a short evening routine that helps you unwind without alcohol. Repetition can turn that routine into something your mind starts to expect.",
        "If you have had more than planned this week, try shifting from judgment to curiosity. Understanding what happened is more helpful than criticizing yourself.",
        "Consider making your first response to stress something physical or calming, like a walk, stretching, deep breathing, or a shower. Small interruptions can change the whole direction of a night.",
        "A practical next move could be removing guesswork. Decide in advance when, where, and how much you want to drink rather than leaving it open-ended.",
        "Try noticing whether certain people, places, or times make your goals harder to keep. Awareness of patterns can help you prepare instead of react.",
        "It may help to focus on sleep tonight. Better rest can improve mood, reduce cravings, and make tomorrow’s choices easier.",
        "Consider celebrating progress in a way that supports your goal. A reward that leaves you feeling better tomorrow is often the better kind.",
        "A helpful recommendation for this week is to make one decision easier. That might mean not buying alcohol, leaving an event earlier, or telling someone your plan.",
        "If you are finding things hard, consider lowering the pressure and aiming for one solid win today. One intentional success can restore momentum quickly.",
        "Try paying attention to the story you tell yourself after a setback. A calmer, kinder response usually leads to better choices than shame does.",
        "It may be useful to review what has gone well lately. The strategies that worked before are often your best guide for what to repeat next.",
        "Consider building a “pause list” for cravings — three things you do before deciding to drink. That extra space can help you choose with more intention.",
        "A strong recommendation is to keep your goal visible and specific. The clearer your reason is, the easier it becomes to stay aligned with it.",
        "If you want today to feel different, start with one supportive action now: drink water, eat something, step outside, text someone, or choose to wait ten minutes before deciding."
    ]

    private var daySeed: Int {
        Calendar.current.ordinality(of: .day, in: .era, for: container.currentDate) ?? 0
    }

    private var dailySupport: String {
        message(from: dailySupportMessages, offset: 0)
    }

    private var advice: String {
        message(from: adviceMessages, offset: 1)
    }

    private var praiseMessage: String {
        message(from: praiseMessages, offset: 2)
    }

    private var recommendation: String {
        message(from: recommendationMessages, offset: 3)
    }

    var body: some View {
        let trimmedName = container.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)

        GeometryReader { geometry in
            ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Guidance for \(trimmedName.isEmpty ? "Friend" : trimmedName)")
                            .font(AppTheme.font(.title2, weight: .bold))
                            .foregroundStyle(AppTheme.text)

                        Text("Daily support and practical coaching based on your recent progress.")
                            .font(AppTheme.font(.footnote))
                            .foregroundStyle(AppTheme.text.opacity(0.9))

                        guidanceAccordion(title: "Daily Support", message: dailySupport, icon: "sun.max", isExpanded: $showDailySupport)
                        guidanceAccordion(title: "Advice", message: advice, icon: "lightbulb", isExpanded: $showAdvice)
                        guidanceAccordion(title: "Praise", message: praiseMessage, icon: "hands.clap", isExpanded: $showPraise)
                        guidanceAccordion(title: "Recommendation", message: recommendation, icon: "target", isExpanded: $showRecommendation)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: geometry.size.height, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(AppTheme.background)
                .appFullscreenContainer()
        }
    }

    private func message(from messages: [String], offset: Int) -> String {
        guard !messages.isEmpty else { return "" }
        let index = (daySeed + offset) % messages.count
        return messages[index]
    }

    private func guidanceAccordion(title: String, message: String, icon: String, isExpanded: Binding<Bool>) -> some View {
        DisclosureGroup(isExpanded: isExpanded) {
            Text(message)
                .font(AppTheme.font(.footnote))
                .foregroundStyle(AppTheme.text.opacity(0.95))
                .padding(.top, 8)
        } label: {
            Label(title, systemImage: icon)
                .font(AppTheme.font(.subheadline, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    GuidanceView().environmentObject(AppContainer())
}
