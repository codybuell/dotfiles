--[[
Ring Meters by londonali1010 (2009)

This script draws percentage meters as rings. It is fully customisable; all options are described in the script.

IMPORTANT: if you are using the 'cpu' function, it will cause a segmentation fault if it tries to draw a ring straight away. The if statement on line 145 uses a delay to make sure that this doesn't happen. It calculates the length of the delay by the number of updates since Conky started. Generally, a value of 5s is long enough, so if you update Conky every 1s, use update_num>5 in that if statement (the default). If you only update Conky every 2s, you should change it to update_num>3; conversely if you update Conky every 0.5s, you should use update_num>10. ALSO, if you change your Conky, is it best to use "killall conky; conky" to update it, otherwise the update_num will not be reset and you will get an error.

To call this script in Conky, use the following (assuming that you save this script to ~/scripts/rings.lua):
  lua_load ~/scripts/rings-v1.2.lua
  lua_draw_hook_pre ring_stats
  
Changelog:
+ v1.2 -- Added option for the ending angle of the rings (07.10.2009)
+ v1.1 -- Added options for the starting angle of the rings, and added the "max" variable, to allow for variables that output a numerical value rather than a percentage (29.09.2009)
+ v1.0 -- Original release (28.09.2009)
]]

CPU1 = {
  cores=16,
  cstart=1,
  xcord=650,
  ycord=150,
  bgcol='0x333333',
  fgcol='0xcd5c5c',
  bgopa=0.05,
  fgopa=0.5,
}

