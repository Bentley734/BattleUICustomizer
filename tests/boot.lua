package.path='./?.lua;./?/init.lua;'..package.path
love=require('tests.love_stub')
local GV=require('src.core.GameVersion'); GV.set(arg[1])
if arg[2]=='cached' then
  require('src.import.CacheFs').readAt=function(path)
    if path:match('/manifest.lua$') then return 'return {textboxW=256,textboxH=512}' end
    if path:match('/textbox.rgba$') then return string.rep('\0',256*512*4) end
    if path:match('/healthbox_player.rgba$') then return string.rep('\0',128*64*4) end
    if path:match('/healthbox_enemy.rgba$') then return string.rep('\0',128*32*4) end
  end
end
local fs={}
function fs.getInfo(p)
  if p=='mods' or p=='mods/battle' or p=='mods/kim' then return {type='directory'} end
  if files[p] then return {type='file'} end
end
function fs.getDirectoryItems(p) if p=='mods' then return {'kim','battle'} end; return {} end
function fs.read(p) return files[p] end
function fs.write(p,v) files[p]=v; return true end
function fs.createDirectory() return true end
function fs.load(p) return (loadstring or load)(files[p] or '') end
local Loader=require('src.mods.Loader')
local loader=Loader.new({fs=fs,generation=GV.generation(),version=arg[1],dev=false})
local data={pokemon={},moves={},items={},maps={},tilesets={}}
loader:load(data)
assert(loader.mods.battleuicustomizer.state=='loaded',table.concat(loader.errors,'\n'))
assert(loader.mods.kim1025.state=='loaded',table.concat(loader.errors,'\n'))
print('PASS sandbox boot with KIM1025: '..arg[1])
local Runtime=require('src.mods.Runtime')
local game={data=data,options={modOptions={}},mods=loader,writeOptions=function(self) self.writes=(self.writes or 0)+1 end}
local rows=Runtime.call('ui.options.rows',function(_,r) return r end,game,{})
local entry
for _,r in ipairs(rows) do
 if r.id=='battleuicustomizer:settings' then entry=r end
 assert(not r.id or not r.id:match('battleuicustomizer:style'),'no standalone control')
end
assert(entry and entry.value()=='OPEN','single submenu entry')
local childRows
local submenu,optionsMenu,rseMenu
if GV.generation()==3 then
 local rse=arg[1]=='ruby' or arg[1]=='sapphire' or arg[1]=='emerald'
 local menu=require(rse and 'src.ui.game3.rse.option_menu' or 'src.ui.game3.option_menu')
 if rse then menu._st={pages={{title='OPTIONS'}},ctx={game=game}} else menu._pages={{title='OPTIONS'}} end
 entry.activate({game=game})
 local pages=rse and menu._st.pages or menu._pages
 assert(#pages==2 and pages[2].title=='BATTLE UI CUSTOMIZER','native child page')
 childRows=pages[2].rows;optionsMenu=menu;rseMenu=rse
else
 game.stack={push=function(_,m)game.child=m end,top=function()return game.child end,pop=function()game.child=nil end}
 entry.activate(game)
 assert(game.child and #game.child.items==5,'four controls and back')
 submenu=game.child
 childRows={}
 for _,item in ipairs(game.child.items) do if item.control then childRows[#childRows+1]=item.control end end
end
rows=childRows
local style,opacity,stretch,align
for _,r in ipairs(rows) do
  if r.id=='battleuicustomizer:style' then style=r end
  if r.id=='battleuicustomizer:opacity' then opacity=r end
  if r.id=='battleuicustomizer:menu_stretch' then stretch=r end
  if r.id=='battleuicustomizer:menu_align' then align=r end
end
assert(style and opacity)
assert(style.value()=='VANILLA' and opacity.value()=='100%')
style.step(game,1); opacity.step(game,-1)
assert(style.value()=='EMERALD' and opacity.value()=='90%')
assert(game.options.modOptions.battleuicustomizer.style==2 and game.writes==2)
local E=loader.exports.battleuicustomizer
assert(stretch and align and stretch.value()=='NORMAL' and align.value()=='RIGHT')
local x,scale=E.placement(64,96,160);assert(x==64 and scale==1)
align.step(game,1);assert(align.value()=='LEFT');x,scale=E.placement(64,96,160);assert(x==0 and scale==1)
align.step(game,1);assert(align.value()=='CENTER');x,scale=E.placement(64,96,160);assert(x==32 and scale==1)
align.step(game,1);assert(align.value()=='RIGHT')
stretch.step(game,1);assert(stretch.value()=='FULL WIDTH');x,scale=E.placement(64,96,160);assert(x==0 and math.abs(scale-160/96)<.0001)
assert(game.options.modOptions.battleuicustomizer.menu_align==2 and game.options.modOptions.battleuicustomizer.menu_stretch==1)
stretch.step(game,1);assert(stretch.value()=='NORMAL')
local G=love.graphics
local original=G.setColor
local recorded
G.setColor=function(r,g,b,a)
  if type(r)=='table' then r,g,b,a=r[1],r[2],r[3],r[4] end
  recorded=a
  return original(r,g,b,a)
end
local before=G.setColor
E.faded(function() G.setColor(1,1,1,1); assert(recorded==1) end)
assert(G.setColor==before)
local ok=pcall(E.faded,function() error('test render error') end)
assert(not ok and G.setColor==before,'alpha scope must restore after an error')
local rects=0
local rectangle=G.rectangle
G.rectangle=function(...) rects=rects+1; return rectangle(...) end
E.panel(0,96,160,48,false)
assert(rects==(arg[2]=='cached' and 5 or 4),'Emerald frame renders its layers')
if GV.generation()==3 then
  local C=require('src.ui.game3.battle_chrome')
  assert(C.drawSafariBox(0,0)==true,'Safari backplate contract')
  C.drawPanel('menu'); C.drawPanel('moves'); C.drawDoublesBox(true,0,0)
end
for i=1,9 do opacity.step(game,-1) end
assert(opacity.value()=='0%')
opacity.step(game,-1); assert(opacity.value()=='100%')
if submenu then submenu.onChoose(submenu.items[5],submenu);assert(game.child==nil,'back closes child')
elseif not rseMenu then optionsMenu.back();assert(#optionsMenu._pages==1,'back restores parent') end
Runtime.hooks:removeOwner('battleuicustomizer')
for _,entry in ipairs(Runtime.hooks.chains['ui.options.rows'] or {}) do
  assert(entry.owner~='battleuicustomizer','disable removes this mod without disturbing other option hooks')
end
print('PASS settings, alpha error cleanup, theme, disable: '..arg[1])
