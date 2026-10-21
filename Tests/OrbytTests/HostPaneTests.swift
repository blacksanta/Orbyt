@testable import Orbyt
import Testing

/// Remote placeholders say what their pane showed, so an untagged pane can be
/// restored; ones written before the rename still say "bigtty".
@Suite struct HostPaneTests {
    @Test func readsPlaceholders() {
        let browser = HostPaneStore.placeholder(in: "\n  Orbyt browser pane\n  Docs\n  https://example.com\n")
        #expect(browser?.kind == .browser)
        #expect(browser?.url == "https://example.com")
        let files = HostPaneStore.placeholder(in: "  bigtty files pane\n  src\n  ~/src\n")
        #expect(files?.kind == .files)
        #expect(files?.path == "~/src")
        #expect(HostPaneStore.placeholder(in: "Orbyt\nsomething else") == nil)
    }
}
