-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
-- Load bling
local bling = require("bling")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"



-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.magnifier,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- Set border width and color
beautiful.border_width = 0
beautiful.border_normal =  "#24273a"
beautiful.border_focus = "#cad3f5"
beautiful.useless_gap = 5
beautiful.maximized_hide_border = true
beautiful.fullscreen_hide_border = true

-- MAster spllit facor

beautiful.master_width_factor = 0.58

awful.spawn.with_shell("~/.config/awesome/polybar.sh")
awful.spawn.with_shell("~/.config/awesome/autostart.sh")

-- Disable window snapping borders
awful.mouse.snap.edge_enabled = false
awful.mouse.snap.client_enabled = false

-- Function to center and resize a floating window
local function center_floating_client(c)
    -- Check if the client is floating, not a special class, not fullscreen
    if c.floating and c.class ~= "spad" and not c.fullscreen then
        local width, height
        local screen_geometry = c.screen.workarea

        -- Determine if the window can be resized
        if c.size_hints.min_width == c.size_hints.max_width and c.size_hints.min_height == c.size_hints.max_height then
            -- Window cannot be resized, use its current size
            width = c.width
            height = c.height
        else
            -- Window can be resized, set a custom size
            width = 1200 -- adjust width
            height = 760 -- adjust height
        end

        -- Calculate position to center the window
        local x = screen_geometry.x + (screen_geometry.width - width) / 2
        local y = screen_geometry.y + (screen_geometry.height - height) / 2

        -- Check if the window is already centered to avoid unnecessary adjustments
        if c.x ~= x or c.y ~= y then
            -- Apply size and position
            c:geometry({ x = x, y = y, width = width, height = height })
        end
    end
end


-- Connect this function to the client's property change signal
client.connect_signal("property::floating", center_floating_client)
client.connect_signal("manage", center_floating_client)

local my_scratchpad = bling.module.scratchpad:new({
    command = "alacritty --class spad",  -- command to launch the scratchpad application
    rule = { class = "spad" },        -- rule to identify the scratchpad window
    sticky = false,                      -- whether the scratchpad should stick to all tags
    autoclose = false,                   -- automatically close the scratchpad when losing focus
    floating = true,                    -- make the window floating
    geometry = {x=560, y=65, height=500, width=800, centered=true},  -- geometry of the scratchpad window, centered
    reapply = true,                     -- reapply geometry when the scratchpad is shown
    autostart = false,
    dont_focus_before_close = false     -- focus the scratchpad before closing it
})



