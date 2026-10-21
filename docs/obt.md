# obt: agents driving Orbyt

**Orbyt ▸ Install obt and Agent Skill…** puts `obt` on your `PATH` and
teaches your agents to use it:

```sh
obt browser open localhost:3000      # beside the agent, or this tab's browser
obt browser snapshot -i              # - textbox "Email" [ref=e3] …
obt browser fill @e3 me@example.com
obt browser click @e5
obt browser wait --text "Welcome"
obt browser screenshot out.png --open
obt open src/app.py:42               # show a file beside the agent
obt diff                             # show the repo's changes
```

Also `type`, `press`, `select`, `check`, `scroll`, `hover`, `get`, `eval`,
`console`, `navigate`, `back`, `forward`, `reload`, `list`, `close`, and
`--json`. Commands go over a user-only socket; the page script runs in an
isolated JavaScript world.

## Notifications

```sh
obt notify "Deploy finished"                   # from a script or agent in a pane
obt notify --title "CI" "tests passed"
```

The message goes on **Needs You** for the calling pane (`HERDR_PANE_ID`, or
`--pane <id>`) and, unless you're looking at that pane, a macOS notification.
If macOS notifications are off for Orbyt, it still lands on Needs You and
`obt` says so. The agent skill tells agents about it, and to use it only when
they're blocked, need a decision, or have finished a long task.

### Claude Code

Claude Code only sends terminal notifications to terminals it recognises,
and herdr panes aren't one, so its notifications (the PushNotification tool)
never reach Orbyt on their own. A Claude Code hook sends them:

```sh
obt hooks install claude      # adds a Notification hook to ~/.claude/settings.json
obt hooks status claude
obt hooks uninstall claude
```

`install` merges into the settings file (or `$CLAUDE_CONFIG_DIR/settings.json`,
or `--settings <path>`): your other hooks and settings stay, a copy of the
previous file is kept beside it, and running it again changes nothing. The hook
only handles `push_notification`; permission prompts and finished turns already
reach Needs You through herdr. Outside herdr, or when Orbyt isn't running, it
does nothing. New Claude Code sessions pick it up.
