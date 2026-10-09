-- Presentation only: customize command placement without changing battle input.
return function(mod)
  local ID = 'battleuicustomizer'
  local G = love.graphics
  local unpack = unpack or table.unpack
  local marker
  local emerald
  local function emeraldArt()
    if emerald ~= nil then return emerald or nil end
    emerald=false
    local CacheFs=require('src.import.CacheFs')
    local root='emerald/data/generated/gba/pokemon/battle/'
    local src=CacheFs.readAt(root..'manifest.lua')
    if type(src)~='string' then return nil end
    local chunk=load(src,'@emerald-battle-manifest','t',{})
    local ok,m=pcall(chunk or function() end)
    if not ok or type(m)~='table' then return nil end
    local function image(file,w,h)
      local rgba=CacheFs.readAt(root..file..'.rgba')
      if type(rgba)~='string' or #rgba~=w*h*4 then return nil end
      local data=love.image.newImageData(w,h,'rgba8',rgba)
      local img=G.newImage(data); img:setFilter('nearest','nearest'); return img
    end
    local w,h=m.textboxW or 256,m.textboxH or 512
    local textbox=image('textbox',w,h)
    if not textbox then return nil end
    emerald={textbox=textbox,quad=G.newQuad(0,112,240,48,w,h),
      player=image('healthbox_player',128,64),enemy=image('healthbox_enemy',128,32)}
    return emerald
  end
  local function setting(key, default)
    local n = tonumber((mod.options:get(key)))
    if n == nil then n = tonumber((mod.save:get(key))) end
    if key == 'style' then return n == 2 and 2 or 1 end
    if key == 'menu_stretch' then return n == 1 and 1 or 0 end
    if key == 'menu_align' then return n == 0 and 0 or n == 1 and 1 or 2 end
    return math.max(0, math.min(100, n or default))
  end
  local function enabled()
    local Runtime = require('src.mods.Runtime')
    local chains = Runtime.hooks and Runtime.hooks.chains
    for _, e in ipairs(chains and chains['ui.options.rows'] or {}) do
      if e.owner == mod.id and e.callback == marker then return true end
    end
    return false
  end
  local compose=assert(load(assert(mod:read('compositor.lua')),'@battle-ui/compositor.lua'))()(G,function() return setting('opacity',100) end)
  local function faded(fn,...)
    return compose(fn,512,192,0,0,...)
  end
  local function placement(x,w,total)
    if setting('menu_stretch',0)==1 then return 0,total/w end
    return (total-w)*setting('menu_align',2)/2,1
  end
  local placementDepth=0
  local function placed(fn,x,w,total,...)
    local dest,scale=placement(x,w,total)
    G.push('all');G.translate(dest-scale*x,0);G.scale(scale,1)
    placementDepth=placementDepth+1
    local result={pcall(fn,...)};placementDepth=placementDepth-1;G.pop()
    if not result[1] then error(result[2],0) end
    return unpack(result,2)
  end
  -- Emerald palette and double frame, drawn at each game's native geometry.
  -- Original artwork; no ROM graphics are distributed.
  local function panel(x,y,w,h, dark)
    local color = {G.getColor()}
    local a = 1
    G.setColor(.20,.29,.28,a); G.rectangle('fill',x,y,w,h)
    G.setColor(.78,.80,.65,a); G.rectangle('fill',x+1,y+1,w-2,h-2)
    G.setColor(.34,.49,.43,a); G.rectangle('fill',x+3,y+3,w-6,h-6)
    if dark then G.setColor(.18,.30,.34,a) else G.setColor(.97,.97,.87,a) end
    G.rectangle('fill',x+5,y+5,w-10,h-10)
    -- Reuse the user's imported Emerald battle frame when available. Keep the
    -- native game's text contrast and geometry inside the original frame.
    local art=emeraldArt()
    if art then
      G.setColor(1,1,1,a)
      G.draw(art.textbox,art.quad,x,y,0,w/240,h/48)
      if dark then G.setColor(.18,.30,.34,a) else G.setColor(.97,.97,.87,a) end
      G.rectangle('fill',x+6,y+6,w-12,h-12)
    end
    G.setColor(unpack(color))
  end
  local function persist(ctx,key,value)
    local game = ctx.game or ctx
    local options = ctx.options or game.options or (game.save and game.save.options)
    assert(options, 'Battle UI: missing options storage')
    options.modOptions = options.modOptions or {}
    local bucket = options.modOptions[ID] or {}
    options.modOptions[ID] = bucket
    bucket.style = setting('style',1); bucket.opacity = setting('opacity',100)
    bucket.menu_stretch=setting('menu_stretch',0);bucket.menu_align=setting('menu_align',2)
    bucket[key] = value
    if game.mods then game.mods.modOptions[ID] = bucket end
    if game.save and game.save.options then game.save.options.modOptions = options.modOptions end
    mod.save:set(key,value)
    if game.writeOptions then game:writeOptions() end
    return false
  end
  local function rows(out)
    for _, r in ipairs(out) do if r.id == ID..':style' then return out end end
    out[#out+1] = {id=ID..':style',label='BATTLE UI',
      value=function() return setting('style',1)==2 and 'EMERALD' or 'VANILLA' end,
      step=function(ctx) return persist(ctx,'style',3-setting('style',1)) end}
    out[#out+1] = {id=ID..':opacity',label='BATTLE OPACITY',
      value=function() return tostring(setting('opacity',100))..'%' end,
      step=function(ctx,dir)
        return persist(ctx,'opacity',(setting('opacity',100)+(dir<0 and -10 or 10))%110)
      end}
    out[#out+1] = {id=ID..':menu_stretch',label='BATTLE MENU WIDTH',
      value=function() return setting('menu_stretch',0)==1 and 'FULL WIDTH' or 'NORMAL' end,
      step=function(ctx) return persist(ctx,'menu_stretch',1-setting('menu_stretch',0)) end}
    out[#out+1] = {id=ID..':menu_align',label='BATTLE MENU ALIGN',
      value=function() return ({'LEFT','CENTER','RIGHT'})[setting('menu_align',2)+1] end,
      step=function(ctx,dir) return persist(ctx,'menu_align',(setting('menu_align',2)+(dir<0 and -1 or 1))%3) end}
    return out
  end
  marker=function(nextFn,game,out) return rows(nextFn(game,out)) end
  mod.hooks:wrap('ui.options.rows',marker,620)
  if mod.generation == 3 then
    local Rows = require('src.ui.game3.option_rows')
    local build = Rows.build
    Rows.build = function(...) local out=build(...); return enabled() and rows(out) or out end
    local C = require('src.ui.game3.battle_chrome')
    local nativeFrames=C.drawMenuFrames
    local Ui=require('src.core.game3.battle.ui')
    local drawing,command=nil,nil
    local nativeUi=Ui.draw
    Ui.draw=function(...)
      local priorDrawing,priorCommand=drawing,command
      drawing,command=true,nil
      local result={pcall(nativeUi,...)}
      drawing,command=priorDrawing,priorCommand
      if not result[1] then error(result[2],0) end
      return unpack(result,2)
    end
    local F=require('src.ui.game3.frlg_font')
    local fontDraw=F.draw
    F.draw=function(text,x,y,...)
      if not enabled() or not command or y<112 then return fontDraw(text,x,y,...) end
      if x<120 then return end -- discard the unused action prompt
      local result={placed(fontDraw,120,120,240,text,x,y,...)}
      command=command+1;if command>=4 then command=nil end
      return unpack(result)
    end
    for _,spec in ipairs({{'src.ui.game3.window','cursorPx'},{'src.ui.game3.rs.menu_cursor','draw'}}) do
      local target=require(spec[1]);local native=target[spec[2]]
      target[spec[2]]=function(x,y,...)
        if enabled() and command and x>=120 and y>=112 then return placed(native,120,120,240,x,y,...) end
        return native(x,y,...)
      end
    end
    for _,name in ipairs({'drawPanel','drawMenuFrames','drawEnemyBox','drawPlayerBox','drawDoublesBox','drawSafariBox'}) do
      local original = C[name]
      if original then C[name] = function(...)
        if not enabled() then return original(...) end
        local args = {...}
        if name=='drawMenuFrames' then return end
        if name=='drawPanel' and args[1]=='menu' then
          if drawing then command=0 end
          return placed(function()
            return faded(function()
              if setting('style',1)==2 then panel(120,112,120,48,false)
              else
                G.setScissor(120,112,120,48)
                original(unpack(args));nativeFrames(unpack(args))
              end
            end)
          end,120,120,240)
        end
        if setting('style',1)==1 then
          return faded(function()
            local result=original(unpack(args))
            if name=='drawPanel' then nativeFrames(unpack(args)) end
            return result
          end)
        end
        return faded(function()
        if name=='drawPanel' then
          local mode=args[1]
          panel(0,112,mode=='menu' and 120 or mode=='moves' and 160 or 240,48,mode~='moves')
          if mode=='menu' then panel(120,112,120,48,false)
          elseif mode=='moves' then panel(160,112,80,48,false) end
        else
          local x,y=args[1],args[2]
          if name=='drawDoublesBox' then x,y=args[2],args[3] end
          local art=emeraldArt()
          local img=art and (name=='drawEnemyBox' and art.enemy or art.player)
          if img and name~='drawDoublesBox' and name~='drawSafariBox' then
            local color={G.getColor()}
            G.setColor(1,1,1,1); G.draw(img,x,y)
            G.setColor(unpack(color))
          else panel(x,y,128,name=='drawEnemyBox' and 32 or name=='drawDoublesBox' and 32 or 40,false) end
          if name=='drawSafariBox' then return true end
        end
        end)
      end end
    end
  else
    local Font=require('src.render.Font')
    local Renderer=require('src.render.Renderer')
    local protected=setmetatable({}, {__mode='k'})
    local queue
    local begin=Renderer.beginFrame
    Renderer.beginFrame=function(self,...)
      protected=setmetatable({}, {__mode='k'})
      return begin(self,...)
    end
    local blit=Renderer.blitCanvas
    local function outside(z,r)
      local l,t=math.max(z.x,r.x),math.max(z.y,r.y)
      local right,bottom=math.min(z.x+z.w,r.x+r.w),math.min(z.y+z.h,r.y+r.h)
      if right<=l or bottom<=t then return {z} end
      local out={}
      local function add(x,y,w,h)
        if w<=0 or h<=0 then return end
        local copy={};for k,v in pairs(z) do copy[k]=v end
        copy.x,copy.y,copy.w,copy.h=x,y,w,h;out[#out+1]=copy
      end
      add(z.x,z.y,z.w,t-z.y);add(z.x,bottom,z.w,z.y+z.h-bottom)
      add(z.x,t,l-z.x,bottom-t);add(right,t,z.x+z.w-right,bottom-t)
      return out
    end
    Renderer.blitCanvas=function(self,canvas,sx,sy,zones,...)
      local rects=enabled() and protected[canvas]
      if rects and #rects>0 and zones and #zones>0 then
        local merged={}
        for _,z in ipairs(zones) do merged[#merged+1]=z end
        -- Do not paint a tinted copy underneath a translucent true-color
        -- copy. Exclude panels from every native zone before their one blit.
        for _,r in ipairs(rects) do
          local clipped={}
          for _,z in ipairs(merged) do
            for _,piece in ipairs(outside(z,r)) do clipped[#clipped+1]=piece end
          end
          merged=clipped
        end
        for i,r in ipairs(rects) do
          local pieces={r}
          for j=1,i-1 do
            local clipped={}
            for _,z in ipairs(pieces) do
              for _,piece in ipairs(outside(z,rects[j])) do clipped[#clipped+1]=piece end
            end
            pieces=clipped
          end
          for _,piece in ipairs(pieces) do merged[#merged+1]=piece end
        end
        zones=merged
        local opaque=self.uiOpaque;self.uiOpaque=false
        local result={pcall(blit,self,canvas,sx,sy,zones,...)}
        self.uiOpaque=opaque
        if not result[1] then error(result[2],0) end
        return unpack(result,2)
      end
      return blit(self,canvas,sx,sy,zones,...)
    end
    local function protect(x,y,w,h)
      local canvas=G.getCanvas()
      if not canvas then return end
      local x1,y1=G.transformPoint(x,y)
      local x2,y2=G.transformPoint(x+w,y+h)
      local left,top=math.min(x1,x2),math.min(y1,y2)
      local right,bottom=math.max(x1,x2),math.max(y1,y2)
      local cx,cy,cw,ch=G.getScissor()
      if cx then
        left,top=math.max(left,cx),math.max(top,cy)
        right,bottom=math.min(right,cx+cw),math.min(bottom,cy+ch)
      end
      if right<=left or bottom<=top then return end
      protected[canvas]=protected[canvas] or {}
      protected[canvas][#protected[canvas]+1]={colors=false,x=left,y=top,w=right-left,h=bottom-top}
    end
    local B = require(mod.generation==2 and 'src.ui.gen2.BattleState' or 'src.battle.BattleState')
    local method = mod.generation==2 and 'drawBottom' or 'drawTextArea'
    local draw = B[method]
    local mode, battle, wide = nil,nil,false
    local function commandMenu() return battle and battle.phase=='menu' and not battle.safari and not battle.contest end
    local function moves() return battle and (battle.phase=='moves' or battle.phase=='moveSelect') end
    local function skip(x,y,w,h)
      -- The TYPE/PP box ends one tile into the move list. In docked layouts
      -- its contents are outside the clip, leaving just this orphan border.
      if wide and commandMenu() and x==0 and y==13 and w==20 then return true end
      if moves() and x==0 and y==8 and w==11 and h==5 then return true end
      -- Full-width message paper is unused behind command and move selection.
      return battle and y==12 and x==0 and w>=20 and h==6
        and (battle.phase=='menu' and not battle.safari or moves())
    end
    local function boxWrapper(target,name)
      local original=target[name]
      target[name]=function(x,y,w,h,...)
        if not mode or (wide and y<13) then return original(x,y,w,h,...) end
        if skip(x,y,w,h) then G.setColor(0,0,0,1); return end
        if mode=='text' then G.setColor(0,0,0,1); return end
        local args={...}
        local function background()
          if setting('style',1)==2 then
            local prior=mode; mode='box'
            local ok,err=pcall(panel,x*8,y*8,w*8,h*8,false); mode=prior
            if not ok then error(err,0) end
          else
            local prior=mode; mode='box'
            local result={pcall(original,x,y,w,h,unpack(args))}; mode=prior
            if not result[1] then error(result[2],0) end
          end
        end
        if wide and commandMenu() then
          placed(function() faded(background);protect(x*8,y*8,w*8,h*8) end,160,144,304)
        elseif wide then faded(background) else background() end
        if wide and not commandMenu() then protect(x*8,y*8,w*8,h*8)
        elseif not wide and queue then queue[#queue+1]={x*8,y*8,w*8,h*8} end
        G.setColor(0,0,0,1)
      end
    end
    if mod.generation==2 then boxWrapper(require('src.ui.gen2.Chrome'),'box')
    else boxWrapper(Font,'drawBox') end
    -- Remove native paper patches and border-repair glyphs on move selection.
    local textDraw=Font.draw
    Font.draw=function(text,x,y,...)
      if enabled() and wide and commandMenu() and y>=112 and placementDepth==0 then
        if x<160 then return end
        return placed(textDraw,160,144,304,text,x,y,...)
      end
      return textDraw(text,x,y,...)
    end
    if mod.generation==2 and B.printMessage then
      local message=B.printMessage
      B.printMessage=function(self,...)
        if battle==self and commandMenu() then return end
        return message(self,...)
      end
    end
    local code=Font.drawCode
    Font.drawCode=function(c,x,y,...)
      if mode=='background' then return end
      if mode=='text' and moves() and ((x==32 and y==96) or (x==80 and y==96))
        and (c==Font.BORDER.h or c==Font.BORDER.br) then return end
      if enabled() and wide and commandMenu() and y>=112 and placementDepth==0 then
        if x<160 then return end
        return placed(code,160,144,304,c,x,y,...)
      end
      return code(c,x,y,...)
    end
    local function run(self,...)
      local args={...}
      local priorBattle,priorMode=battle,mode
      battle=self
      local priorQueue=queue; queue={}
      local originalDraw,rectangle,print,printf=G.draw,G.rectangle,G.print,G.printf
      local function restore()
        G.draw,G.rectangle,G.print,G.printf=originalDraw,rectangle,print,printf
        battle,mode=priorBattle,priorMode
        queue=priorQueue
      end
      local ok,err=pcall(function()
        -- Draw boxes at full opacity into one surface, including their overlaps.
        faded(function()
          mode='background'
          G.draw=function(...) if mode=='box' then return originalDraw(...) end end
          G.rectangle=function(...) if mode=='box' then return rectangle(...) end end
          G.print=function(...) if mode=='box' and print then return print(...) end end
          G.printf=function(...) if mode=='box' and printf then return printf(...) end end
          draw(self,unpack(args))
          G.draw,G.rectangle,G.print,G.printf=originalDraw,rectangle,print,printf
        end)
        for _,rect in ipairs(queue) do protect(unpack(rect)) end
        G.draw,G.print,G.printf=originalDraw,print,printf
        -- Text is drawn once at full opacity, without opaque paper rectangles.
        G.rectangle=function() end
        mode='text'; draw(self,unpack(args))
      end)
      restore()
      if not ok then error(err,0) end
    end
    B[method]=function(self,...)
      if not enabled() then return draw(self,...) end
      if self.phase=='menu' and not self.safari and not self.contest then
        local ox=mod.generation==2 and (tonumber((...)) or 0) or 0
        return placed(run,64+ox*8,96,160+ox*8,self,...)
      end
      return run(self,...)
    end
    if mod.generation==1 then
      local zonePass=B.drawZonePass
      B.drawZonePass=function(self,source,sx,sy,...)
        local rects=enabled() and protected[source]
        if not rects or #rects==0 then return zonePass(self,source,sx,sy,...) end
        local originalDraw,rectangle=G.draw,G.rectangle
        local function regions()
          local x,y,w,h=G.getScissor()
          if not x then x,y,w,h=0,0,source:getWidth(),source:getHeight() end
          local area={x=x,y=y,w=w,h=h}
          local pieces={area}
          local plain={}
          for _,r in ipairs(rects) do
            local moved={x=r.x+(sx or 0),y=r.y+(sy or 0),w=r.w,h=r.h}
            local nextPieces={}
            for _,p in ipairs(pieces) do
              local l,t=math.max(p.x,moved.x),math.max(p.y,moved.y)
              local right,bottom=math.min(p.x+p.w,moved.x+moved.w),math.min(p.y+p.h,moved.y+moved.h)
              if right>l and bottom>t then plain[#plain+1]={x=l,y=t,w=right-l,h=bottom-t} end
              for _,q in ipairs(outside(p,moved)) do nextPieces[#nextPieces+1]=q end
            end
            pieces=nextPieces
          end
          return area,pieces,plain
        end
        local function clipped(fn,args,includePlain)
          local area,pieces,plain=regions()
          local shader=G.getShader()
          for _,r in ipairs(pieces) do
            G.setScissor(r.x,r.y,r.w,r.h);fn(unpack(args))
          end
          if includePlain then
            G.setShader()
            for _,r in ipairs(plain) do
              G.setScissor(r.x,r.y,r.w,r.h);fn(unpack(args))
            end
          end
          G.setShader(shader);G.setScissor(area.x,area.y,area.w,area.h)
        end
        G.draw=function(image,...)
          if image~=source then return originalDraw(image,...) end
          return clipped(originalDraw,{image,...},false)
        end
        G.rectangle=function(...)
          return clipped(rectangle,{...},false)
        end
        local result={pcall(zonePass,self,source,sx,sy,...)}
        G.draw,G.rectangle=originalDraw,rectangle
        if not result[1] then error(result[2],0) end
        -- The native whole-screen zone and message zone overlap. Redraw
        -- protected source regions once after all native zones have finished.
        local unique={}
        for _,r in ipairs(rects) do
          local pieces={r}
          for _,previous in ipairs(unique) do
            local nextPieces={}
            for _,p in ipairs(pieces) do
              for _,q in ipairs(outside(p,previous)) do nextPieces[#nextPieces+1]=q end
            end
            pieces=nextPieces
          end
          for _,p in ipairs(pieces) do unique[#unique+1]=p end
        end
        G.push('all');G.setShader();G.setColor(1,1,1,1)
        G.setBlendMode('alpha','premultiplied')
        for _,r in ipairs(unique) do
          local x,y=r.x+(sx or 0),r.y+(sy or 0)
          G.setScissor(x,y,r.w,r.h)
          originalDraw(source,sx or 0,sy or 0)
          protect(x,y,r.w,r.h)
        end
        G.pop()
        return unpack(result,2)
      end
      local Wide=require('src.battle.WideBattle')
      local native=Wide.draw
      Wide.draw=function(self,...)
        if not enabled() then return native(self,...) end
        local priorMode,priorBattle=mode,battle
        mode,battle,wide='wide',self,true
        local result={pcall(native,self,...)}
        mode,battle,wide=priorMode,priorBattle,false
        if not result[1] then error(result[2],0) end
        return unpack(result,2)
      end
    end
  end
  mod.exports = {setting=setting, panel=panel, faded=faded, placement=placement}
end