-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))
-- Unused
local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, visible = false })


    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ modkey }, 4, awful.tag.viewnext),
    awful.button({ modkey }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Layout manipulation
    awful.key({ modkey,}, "w", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- My Keybinds

    awful.key({}, "XF86MonBrightnessUp", function () awful.spawn("brightnessctl s +5%") end,
              {description = "increase brightness", group = "custom"}),
    awful.key({}, "XF86MonBrightnessDown", function () awful.spawn("brightnessctl s 5%-") end,
              {description = "decrease brightness", group = "custom"}),
    -- Toggle a window to maximize over all windows on a tag
    awful.key({ modkey, "Control" }, "p", function ()
        local c = client.focus
        if c then
            c.maximized = not c.maximized  -- Toggle maximization state
            c:raise()  -- Bring the window to the front
        end
    end, {description = "toggle maximize over all windows", group = "client"}),
    awful.key({ modkey }, "g", function () awful.spawn("github-desktop") end,
              {description = "open Github Desktop", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "l", function () awful.spawn("i3lock-fancy") end,
              {description = "lock screen with i3lock-fancy", group = "custom"}),
    awful.key({ }, "Print", function () awful.spawn("flameshot gui") end,
              {description = "capture screen with flameshot", group = "screenshot"}),
    awful.key({ modkey }, "a", function () my_scratchpad:toggle() end,
        {description = "toggle scratchpad", group = "custom"}),
    awful.key({ modkey }, "e", function () awful.spawn("Thunar") end,
              {description = "open Thunar file manager", group = "launcher"}),
    awful.key({ modkey }, "c", function () awful.spawn("code") end,
              {description = "open VS Code", group = "launcher"}),
    awful.key({ modkey }, "f", function () awful.spawn("thorium-browser") end,
              {description = "open Thorium Browser", group = "launcher"}),
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.spawn("pamixer -i 5") end,
              {description = "increase volume", group = "media"}),
    awful.key({ }, "XF86AudioLowerVolume", function () awful.spawn("pamixer -d 5") end,
              {description = "decrease volume", group = "media"}),
    awful.key({ }, "XF86AudioMute", function () awful.spawn("pamixer -t") end,
              {description = "toggle mute", group = "media"}),
    awful.key({ }, "XF86AudioPlay", function () awful.spawn("playerctl play-pause") end,
              {description = "play/pause media", group = "media"}),
    awful.key({ }, "XF86AudioPause", function () awful.spawn("playerctl play-pause") end,
              {description = "play/pause media", group = "media"}),
    awful.key({ }, "XF86AudioNext", function () awful.spawn("playerctl next") end,
              {description = "next media track", group = "media"}),
    awful.key({ }, "XF86AudioPrev", function () awful.spawn("playerctl previous") end,
              {description = "previous media track", group = "media"}),
    awful.key({ modkey }, "d", function () awful.spawn.with_shell("rofi -modi 'clipboard:greenclip print' -show clipboard -run-command '{cmd}'") end,
              {description = "list clipboard to rofi", group = "custom"}),
    awful.key({ modkey }, "F4", function ()
        local clients = awful.screen.focused().clients
        for _, c in pairs(clients) do
            if c.class ~= "Polybar" then
                c:kill()
            end
        end
    end,
    {description = "kill all windows except polybar", group = "client"}),
    -- Standard program
    awful.key({ modkey,           }, "q", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey }, "r", function() awful.spawn.with_shell("rofi -show drun") end,
              {description = "Rofi run launcher", group = "launcher"}),

    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey,           }, "m", awesome.restart,
              {description = "restart awesome", group = "awesome"}),

    awful.key({ modkey,           }, "Up",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "Down",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "p",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ "Mod1",   }, "F4",      function (c) c:kill() end,
              {description = "close", group = "client"}),
    awful.key({ modkey}, "v",  awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    --Unused awful.key({ modkey,           }, "m",
    --    function (c)
    --            c.maximized = not c.maximized
    --            c:raise()
     --   end ,
     --   {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     maximized = false,
                     switchtotag = true
     }
    },
    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    --My workspace rules


    { rule = { class = "Polybar" },
      properties = { border_width = 0 } },

    { rule = { },
      properties = { screen = 1, tag = "1" } },

    { rule = { class = "Thunar" },
      properties = { screen = 1, tag = "2" } },

    { rule = { class = "Thorium-browser" },
      properties = { screen = 1, tag = "3" } },

    { rule = { class = "Code" },
      properties = { screen = 1, tag = "4" } },

    { rule = { class = "Cursor" },
      properties = { screen = 1, tag = "4" } },

    { rule = { class = "discord" },
      properties = { screen = 1, tag = "5" } },

    { rule = { class = "Alacritty" },
      properties = { screen = 1, tag = "6" } },

    { rule = { class = "steam" },
      properties = { screen = 1, tag = "7" } },

    { rule = { class = "Mailspring" },
      properties = { floating = false, tag = "8" } },

    { rule = { class = "Spotify" },
      properties = { screen = 1, tag = "9" } },

    { rule = { class = "spad" },
      properties = { screen = 1, tag = "nil", autostart=false } },

    { rule = { instance = "xdg-desktop-portal-gtk" },
      properties = { floating = true, tag = "nil" } },

    { rule = { name = "All Files" },
      properties = { screen = 1, tag = "nil" } },

    { rule = { class = "PeaZip" },
      properties = { floating = true, tag = "nil" } },

      { rule = { class = "qView" },
      properties = { floating = true, tag = "nil" } },

      { rule = { class = "mpv" },
      properties = { floating = true, tag = "nil" } },

      { rule = { name = "Authentication required" },
      properties = { screen = 1, tag = "nil", ontop = true,
                     x=760, y=450, width = 400, height = 200, centered = true } },
}


-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.

client.connect_signal("request::activate", function(c, context, hints)
    if context ~= "ewmh" then return end
    if not c:isvisible() then
        local t = c.first_tag
        if t then
            t:view_only()
        end
    end
    client.focus = c
    c:raise()
end)

-- Ensure the master window remains master when a new client is launched
client.connect_signal("manage", function(c)
    c.shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 10)  -- 10 is the radius of the corners
    end
end)

client.connect_signal("manage", function(c)
    if not awesome.startup then
        awful.client.setslave(c)

    end
end)


client.connect_signal("property::fullscreen", function(c)
    if c.fullscreen then
        -- Set border width to 0 when a client is fullscreen
        c.shape = gears.shape.rectangle
    else
        -- Restore the border width when a client is not fullscreen
        c.border_width = beautiful.border_width
    end
end)


client.connect_signal("property::maximized", function(c)
    if c.maximized then
        c.shape = gears.shape.rectangle
    else
        c.border_width = beautiful.border_width
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

client.connect_signal("property::floating", center_floating_client)


client.connect_signal("property::minimized", function(c)
    c.minimized = false
end)

client.connect_signal("property::floating", function(c)
    if not c.fullscreen then  -- Check if the client is not in fullscreen mode
        c.ontop = c.floating
    end
end)