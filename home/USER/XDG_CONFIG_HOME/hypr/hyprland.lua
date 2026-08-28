hl.config({
  animations = { enabled = false },
  decoration = {
    blur = { passes = 3 },
    shadow = {
      color = '#00000033',
      offset = { 4, 4 },
      range = 6,
      render_power = 1
    }
  },
  dwindle = { preserve_split = true },
  general = {
    -- CSS named colors: deepskyblue, springgreen
    col = { active_border = { colors = { '#00bfff', '#00ff7f' } } },
    gaps_in = 0,
    gaps_out = 0
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0
  }
})

hl.window_rule({
  border_size = 0,
  match = { float = false, workspace = 'w[tv1]' },
  no_shadow = true
})

hl.window_rule({ match = { class = '.*' }, suppress_event = 'maximize' })

hl.window_rule({
  match = {
    class = '^$',
    float = true,
    fullscreen = false,
    pin = false,
    title = '^$',
    xwayland = true
  },
  no_focus = true
})

hl.monitor({
  mode = '3840x2160@60',
  output = 'DP-1',
  position = '0x0',
  scale = 2
})

hl.monitor({
  mode = '1920x1080@240',
  output = 'DP-2',
  position = '1920x0',
  scale = 1
})

for key = 1, 6 do
  hl.workspace_rule({
    default = (key % 3) == 1,
    monitor = 'DP-' .. (key <= 3 and 1 or 2),
    persistent = true,
    workspace = key
  })

  if key <= 2 then
    hl.bind(
      'SUPER + CTRL + SHIFT + ' .. key,
      hl.dsp.focus({ monitor = 'DP-' .. key })
    )
  end

  hl.bind(
    'SUPER + ' .. key,
    hl.dsp.focus({ on_current_monitor = true, workspace = key })
  )

  hl.bind(
    'SUPER + SHIFT + ' .. key,
    hl.dsp.window.move({ follow = false, workspace = key })
  )
end

hl.bind('SUPER + B', hl.dsp.exec_cmd('uwsm-app -- chromium'))
hl.bind('SUPER + M', hl.dsp.exec_cmd('uwsm-app -- hyprlauncher'))
hl.bind('SUPER + RETURN', hl.dsp.exec_cmd('uwsm-app -- kitty'))

hl.bind(
  'SUPER + H',
  hl.dsp.window.resize({ x = -20, y = 0 }),
  { repeating = true }
)
hl.bind(
  'SUPER + J',
  hl.dsp.window.resize({ x = 0, y = 20 }),
  { repeating = true }
)
hl.bind(
  'SUPER + K',
  hl.dsp.window.resize({ x = 0, y = -20 }),
  { repeating = true }
)
hl.bind(
  'SUPER + L',
  hl.dsp.window.resize({ x = 20, y = 0 }),
  { repeating = true }
)

hl.bind('SUPER + F', hl.dsp.window.fullscreen({ mode = 'fullscreen' }))
hl.bind('SUPER + Q', hl.dsp.window.close())
hl.bind('SUPER + SHIFT + P', hl.dsp.window.pin())
hl.bind('SUPER + SHIFT + T', hl.dsp.window.float())
hl.bind('SUPER + SHIFT + TAB', hl.dsp.window.swap({ next = true }))
hl.bind('SUPER + TAB', hl.dsp.window.cycle_next())

-- Dwindle Layout
hl.bind('SUPER + SHIFT + J', hl.dsp.layout('togglesplit'))

-- Special Workspace
hl.bind('SUPER + S', hl.dsp.workspace.toggle_special('s'))
hl.bind('SUPER + SHIFT + S', hl.dsp.window.move({ workspace = 'special:s' }))

hl.bind('SUPER + mouse_down', hl.dsp.focus({ workspace = 'e+1' }))
hl.bind('SUPER + mouse_up', hl.dsp.focus({ workspace = 'e-1' }))

hl.bind('SUPER + mouse:272', hl.dsp.window.drag(), { mouse = true })
hl.bind('SUPER + mouse:273', hl.dsp.window.resize(), { mouse = true })