cpu1 = {}
for i = 0, CPU1['cores'] - 1, 1
do
  table.insert(cpu1, {
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

-- troubleshooting tables, dump to console
-- function tprint (tbl, indent)
--   if not indent then indent = 0 end
--   for k, v in pairs(tbl) do
--     formatting = string.rep("  ", indent) .. k .. ": "
--     if type(v) == "table" then
--       print(formatting)
--       tprint(v, indent+1)
--     else
--       print(formatting .. v)
--     end
--   end
-- end
-- 
-- tprint(cpu1, 2)

CPU2 = {
  cores=16,
  cstart=17,
  xcord=650,
  ycord=400,
  bgcol=0x333333,
  fgcol=0xcd5c5c,
  bgopa=0.05,
  fgopa=0.5,
}

cpu2 = {}
for i = 0, CPU2['cores'] - 1, 1
do
  table.insert(cpu2, {
    name='cpu',
    arg=i + CPU2['cstart'],
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

settings_table = {
--{
--  -- Edit this table to customise your rings.
--  -- You can create more rings simply by adding more elements to settings_table.
--  -- "name" is the type of stat to display; you can choose from 'cpu', 'memperc', 'fs_used_perc', 'battery_used_perc'.
--  name='time',
--  -- "arg" is the argument to the stat type, e.g. if in Conky you would write ${cpu cpu0}, 'cpu0' would be the argument. If you would not use an argument in the Conky variable, use ''.
--  arg='%I.%M',
--  -- "max" is the maximum value of the ring. If the Conky variable outputs a percentage, use 100.
--  max=12,
--  -- "bg_colour" is the colour of the base ring.
--  bg_colour=0xffffff,
--  -- "bg_alpha" is the alpha value of the base ring.
--  bg_alpha=0.1,
--  -- "fg_colour" is the colour of the indicator part of the ring.
--  fg_colour=0xffffff,
--  -- "fg_alpha" is the alpha value of the indicator part of the ring.
--  fg_alpha=0.2,
--  -- "x" and "y" are the x and y coordinates of the centre of the ring, relative to the top left corner of the Conky window.
--  x=165, y=170,
--  -- "radius" is the radius of the ring.
--  radius=50,
--  -- "thickness" is the thickness of the ring, centred around the radius.
--  thickness=5,
--  -- "start_angle" is the starting angle of the ring, in degrees, clockwise from top. Value can be either positive or negative.
--  start_angle=0,
--  -- "end_angle" is the ending angle of the ring, in degrees, clockwise from top. Value can be either positive or negative, but must be larger (e.g. more clockwise) than start_angle.
--  end_angle=360
--},
--{
--  name='time',
--  arg='%M.%S',
--  max=60,
--  bg_colour=0xffffff,
--  bg_alpha=0.1,
--  fg_colour=0xffffff,
--  fg_alpha=0.4,
--  x=165, y=170,
--  radius=120,
--  thickness=5,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='time',
--  arg='%S',
--  max=60,
--  bg_colour=0xffffff,
--  bg_alpha=0.1,
--  fg_colour=0xffffff,
--  fg_alpha=0.6,
--  x=165, y=170,
--  radius=115,
--  thickness=5,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu17',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=110,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu18',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=105,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu19',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=100,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu20',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=95,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu21',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=90,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu22',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=85,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu23',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=80,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu24',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=75,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu25',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=70,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu26',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=65,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu27',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=60,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu28',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=55,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu29',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=50,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu30',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=45,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu31',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=40,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu32',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=400,
--  radius=35,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
---- personal
--{
--  name='cpu',
--  arg='cpu1',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=110,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu2',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=105,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu3',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=100,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu4',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=95,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu5',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=90,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu6',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=85,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu7',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=80,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu8',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=75,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu9',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=70,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu10',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=65,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu11',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=60,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu12',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=55,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu13',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=50,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu14',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=45,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu15',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=40,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
--{
--  name='cpu',
--  arg='cpu16',
--  max=100,
--  bg_colour=0x333333,
--  bg_alpha=0.05,
--  fg_colour=0xcd5c5c,
--  fg_alpha=0.5,
--  x=650, y=150,
--  radius=35,
--  thickness=4,
--  start_angle=0,
--  end_angle=360
--},
---- end personal
--{
--  name='cpu',
--  arg='cpu1',
--  max=100,
--  bg_colour=0xffffff,
--  bg_alpha=0,
--  fg_colour=0xffffff,
--  fg_alpha=0.1,
--  x=165, y=170,
--  radius=70,
--  thickness=5,
--  start_angle=60,
--  end_angle=120
--},
--{
--  name='cpu',
--  arg='cpu2',
--  max=100,
--  bg_colour=0xffffff,
--  bg_alpha=0,
--  fg_colour=0xffffff,
--  fg_alpha=0.1,
--  x=165, y=170,
--  radius=76,
--  thickness=5,
--  start_angle=60,
--  end_angle=120
--},
--{
--  name='cpu',
--  arg='cpu0',
--  max=100,
--  bg_colour=0xffffff,
--  bg_alpha=0.1,
--  fg_colour=0xffffff,
--  fg_alpha=0.4,
--  x=165, y=170,
--  radius=84.5,
--  thickness=8,
--  start_angle=60,
--  end_angle=120
--},
--  {
--    name='battery_percent',
--    arg='BAT1',
--    max=100,
--    bg_colour=0xffffff,
--    bg_alpha=0.1,
--    fg_colour=0xffffff,
--    fg_alpha=0.6,
--    x=165, y=170,
--    radius=72,
--    thickness=11,
--    start_angle=122,
--    end_angle=210
--  },
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
--{
--  name='time',
--  arg='%d',
--  max=31,
--  bg_colour=0xffffff,
--  bg_alpha=0.1,
--  fg_colour=0xffffff,
--  fg_alpha=0.8,
--  x=165, y=170,
--  radius=70,
--  thickness=5,
--  start_angle=212,
--  end_angle=360
--},
--{
--  name='time',
--  arg='%m',
--  max=12,
--  bg_colour=0xffffff,
--  bg_alpha=0.1,
--  fg_colour=0xffffff,
--  fg_alpha=0.8,
--  x=165, y=170,
--  radius=76,
--  thickness=5,
--  start_angle=212,
--  end_angle=360
--},
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

--table.insert(settings_table, cpu1)

require 'cairo'

function rgb_to_r_g_b(colour,alpha)
  return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function draw_ring(cr,t,pt)
  local w,h=conky_window.width,conky_window.height
  
  local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
  local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

  local angle_0=sa*(2*math.pi/360)-math.pi/2
  local angle_f=ea*(2*math.pi/360)-math.pi/2
  local t_arc=t*(angle_f-angle_0)

  -- Draw background ring

  cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
  cairo_set_line_width(cr,ring_w)
  cairo_stroke(cr)
  
  -- Draw indicator ring

  cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
  cairo_stroke(cr)    
end

function conky_ring_stats()
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

  if update_num>1 then
    for i in pairs(settings_table) do
      setup_rings(cr,settings_table[i])
    end
  end
end
