--[[

Adapted from:
  - Ring Meters by londonali1010 (https://www.gnome-look.org/p/1115175/)
  - Conky Draw  by fisadev (https://github.com/fisadev/conky-draw)

IMPORTANT: if you are using the 'cpu' function, it will cause a segmentation
fault if it tries to draw a ring straight away. The if statement on line 145
uses a delay to make sure that this doesn't happen. It calculates the length of
the delay by the number of updates since Conky started. Generally, a value of
5s is long enough, so if you update Conky every 1s, use update_num>5 in that if
statement (the default). If you only update Conky every 2s, you should change
it to update_num>3; conversely if you update Conky every 0.5s, you should use
update_num>10. ALSO, if you change your Conky, is it best to use "killall
conky; conky" to update it, otherwise the update_num will not be reset and you
will get an error.

Available Rendering Modules:

  ??_rings_table = {      RINGS TO RENDER
    {
      name='time',        -- the type of stat to display; you can choose from 'cpu', 'memperc', 'fs_used_perc', 'battery_used_perc'
      arg='%I.%M',        -- the argument to the stat, e.g. if in Conky you would write ${cpu cpu0}, 'cpu0' would be the argument
      max=12,             -- the maximum value of the ring, if the Conky variable outputs a percentage, use 100
      bg_colour=0xffffff, -- the colour of the base ring
      bg_alpha=0.1,       -- the alpha value of the base ring
      fg_colour=0xffffff, -- the colour of the indicator part of the ring
      fg_alpha=0.2,       -- the alpha value of the indicator part of the ring
      x=165, y=170,       -- the x and y coordinates of the centre of the ring, relative to the top left corner of the Conky window
      radius=50,          -- the radius of the ring
      thickness=5,        -- the thickness of the ring, centred around the radius.
      start_angle=0,      -- the starting angle of the ring, in deg, clockwise from top, value can be either positive or negative
      end_angle=360       -- the ending angle of the ring, in deg, clockwise from top, value can be either positive or negative, must be larger (more clockwise) than start_angle
    },
  }

  ??_bars_table = {       BARS TO RENDER
    {
        conky_value = 'fs_used_perc /home/',
        from = {x = 0, y = 45},
        to = {x = 180, y = 45},
        background_thickness = 20,
        bar_thickness = 16,
    },
  }

  ??_text_table = {       TEXT TO RENDER
    {
      font="Mono",
      font_size=10,
      text="${exec sensors coretemp-isa-0000 | grep Physical | sed 's/\+//' | awk '{print $4}'}",
      xpos=635, ypos=155,
      fgcol=0x333333,
      fgopa=0.4,
      font_slant=CAIRO_FONT_SLANT_NORMAL,
      font_face=CAIRO_FONT_WEIGHT_NORMAL,
    },
  }

]]

-------------------
-------------------
--  Time Tables  --
-------------------
-------------------

time_rings_table = {
  {
    name='time',
    arg='%I.%M',
    max=12,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xffffff,
    fg_alpha=0.2,
    x=165, y=170,
    radius=50,
    thickness=5,
    start_angle=0,
    end_angle=360
  },
  {
    name='time',
    arg='%d',
    max=31,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xffffff,
    fg_alpha=0.8,
    x=165, y=170,
    radius=70,
    thickness=5,
    start_angle=212,
    end_angle=360
  },
  {
    name='time',
    arg='%m',
    max=12,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xffffff,
    fg_alpha=0.8,
    x=165, y=170,
    radius=76,
    thickness=5,
    start_angle=212,
    end_angle=360
  },
}

----------------------
----------------------
--  Battery Tables  --
----------------------
----------------------

battery_rings_table = {
  {
    name='battery_percent',
    arg='BAT1',
    max=100,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xffffff,
    fg_alpha=0.6,
    x=165, y=170,
    radius=72,
    thickness=11,
    start_angle=122,
    end_angle=210
  },
}

---------------------
---------------------
--  Memory Tables  --
---------------------
---------------------

memory_rings_table = {
  {
    name='memperc',
    arg='',
    max=100,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xffffff,
    fg_alpha=0.8,
    x=165, y=170,
    radius=83.5,
    thickness=8,
    start_angle=122,
    end_angle=210
  },
}

-------------------------
-------------------------
--  Filesystem Tables  --
-------------------------
-------------------------

function query_filesystem_stats()

  filesystem_text_table = {}
  filesystem_bars_table = {}

  -- grab all non-temp filesystems and their stats
  local mount_raw = conky_parse("${exec df -hP -x tmpfs -x devtmpfs | grep -v 'Mounted on'}")
  local mounts = {}
  for line in string.gmatch(mount_raw, '([^\n]+)') do
    table.insert(mounts, line)
  end

  -- starting y coordinates
  local filesystem_text_start_y = 10
  local filesystem_bar_start_y  = 20

  -- loop through all mounts and build tables
  for line = 1,table.getn(mounts) do
    -- split the line into a table
    local index = 1
    local mount = {}
    for value in string.gmatch(mounts[line], "%S+") do 
      mount[index] = value
      index = index + 1
    end

    -- append onto the filesystem text table
    table.insert(filesystem_text_table, {
      font="Mono",
      font_size=10,
      text=mount[6],
      xpos=1, ypos=filesystem_text_start_y,
      fgcol=0x333333,
      fgopa=0.4,
      font_slant=CAIRO_FONT_SLANT_NORMAL,
      font_face=CAIRO_FONT_WEIGHT_NORMAL,
    })

    table.insert(filesystem_bars_table, {
      conky_value = 'fs_used_perc ' .. mount[6],
      from = {x = 0, y = filesystem_bar_start_y},
      to = {x = 235, y = filesystem_bar_start_y},
      background_thickness = 10,
      bar_thickness = 10,
      max_value = 100,
      critical_threshold = 80,
      change_color_on_critical = true,
      background_color = 0x333333,
      background_alpha = 0.05,
      background_color_critical = 0x333333,
      background_alpha_critical = 0.05,
      graduated = true,
      number_graduation = 50,
      space_between_graduation = 2,
      bar_color = 0x333333,
      bar_alpha = 0.5,
      bar_color_critical = 0xcd5c5c,
      bar_alpha_critical = 0.5,
    })

    -- increment for the next go around
    filesystem_text_start_y = filesystem_text_start_y + 30
    filesystem_bar_start_y = filesystem_bar_start_y + 30
  end
end

filesystem_rings_table = {
  {
    name='fs_used_perc',
    arg='/',
    max=150,
    bg_colour=0xffffff,
    bg_alpha=0.2,
    fg_colour=0xffffff,
    fg_alpha=0.3,
    x=165, y=170,
    radius=108.5,
    thickness=3,
    start_angle=-120,
    end_angle=240
  },
  {
    name='fs_used_perc',
    arg='/',
    max=100,
    bg_colour=0xffffff,
    bg_alpha=0.2,
    fg_colour=0xffffff,
    fg_alpha=0.3,
    x=165, y=170,
    radius=135,
    thickness=50,
    start_angle=-120,
    end_angle=120
  },
}

------------------
------------------
--  CPU Tables  --
------------------
------------------

-- text settings
cpu_text_table = {
  {
    font="Mono",
    font_size=10,
    text="${exec sensors coretemp-isa-0000 | grep Physical | sed 's/\+//' | awk '{print $4}'}",
    xpos=105, ypos=125,
    fgcol=0x333333,
    fgopa=0.4,
    font_slant=CAIRO_FONT_SLANT_NORMAL,
    font_face=CAIRO_FONT_WEIGHT_NORMAL,
  },
  {
    font="Mono",
    font_size=10,
    text="${exec sensors coretemp-isa-0001 | grep Physical | sed 's/\+//' | awk '{print $4}'}",
    xpos=105, ypos=375,
    fgcol=0x333333,
    fgopa=0.4,
    font_slant=CAIRO_FONT_SLANT_NORMAL,
    font_face=CAIRO_FONT_WEIGHT_NORMAL,
  }
}

-- ring settings
cpu_rings_table = {
}

-- cpu 1 settings
CPU1 = {
  cores=16,
  cstart=1,
  xcord=120,
  ycord=120,
  bgcol='0x333333',
  fgcol='0xcd5c5c',
  bgopa=0.05,
  fgopa=0.5,
}

for i = 0, CPU1['cores'] - 1, 1
do
  table.insert(cpu_rings_table, {
    name='cpu',
    arg='cpu' .. (i + CPU1['cstart']),
    max=100,
    bg_colour=CPU1['bgcol'],
    bg_alpha=CPU1['bgopa'],
    fg_colour=CPU1['fgcol'],
    fg_alpha=CPU1['fgopa'],
    x=CPU1['xcord'], y=CPU1['ycord'],
    radius=35 + (i * 5),
    thickness=4,
    start_angle=0,
    end_angle=360
  })
end

-- cpu 2 settings
CPU2 = {
  cores=16,
  cstart=17,
  xcord=120,
  ycord=370,
  bgcol=0x333333,
  fgcol=0xcd5c5c,
  bgopa=0.05,
  fgopa=0.5,
}

for i = 0, CPU2['cores'] - 1, 1
do
  table.insert(cpu_rings_table, {
    name='cpu',
    arg='cpu' .. (i + CPU2['cstart']),
    max=100,
    bg_colour=CPU2['bgcol'],
    bg_alpha=CPU2['bgopa'],
    fg_colour=CPU2['fgcol'],
    fg_alpha=CPU2['fgopa'],
    x=CPU2['xcord'], y=CPU2['ycord'],
    radius=35 + (i * 5),
    thickness=4,
    start_angle=0,
    end_angle=360
  })
end

require 'cairo'

------------------------
------------------------
--  Helper Functions  --
------------------------
------------------------

--troubleshooting tables, dump to console
function tprint(tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    else
      print(formatting .. v)
    end
  end
end

-- evaluate a conky template to get its current value ie: "cpu cpu0" --> 20
function get_conky_value(conky_value, is_number)
  local value = conky_parse(string.format('${%s}', conky_value))

  if is_number then
    value = tonumber(value)
  end
  if value==nil then
    return 0
  end
  return value
end

-- convert color codes to cairo supported format
function rgb_to_r_g_b(colour,alpha)
  return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

-- draw text to screen
function draw_text(cr,tt)
  text = conky_parse(tt.text)
  fgc  = tt.fgcol
  fga  = tt.fgopa
  cairo_set_font_size(cr, tt.font_size)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
  cairo_move_to(cr,tt.xpos,tt.ypos)
  cairo_show_text(cr,text)
  cairo_stroke(cr)
end

-- draw rings to screen
function draw_ring(cr,t,pt)
  local w,h=conky_window.width,conky_window.height
  
  local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
  local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

  local angle_0=sa*(2*math.pi/360)-math.pi/2
  local angle_f=ea*(2*math.pi/360)-math.pi/2
  local t_arc=t*(angle_f-angle_0)

  -- draw background ring

  cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
  cairo_set_line_width(cr,ring_w)
  cairo_stroke(cr)
  
  -- draw indicator ring

  cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
  cairo_stroke(cr)    
end

-- draw a line
function draw_line(cr, element)
  -- deltas for x and y (cairo expects a point and deltas for both axis)
  local x_side = element.to.x - element.from.x -- not abs! because they are deltas
  local y_side = element.to.y - element.from.y -- and the same here
  local from_x = element.from.x
  local from_y = element.from.y

  if not element.graduated then
    -- draw line
    cairo_set_source_rgba(cr, rgb_to_r_g_b(element.color, element.alpha))
    cairo_set_line_width(cr, element.thickness);
    cairo_move_to(cr, element.from.x, element.from.y);
    cairo_rel_line_to(cr, x_side, y_side);
  else
    -- draw graduated line
    cairo_set_source_rgba(cr, rgb_to_r_g_b(element.color, element.alpha))
    cairo_set_line_width(cr, element.thickness);
    local space_graduation_x = (x_side-x_side/element.space_between_graduation+1)/element.number_graduation
    local space_graduation_y =(y_side-y_side/element.space_between_graduation+1)/element.number_graduation
    local space_x = x_side/element.number_graduation-space_graduation_x
    local space_y = y_side/element.number_graduation-space_graduation_y

    for i=1,element.number_graduation do
      cairo_move_to(cr,from_x,from_y)
      from_x=from_x+space_x+space_graduation_x
      from_y=from_y+space_y+space_graduation_y
      cairo_rel_line_to(cr,space_x,space_y)
    end
  end
  cairo_stroke(cr)
end

-- draw a bar graph
function draw_bar_graph(cr, element)
  value = get_conky_value(element.conky_value, true)
  if value > element.max_value   then
    value = element.max_value
  end

  -- dimensions of the full graph
  local x_side = element.to.x - element.from.x
  local y_side = element.to.y - element.from.y
  local hypotenuse = math.sqrt(math.pow(x_side, 2) + math.pow(y_side, 2))
  local angle = math.atan2(y_side, x_side)

  -- dimensions of the value bar
  local bar_hypotenuse = value * (hypotenuse / element.max_value)
  local bar_x_side = bar_hypotenuse * math.cos(angle)
  local bar_y_side = bar_hypotenuse * math.sin(angle)

  -- is it in critical value?
  local color_critical_or_not_suffix = ''
  local alpha_critical_or_not_suffix = ''
  local thickness_critical_or_not_suffix = ''
  if value >= element.critical_threshold then
    if element.change_color_on_critical then
      color_critical_or_not_suffix = '_critical'
    end
    if element.change_alpha_on_critical then
      alpha_critical_or_not_suffix = '_critical'
    end
    if element.change_thickness_on_critical then
      thickness_critical_or_not_suffix = '_critical'
    end
  end

  -- background line (full graph)
  background_line = {
    from = element.from,
    to = element.to,

    color = element['background_color' .. color_critical_or_not_suffix],
    alpha = element['background_alpha' .. alpha_critical_or_not_suffix],
    thickness = element['background_thickness' .. thickness_critical_or_not_suffix],
    graduated = element.graduated,
    number_graduation=element.number_graduation,
    space_between_graduation=element.space_between_graduation,
  }
  bar_line = {
    from = element.from,
    to = {x=element.from.x + bar_x_side, y=element.from.y + bar_y_side},

    color = element['bar_color' .. color_critical_or_not_suffix],
    alpha = element['bar_alpha' .. alpha_critical_or_not_suffix],
    thickness = element['bar_thickness' .. thickness_critical_or_not_suffix],
  }

  -- draw background lines
  draw_line(cr, background_line)

  if element.graduated then
    -- draw bar line if graduated
    cairo_set_source_rgba(cr, rgb_to_r_g_b(bar_line.color, bar_line.alpha))
    cairo_set_line_width(cr, bar_line.thickness);
    local from_x = bar_line.from.x
    local from_y = bar_line.from.y
    local space_graduation_x = (x_side-x_side/element.space_between_graduation+1)/element.number_graduation
    local space_graduation_y =(y_side-y_side/element.space_between_graduation+1)/element.number_graduation
    local space_x = x_side/element.number_graduation-space_graduation_x
    local space_y = y_side/element.number_graduation-space_graduation_y

    for i=1,bar_x_side/(space_x+space_graduation_x) do

      cairo_move_to(cr,from_x,from_y)
      from_x=from_x+space_x+space_graduation_x
      from_y=from_y+space_y+space_graduation_y
      cairo_rel_line_to(cr,space_x,space_y)
    end

    cairo_stroke(cr)
  else
    -- draw bar line if not graduated
    draw_line(cr,bar_line);
  end

end

----------------------------
----------------------------
--  Render Conky Modules  --
----------------------------
----------------------------

-- cpu stats
function conky_cpu_stats()
  local function setup_rings(cr,pt)
    local str=''
    local value=0

    str=string.format('${%s %s}',pt['name'],pt['arg'])
    str=conky_parse(str)

    value=tonumber(str)
    pct=value/pt['max']

    draw_ring(cr,pct,pt)
  end

  if conky_window==nil then return end
  local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

  local cr=cairo_create(cs)

  local updates=conky_parse('${updates}')
  update_num=tonumber(updates)

  if update_num>5 then
    for i in pairs(cpu_rings_table) do
      setup_rings(cr,cpu_rings_table[i])
    end
  end

  for i in pairs(cpu_text_table) do
    draw_text(cr,cpu_text_table[i])
  end
end

-- filesystem stats
function conky_filesystem_stats()

  query_filesystem_stats()

  if conky_window==nil then return end
  local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

  local cr=cairo_create(cs)

  for i in pairs(filesystem_bars_table) do
    draw_bar_graph(cr,filesystem_bars_table[i])
  end

  for i in pairs(filesystem_text_table) do
    draw_text(cr,filesystem_text_table[i])
  end
end
