# Building and development

## Build from source

Needs Xcode 26 (Swift 6.2+).

```sh
scripts/bundle.sh                 # dev build → build/Orbyt.app
open build/Orbyt.app
scripts/release.sh 0.3.0          # universal release → build/release/Orbyt-0.3.0.{dmg,zip}
```

`BIGTTY_SESSION=<name>` connects to a named herdr session.

Only one copy of a bundle id runs: launching a second (say from Spotlight)
brings the running one to the front. Dev builds use `dev.orbyt.dev`, so
they run next to the installed `dev.orbyt.orbyt`, with their own settings
(`defaults read dev.orbyt.dev`) and notification permission. Both share
the control socket; whichever started first serves `obt`. Set
`BIGTTY_SOCKET=<path>` to give an instance its own socket; such instances
always run.

## Development

```sh
swift test                                  # unit tests
herdr --session bttytest server &            # isolated server for live tests
BTTY_TEST_SESSION=bttytest swift test         # + live socket/terminal tests
```

Debug hooks on a running app: `kill -USR1 <pid>` writes window, pane and
on-screen terminal text to `$TMPDIR/orbyt-debug.txt` (plus a window
render); `kill -USR2 <pid>` pastes `$TMPDIR/orbyt-type.txt` into the
focused pane, or, starting with `!`, sends a menu action
(`!@<space> newBrowserPane:`). Quit the app with `pkill -x Orbyt`
(`pkill -f Orbyt.app` also kills the placeholders inside herdr panes).
