import AppKit

/// Teaches coding agents about `obt`: installs the command on PATH and a
/// skill file for Claude Code and other agents that read `~/.agents/skills`.
@MainActor
enum AgentSkill {
    static func markdown(obt: String) -> String {
        """
        ---
        name: orbyt-browser
        description: Open, read and drive web pages in an Orbyt browser pane next to your terminal (the user sees it live). Use to check a dev server, verify a UI change, fill forms, read docs, or capture screenshots. Also `obt notify` to ping the user.
        ---

        # Orbyt browser

        You run inside a herdr pane shown by Orbyt. `obt browser` controls a real
        WebKit browser pane in the same tab, visible to the user. The binary is
        `obt` (or `\(obt)`).

        ## Loop

        1. `obt browser open http://localhost:3000` — opens a browser pane beside you
           (or reuses this tab's browser). Prints `id  url  title`.
        2. `obt browser snapshot -i` — interactive elements with refs:
           `- textbox "Email" [ref=e3]`, `- button "Sign in" [ref=e5]`.
           Drop `-i` for the full page structure and text.
        3. Act with refs (or CSS selectors): `obt browser fill @e3 me@example.com`,
           `obt browser click @e5`, `obt browser press Enter`.
        4. Refs go stale after the page changes: snapshot again before the next action.

        ## Commands

        - `open [url] [--new]`, `navigate <url>`, `back`, `forward`, `reload`, `list`
        - `snapshot [-i] [--selector S]`
        - `click|dblclick|hover|highlight <target>`, `check|uncheck <target>`
        - `fill <target> <text>`, `type <target> <text>`, `press <key> [target]`
        - `select <target> <value>...`, `scroll [up|down] [px]`, `scroll --target <t>`
        - `get text|html|value|attr|count|visible|url|title [target] [attr]`
        - `eval '<js>'` (expressions or statements with `return`; `await` works)
        - `wait --text T | --selector S | --url U | --load [--gone] [--timeout s]`
        - `screenshot [path]` → PNG path; read it to see the page
        - `console [--clear]` — console output and page errors since load

        Add `--json` for machine-readable output and `--browser <id>` to pick a
        pane from `list`. Exit code 3 means Orbyt isn't running.

        ## Pinging the user

        `obt notify "<message>"` puts a message on the user's Needs You list and
        shows a macOS notification if they aren't looking at your pane. Use it
        sparingly: when you're blocked, need a decision, or finished a long task.
        """
    }

    /// Links `obt` into ~/.local/bin and writes the skill for every agent
    /// home that exists. Returns what was done, for the confirmation alert.
    static func install() -> [String] {
        let fm = FileManager.default
        let home = NSHomeDirectory()
        let obt = Bundle.main.executableURL!.deletingLastPathComponent().appendingPathComponent("obt").path
        var done: [String] = []

        let bin = home + "/.local/bin"
        try? fm.createDirectory(atPath: bin, withIntermediateDirectories: true)
        let link = bin + "/obt"
        try? fm.removeItem(atPath: link)
        if (try? fm.createSymbolicLink(atPath: link, withDestinationPath: obt)) != nil {
            done.append("Linked \(link) → Orbyt's obt")
        }
        // What bigtty installed: its `btty` link (only one into an app) and skill.
        let oldLink = bin + "/btty"
        if let target = try? fm.destinationOfSymbolicLink(atPath: oldLink), target.hasSuffix(".app/Contents/MacOS/btty") {
            try? fm.removeItem(atPath: oldLink)
        }

        for base in [home + "/.claude", home + "/.agents"] where fm.fileExists(atPath: base) {
            try? fm.removeItem(atPath: base + "/skills/bigtty-browser")
            let dir = base + "/skills/orbyt-browser"
            try? fm.createDirectory(atPath: dir, withIntermediateDirectories: true)
            if (try? markdown(obt: link).write(toFile: dir + "/SKILL.md", atomically: true, encoding: .utf8)) != nil {
                done.append("Wrote \((dir as NSString).abbreviatingWithTildeInPath)/SKILL.md")
            }
        }
        return done
    }
}
