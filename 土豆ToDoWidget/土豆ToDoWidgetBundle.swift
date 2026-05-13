import WidgetKit
import SwiftUI

@main
struct PotatoTodoWidgetBundle: WidgetBundle {
    var body: some Widget {
        CalendarWidget()
        CheckInWidget()
        CountdownWidget()
    }
}
