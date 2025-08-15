pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--     m i c r o   m u r d e r
--   but it's robots so it's ok.

-- todo: 

tick,wind,ccsize=0,0,1

ai_fly_iter=2
helpi,helpc=1,0
colfade={0,1,0,1,2,1,2,14,8}

helptext={
 "but it's robots so it's ok",
 "(really, it's ok)",
	"a game by tic tac toad",
	"copyright (c) 2017",
	"-= how to play =-",
	"⬅️➡️ walk , ❎ jump  ",
	"⬆️⬇️ change aiming angle  ",
	"hold 🅾️ for action menu ",
	"while holding 🅾️:",
	"⬅️➡️ pan map   ",
	"⬆️ select weapon  ",
	"hold ⬇️ to start shot ",
	"release to fire",
	"...",
	"follow @ilkkke + @kometbomb",
	"♥ for more nice things ♥",
	"...",
}

watercolor={
	8,14,
	9,10,
	8,14,
	12,7
}

-- 0=none 1=slight 2=normal 3=mega
windscale,menuflyout,totalmen=1,-0.5,4
holes,bombs,parts,men,weap={},{},{},{},{}

--tilebase=128

message,messagec="",0

scrollx,scrolly=128,64

targetx,targety=128,64

windpos=0

robottypes={
	{c=12,s=32, l=64, w=48, name="bluteks"},
	{c=8, s=33, l=65, w=49, name="r3dl3dz"},
	{c=10, s=34, l=66, w=50, name="yolx"},
	{c=11, s=35, l=67, w=51, name="greengoz"}
}

teams={
	{r=1,ai=false,score=0},
	{r=2,ai=true,score=0}
}

stars={}

seedchars=".abcdefghijklmnopqrstuvwxyz"
levelseed={}
seedc=1

-- eh forgot this name was taken
--addmenuitem=menuitem
menuitem=1

-- 0 move, 1 bomb flying, 
-- 2 splode, 3 damage

bombtype={
	{s=4,p=8,d=5,aicost=1.1,name="mortar"},
	{s=20,p=8,d=4,timer=1,ttl=60,split=4,splitbt=1,aicost=3.5,name="cluster"},
	{s=36,p=14,d=5,timer=1,ttl=120,aicost=3.5,name="grenade"},
	{s=52,p=12,d=6,aicost=1.8,name="big bomb"},
	{s=68,p=10,d=0.125,h=5,aicost=1.3,name="digger"},
	{s=84,p=26,d=4,aicost=32,ttl=150,timer=1,name="nuke"},
	--{s=84,p=0,d=0,aiwt=0.1,aicost=16,ttl=150,split=8,splitbt=8,name="napalm"},
	--{s=96,p=4,d=2,e=0,aiwt=0.1,timer=3,aicost=16,ttl=60,name=""},
}

--[[
function capmap()
	local temp=state
	local tempx=scrollx
	local tempy=scrolly
	hidehud=true
	state=1
	for y=-4,12,16 do
	for x=0,64,16 do
		scrollx = x*8+32
		scrolly = y*8+16
		cls()
		_draw()
		flip()
		extcmd("screen")
	end
	end
	state=temp
	scrollx=tempx
	scrolly=tempy
	hidehud=false
end

addmenuitem(1,"capture map",capmap)
--]]

function smallmap()

	for y=0,30 do
		for x=0,127 do
			local mx,my=x*72/128,y*18/32
			local tile=mget(mx,my)
			if tile>0 then
				local sx,sy=tile%16*8,flr(tile/16)*8
				pset(x,y+53,sget(sx+(mx-flr(mx))*8,sy+(my-flr(my))*8))
			else
				pset(x,y+53,0)
			end			
		end
	end
	-- border
	rect(0,52,127,84,12)
	color(7)
	pset(0,52)
	pset(127,52)
	pset(0,84)
 pset(127,84)
end

function prettymap()
	for y=0,18 do
		for x=0,72 do
				if mget(x,y) > 0 then 
					mset(x,y,gettile(x,y))
				end
		end
	end
end

function gettile(x,y)

	-- figure out bitmask
	
	local mask = 0
		
	if mget(x,y-1) > 0 then
		-- north has tile
		mask = 1
	end
	
	if mget(x+1,y) > 0 then
		-- east has tile
		mask += 2
	end
	
	if mget(x,y+1) > 0 then
		-- south has tile
		mask += 4
	end
	
	if mget(x-1,y) > 0 then
		-- west has tile
		mask += 8
	end

	-- check out spritesheet
	-- at sprites 48-63
	
	if mask==15 and rnd()<0.15 then
		local f=rnd()
		return 112+tilebase*4+f*f*3
	end
	
	return tilebase*16+128 + mask
	
end

function genmap()
	local seedsum,x = 0,7.13
	
	for i in all(levelseed) do
		x*=i
		seedsum += x
	end
	
	srand(seedsum)
	tilebase=flr(rnd(4))
	local f,p={},{}

	 --for i=1,256 do
		--permutation[i]=flr(rnd(256))
	 --end

	 for i=0,255 do
	  local t,pm=shr(i,8),flr(rnd(256))
	  f[t],p[i],p[256+i]=t*t*t*(t*(t*6-15)+10),pm,pm
	 end

	local function lerp(t,a,b)
		return a+t*(b-a)
	end

	local function grad(hash,x,y,z)
		local h,u,v,r=band(hash,15),x,z

		if h>=8 then 
			u=y 
		end

		if h<4 then 
			v=y 
		elseif h==12 or h==14 then 
			v=x 
		end

		if band(h,1)==0 then 
			r=u 
		else 
			r=-u 
		end

		if band(h,2)==0 then 
			r+=v 
		else 
			r-=v 
		end

		return r
	end

	function noise(x,y,z)
	--y,z=y or 0,z or 0

		local xi,yi,zi=band(x,255),band(y,255),band(z,255)
		x,y,z=band(x,0x0.ff),band(y,0x0.ff),band(z,0x0.ff)
		local u,v,w=f[x],f[y],f[z]
		local a,b =p[xi  ]+yi,p[xi+1]+yi
		local aa,ab,ba,bb=p[a   ]+zi,p[a+1 ]+zi,p[b   ]+zi,p[b+1 ]+zi
		local xx,yy,zz=x-1,y-1,z-1
		return lerp(w,lerp(v,lerp(u,grad(p[aa  ],x  ,y  ,z  ),
								  grad(p[ba  ],xx,y  ,z  )),
						   lerp(u,grad(p[ab  ],x  ,yy,z  ),
								  grad(p[bb  ],xx,yy,z  ))),
					lerp(v,lerp(u,grad(p[aa+1],x  ,y  ,zz),
								  grad(p[ba+1],xx,y  ,zz)),
						   lerp(u,grad(p[ab+1],x  ,yy,zz),
								  grad(p[bb+1],xx,yy,zz))))
	end
 
	local z,scl,lscl,c,cs,bn=
	rnd(),rnd(2)+0.5,rnd(5)+6,flr(rnd(2)+0.5),
	rnd(0.5)+0.15,rnd(0.2)+0.45
	
	if c==0 then
		cs=0
	end
 
	--cls()
	--print("x="..xscl.." y="..yscl.." l="..lscl,0,0,7)
	
	for y=0,18 do 
		for x=0,71 do 
			n=bn
			for i=1,4 do
				n+=noise(x/scl/8*i,y/scl/4*i,z)/(i)
			end
			mset(x,y,n< (y/10-0.2-cos(x/72*c)*cs) and 1)
		end
	end
	
	prettymap()
	
	local girders = tilebase == 3 and 1 or rnd(6)
	
	
	for i=1,girders do 
		local direction,length,tries=
			flr(rnd(2))*2-1,rnd(5)+2,0
		
		while tries<150 do
			tries+=1
			local x,y=rnd(60)+5,rnd(17)
			if mget(x,y)>0 and 
				--mget(x+direction,y-1)==0 and 
				mget(x+direction,y)==0 then
				for l=1,length do
					mset(x,y,96)
					x+=direction
				end
				break
			end
		end
	end

	smallmap()
	--stop()
end

function drawlevelscreen()

	text("combat sector:",37,88,12,0)

	rectfill(43,95,84,102,0)

	for i=1,#levelseed do
		txt=sub(seedchars,levelseed[i],levelseed[i])
		text(txt, 60-#levelseed*2+i*4, 96, seedc == i and 8 or 9, 0)
	end

	text(" ⬅️➡️⬆️⬇️=edit ❎=random 🅾️=ok", 2, 114, menuitem == 4 and 7 or 9, 0)
end

function udlevelscreen()
	if btnp(5) then
		randseed()
		genmap()
		--smallmap()
	elseif btnp(0) then
		seedc = max(1,seedc-1)
	elseif btnp(1) then
		seedc = min(#levelseed,seedc+1)
	elseif btnp(2) then
		levelseed[seedc] = (levelseed[seedc] - 2 + #seedchars) % #seedchars + 1
		genmap()
		--smallmap()
	elseif btnp(3) then
		levelseed[seedc] = (levelseed[seedc]) % #seedchars + 1
		genmap()
		--smallmap()
	end

	if btnp(4) then
		startgame()
	end
end

function initai()
	aistate={
		working=false,
		x=cman.x,
		ox=cman.x,
		y=cman.y,
		oy=cman.y,
		d=cman.d,
		dx=0,
		dy=0,
		mx=0,
		bt=cman.bt,
		a=cman.a,
		p=cman.p,
		bomb={},
		score=0
	}
	ai={x=cman.x,a=cman.a,p=cman.p,score=-1,bt=cman.bt}
end

function startai(cman,mx,a,p,bt,j)
	
	ai_shots+=1
	--printh("startai")
	--ai_fly_iter=max(3,rnd(min(6,30-statetime/30)+2))
	aistate.working=true
	aistate.dmg=0
	aistate.ground =true
	aistate.dmgscore=0
	aistate.bomb=nil
	aistate.bombs={}
	aistate.x=cman.x
	aistate.ox=cman.x
	aistate.px=cman.x
	aistate.y=cman.y
	aistate.j=j
	aistate.oy=cman.y
	aistate.py=cman.y
	aistate.dx=0
	aistate.dy=0
	aistate.mx=mx
	aistate.p=p
	aistate.a=a
	aistate.score=-1
	aistate.bt=bt
	aistate.cman=cman
end

function levelscreen()

	drawbg()
 drawlogo()

	state=9
	genmap()

end

function drawbg()
		for x=0,16 do
			for y=0,16 do
				spr(72-rnd(1.001),x*8-4,y*8-4)
			end
		end
end

function drawlogo()
	spr(69,96,0)
	spr(192,16,8,12,4)
end

function startgame()
	holes={}
	music(-1,250)
	
	while true do	
	men,state,statetime={},0,0
	local tries=0
	for t=1,2 do
		if tries>1000 then
				break
		end
		weap[t]={99,3,3,3,3,1,1,0}
		for m=1,totalmen do
			tries+=1
			if tries>1000 then
				break
			end
			local x,y
			while true do
				x=flr(rnd(33)+38*(t-1))
				y=flr(rnd(18))
				if mget(x,y) == 0 and
				mget(x,y+1) != 0 then
					local f=false
					for i=0,5 do
						if mget(x,y-i) != 0 then
							f=true
						end
					end
					
					for m2 in all(men) do
						if abs(x*8-m2.x)<32 then
							f=true
						end
					end
					
					if not f then break end
				end
			end
			
			add(men,{flash=0,bt=1,team=t,dmg=0,d=1-(t-1)*2,
			dx=0,dy=0,health=100,px=0,py=0,
			x=x*8+4,y=y*8+7,a=0.25+((t-1)*2-1)*0.125,p=2})
		end
	end
	
	if tries<1000 then
		break
	end
	end
	
	for i=1,10 do
		updatemen()
	end
	
	for m in all(men) do
		m.py=m.y
	end

	srand(time())
	beginturn(flr(rnd(2))+1)
end

function setmsg(msg,t,c)
	messagetime=t
	messagec=c
	helpc=1
	message=msg
end

function beginturn(t)
	xcache={}
	ai_shots=0
	last_dm_x=-999
	last_dm_y=-999
	last_dm_m=nil

	power=0
	ts=0.005
	statetime=0
	wind=(rnd(0.1)-0.05)*windscale/2
	state=0
	turn=t
	cman=nil
	
	for i=1,2 do
		teams[i].score=totalmen
	end
	
	for m in all(men) do
		if not m.dead and m.team == 1 then
			teams[2].score-=1
		end
		if not m.dead and m.team == 2 then
			teams[1].score-=1
		end
	end
	
	for m in all(men) do
		if m.team == t and not m.dead then
			cman=m
			-- move to last position
			del(men,m)
			add(men,m)
			break
		end
	end
	
	if teams[1].score==totalmen
	and teams[2].score==totalmen then
	 music(6)
		-- tie!
		state=7
		winner=0
	elseif teams[1].score==totalmen	then
	 music(6)
		state=7
		winner=1
	elseif teams[2].score==totalmen then
	 music(6)
		state=7
		winner=2
	elseif not cman then
		state=7
		winner=(turn-1)==0 and 2 or 1
	else
		resetmen(true)
		initai()
	end	
	
	if state==0 then
		--above code did not
		--find a winner so turn
		--begins
		if not teams[t].ai then
			message = "player "..t.."'s turn"
		else
			message = robottypes[teams[t].r].name.."' turn"
			sfx(14,0) -- ai think
		end
	
		setmsg(message,30,robottypes[teams[t].r].c)
	end
end

function gotomenu()
	state,helpi,helpc=8,1,0
	music(0)
end

function randseed()
	for i=1,10 do
		levelseed[i]=flr(rnd(#seedchars)+1)
	end
end

function _init()
	randseed()
	lut_items=0
	--startgame()
	gotomenu()
	messagetime,menuitem,menuside=0,1,1
	
	for i=1,100 do
		add(stars,{x=rnd(128),y=rnd(128),z=flr(rnd(5))})
	end
	
	for i=1,2 do
		teams[i].score=0
	end

end

function updateparts()
	for p in all(parts) do
		if p.ttl <= 0 then
			del(parts,p)
		else
			p.ttl -= 1
			p.x+=p.dx
			p.y+=p.dy
			if p.t==2 then
				p.dy += 0.1
			end
		end
	end
end

function jump(man)
	if man.ground then
		man.y-=1
		man.dx = cman.d
		man.dy = -2
		return true
	end
	return false
end

local last_dm_x,last_dm_y,last_dm_m,cp_lookups=-999,-999,nil,0

function checkpixel(x,y,nospr,m)
	x,y=flr(x),flr(y)

	if y < 0 or x < 0 or y >160 or x>1023 then
		return 0
	end

	local sx,sy=x/8,y/8
	local tile=mget(sx,sy)

	if nospr and tile == 0 then
		return 0
	end
	
	--[[for h in all(holes) do
		local dx=h.x-x
		local dy=h.y-y
		
		if abs(h.y-y)<=h.r 
			and abs(h.x-x)<=h.r 
			and dx*dx+dy*dy <= h.r*h.r then
			return 0
		end
	end--]]
	
	--print(x.." "..y.." ")
	
	--if m!=last_dm_m or abs(last_dm_x - x)>=ccsize or
	--abs(last_dm_y - y)>=ccsize then
	 
		--last_dm_x,last_dm_y=x,y
		
		--printh("refreshing collision area ("..last_dm_x..","..last_dm_y..")")
		
		--drawmap(last_dm_x-64,last_dm_y-64,1, true or nospr, m)
		
		
		local c=0
		if tile > 0 then 
			c=sget(tile%16*8+x%8,flr(tile/16)*8+y%8)
			if c>0 then
				for h in all(holes) do
					if x>=h.x-h.r and y>=h.y-h.r 
						and x<=h.x+h.r and y<=h.y+h.r then
						local dx,dy=x-h.x,y-h.y
						if dx*dx+dy*dy<=h.r*h.r then
							c=0
							break
						end
					end
				end
			end
		end
		cp_lookups+=1
	--end

	--local c=pget(64+x-last_dm_x,64+(y)-last_dm_y)
	
	if c==0 and not nospr then
		for am in all(men) do
			if am != m then
				if abs(am.x-x)<4 and
				abs((am.y-4)-y)<=4 then
					return 1
				end
			end
		end
	end
	
	return	c
	--return peek(0x6000+((flr(x)+flr(y)*128)/2))
end

function updateman(m,orig)
	if not orig then
		orig=m
	end

	if checkpixel(m.x,m.y,true,orig) == 0 then
		m.px,m.py=m.x,m.y
	end
	
	m.x+=m.dx
	m.y+=m.dy
	local ret =true
	--if mget(m.x/8,flr(m.y)/8) != 0 then
	if checkpixel(m.x,m.y-1,true,orig) == 0 then
		if checkpixel(m.x,m.y,true,orig) > 0 then
			if abs(m.dy) >= 4 then
				m.dmg += flr(abs(m.dy))
			end
			m.y+=1
			m.ground=true
		else
			m.ground=false
		end
	else
		local y=0
		local prevy=m.y
		while checkpixel(m.x,m.y-y-2,true,orig) != 0 do
			m.y=flr(m.y-1)
			y+=1
			
			if y >= 4 then
				if abs(m.dy)+abs(m.dx) >= 4 then
					m.dmg += flr(abs(m.dx)+abs(m.dy))
				end
				m.x = m.px
				m.y = m.py
				ret=false
				break
			end
		end
		m.ground=true
	end
	
	if m.ground then
		m.dy = 0 
		m.dx *= 0.5
	else
		m.dy+=0.15
	end
	
	if m.y >= 160 then
		m.dead = true
		--m.health=0
		--m.dmg=999
		m.y=160
		m.dx=0
		m.dy=0
		ret =false
	end
	
	return ret
end


function updatemen()
	local someonefell = false
	local someonedrowned=false
	for m in all(men) do
		local dy=m.dy
		updateman(m)
		if m.ground and dy > 1 and m.dy == 0 then
			someonefell = true
		end
		if m.y>= 160 and dy > 0.1 then
			someonedrowned=true
		end
		if m.flash > 0 then
			m.flash-=1
		end
	end
	
	if someonefell and state<8 then
		sfx(5)
	end
	
	if someonedrowned and state<8 then
		sfx(13,1) 
	end
end

function bombdmg(x,y,r,dm)
	for m in all(men) do
		local dx=m.x-x
		local dy=(m.y-4)-y
		if abs(dx)+abs(dy) < 64 then
			local d= sqrt(dx*dx+dy*dy)
			local dmg = (r*2.0-d)		
			if dmg > 0 then
				local p = min(2,dmg*dm)
				m.dx += dx/d *p
				m.dy += dy/d *p
				m.dmg+=flr(dmg*dm)
				m.flash=30
			end
		end
	end
end

function splode(x,y,r,dm,pp)

	add(parts,{t=1,dx=0,dy=0,x=x,y=y,ttl=10})

	local rr=r*r
	
	if not pp or pp>0 then
		for i=1,rr/2 do
			local a=rnd()
			add(parts,{t=2,x=x+cos(a)*r,y=y+sin(a)*r,dx=rnd(5)-2.5,dy=rnd(5)-3.5,ttl=rnd(60),c=rnd(16)})
		end
	end
	
	add(holes,{x=x,y=y,r=r})

	local cx=flr((x-r)/8)
	local cy=flr((y-r)/8)
	
	for dx=cx,cx+(r*2/8) do
		for dy=cy,cy+(r*2/8) do
			local xx0=dx*8-x
			local yy0=dy*8-y
			local xx1=dx*8-x+7
			local yy1=dy*8-y+7
			local d0=xx0*xx0+yy0*yy0
			local d1=xx0*xx0+yy1*yy1
			local d2=xx1*xx1+yy0*yy0
			local d3=xx1*xx1+yy1*yy1

			if d0<= rr and d1<= rr 
				and d2<=rr and d3<=rr then
				mset(dx,dy,0)
			end
		end
	end
	
	--stop()
	
	bombdmg(x,y,r,dm)	
	sfx(3)
end

function explodebomb(b,simulate)
	if not simulate 
		--and b.t.e!=0 
	then
		splode(b.x, b.y, b.t.p, b.t.d, b.t.parts)
	else
		bombdmg(b.x, b.y, b.t.p, b.t.d)
	end
	
	if b.t.split then
		for i=1,b.t.split do
			local p = rnd()*0.25+0.5
			--if b.t.e == 0 then
				--p = 0.1
			--end
			fire(b.t.splitbt,b.x,b.y,rnd(),p)
			--if b.t.e == 0 then
				--napalm flames
				--bomb.x=b.x
				--bomb.y=b.y
			--end
			bomb.dx+=b.dx
			bomb.dy+=b.dy
		end
	end
end


function updatebombs(simulate)
	for b in all(bombs) do
		local titer=simulate and ai_fly_iter or 1
		px=b.x
		py=b.y
		for iter=1,titer do
			--[[if b.t.e == 0 then
				b.x+=rnd(2)-1
				b.y+=rnd(2)-1
			end--]]
			b.x+=b.dx
			b.y+=b.dy
			b.dx+=(wind/8)/(max((b.y+32),1)/32+1)
			b.dy += 0.01
		end

		--drawmap(b.x-64,b.y-64,1)
		if checkpixel(b.x,b.y)>0 then
			if not b.t.timer then
				explodebomb(b,simulate)
					
				if not b.h or b.h <= 0 then
					b.dead=1
					del(bombs,b)
				else
					b.h -= 1
				end
			else
					
				local dy,dx=0,0
				for tdy=-2,2 do
					for tdx=-2,2 do
						if checkpixel(b.x+tdx,b.y+tdy)>0 then
							dx-=tdx
							dy-=tdy
						end
					end
				end
				
				--[[if b.t.e == 0 then
					explodebomb(b,simulate)
				end--]]
				
				local d = dx*dx+dy*dy
				b.x=px
				b.y=py					
				if d > 0 then
					d=sqrt(d)
					dx/=d
					dy/=d
					b.x+=dx
					b.y+=dy
					local dot=b.dx*dx+b.dy*dy
					b.dx=(b.dx-1.25*dot*dx)
					b.dy=(b.dy-1.25*dot*dy)
				else
					b.dx *= -0.25
					b.dy *= -0.25
				end
				if not simulate then
					sfx(7)
				end
			end
		end
			
		if b.t.timer then
			b.ttl -= 0.25*titer
			if b.ttl <= 0 then
				explodebomb(b,simulate)
				b.dead=1
				del(bombs,b)
			end
		end

		if b.y>160 then
			b.dead=1
			if not simulate then
				sfx(13)
			end
			del(bombs,b)
		end

		if not simulate 
			--and b.t.e!=0 
		then
			if rnd() < 0.5 then
				add(parts,{x=b.x,y=b.y,dx=rnd(0.2)-0.1,dy=rnd(0.2)-0.1,ttl=rnd(60),c=flr(rnd(7))+1})
			end
		elseif b.x < 0 or b.x>70*8 then
			b.dead=1
		end
	end
	
end

--[[function dist(a,b)
	local dx=a.x-b.x
	local dy=a.y-b.y
	
	if abs(dx)>=128 or abs(dy) >= 128 then
		return 9999
	end
	
	return sqrt(dx*dx+dy*dy)
end--]]

function simulate()
	--printh("start simulate")
	if aistate.x-(aistate.ox+aistate.mx)>0.5 then
		aistate.d = -1
	else
		aistate.d = 1
	end

	--local cycles=0

	if xcache[aistate.mx] then
		aistate.x=xcache[aistate.mx].x
		aistate.y=xcache[aistate.mx].y
	else
		local f=aistate.mx
		while f!=0 and not xcache[f] do
			f-=aistate.d
		end
		
		if f != 0 then
			aistate.x=xcache[f].x
			aistate.y=xcache[f].y
		end
	
		while abs(aistate.x-(aistate.ox+aistate.mx))>=1 do
			--cycles+=1
			aistate.px=aistate.x
			aistate.py=aistate.y
			if aistate.ground then
				--if aistate.j == c then
				--	jump(aistate)
				--else

				--*** this can be and instead of two ifs
				if aistate.x-(aistate.ox+aistate.mx)>0.5 then
					aistate.x -= 1
					aistate.d= -1
				else
					aistate.x += 1
					aistate.d = 1
				end
				--end
			end
			--printh("i:"..c)

			if cp_lookups>200 then 
				--printh("ai timeout from walk")
				return false
			elseif not updateman(aistate,cman) then
				--printh("ai fail from walk")
				--printh(aistate.x..", "..aistate.y)
				aistate.score=-1
				return true
			end
			
			if aistate.ground then
				xcache[flr(aistate.x-aistate.ox)]={x=aistate.x,y=aistate.y}
			end
		
			--c+=1
		end
		
		if not aistate.ground or aistate.dead then
			--printh("ai fail from walk")
			aistate.score=-1
			return true
		end

		--stop()
	end
	
	bomb = aistate.bomb
	bombs = aistate.bombs
	aistate.bomb=nil
	aistate.bombs={}
	
	if #bombs == 0 then
		--printh("ai fires bomb")
		fire(aistate.bt,aistate.x,aistate.y-4,aistate.a,aistate.p)
		aistate.flytime=0
	end

	local maxflytime= 30*4.82
	--printh("mft:"..maxflytime)
	while #bombs>0 and aistate.flytime <maxflytime do
		--cycles+=#bombs
		aistate.flytime+=0.25--*ai_fly_iter
		updatebombs(true)
		
		if cp_lookups>200 and #bombs>0 then
--[[		
			for m in all(men) do
				if m != cman then
					if cman.team != m.team then
						aistate.dmgscore += m.dmg/10
						if m.dmg>=m.health then
							aistate.dmgscore += 50
						end
					else
						aistate.dmgscore -= m.dmg*20
					end
				else
					aistate.dmgscore -= m.dmg*20
				end
			end
--]]
			aistate.bombs = bombs
			aistate.bomb = bomb
			bomb=nil
			bombs={}
			resetmen(true)
			--printh("ai timeout from bomb")
			return false
		end
	end
	
	bombs={}
	
	local score=aistate.dmgscore
	
	for m in all(men) do
		if m==cman then
			local dx,dy=aistate.x-bomb.x,aistate.y-bomb.y
			local d=abs(dx)+abs(dy)
			if d < 64 then
				score -= 200/max(1,d)
			end
		else
			local dx,dy=m.x-bomb.x,m.y-bomb.y
			local d=abs(dx)+abs(dy)
		
			if cman.team != m.team then
				score += 2/max(1,d)+m.dmg*10
			else
				score -= m.dmg*40
			end
		end					
	end

	--	color(7)
	--	print(aim.x)
	--	print(man.x)

	resetmen(true)
	
	if bomb.x < 0 or bomb.x>70*8 then
		aistate.score=-1
		--printh("ai fail from bomb")
		return true
	end
	--	print(aim.x)
	--	print(man.x)
	--	stop()
	
	if aistate.flytime >= maxflytime then
		aistate.score=-1
		--printh("ai fail from bomb")
		return true
	end
	
	aistate.score = 0.1*score/bombtype[aistate.bt].aicost*(1+abs(aistate.mx)*0.001)
	
	--printh("ai score = "..aistate.score)
	
	return true
end

function fired(bt,x,y,dx,dy,p)
	bomb={t=bombtype[bt], 
		ttl=bombtype[bt].ttl,
		x=x+dx*8,
		y=y+dy*8,
		h=bombtype[bt].h,
		dx=dx*p,
		dy=dy*p}
	add(bombs,bomb)
	return bomb
end

function fire(bt,x,y,a,p)
	local dx=cos(a)
	local dy=sin(a)
	
	return fired(bt,x,y,dx,dy,p)
end

function resetmen(movement)
	for m in all(men) do
		m.px=m.x
		m.py=m.y
		m.walking=nil
		
		if movement then
			m.dead=nil
			m.dmg=0
			m.flash=0
			m.dx=0
			m.dy=0
		end
	end
end

function simcycle()
	local tcyc=0
	while tcyc<150 do
	tcyc+=1
	if ai.done then break end
	if not aistate.working then
		local sima,simp,simx,simbt
				
		if ai.score>0 and rnd()<max(0.25,ai.score) then
			simbt=ai.bt
			simx =ai.mx
			sima =ai.a
			simp =ai.p
			local r=flr(rnd(4))
			if r==0 then 
				simbt=flr(rnd(#bombtype))+1
				while weap[turn][simbt] <= 0 do
					simbt=simbt%#bombtype+1
				end					
			elseif r==1 then simx =flr(ai.mx+rnd(64)-32)
			elseif r==2 then sima =ai.a+rnd(0.02)-0.01
			elseif r==3 then simp =min(3,max(0.1, ai.p+rnd(0.02)-0.01)) 
			end
		else 
			simbt=flr(rnd(#bombtype))+1

			--while bombtype[simbt].timer do
			--	simbt=flr(rnd(#bombtype))+1
			--end
					
			while weap[turn][simbt] <= 0 do
				simbt=simbt%#bombtype+1
			end					
					
			--[[if rnd()<0.1 then
				local m
				while true do
					m = men[flr(rnd(#men)) + 1]
					if m.team != cman.team then
						break
					end
				end
				
				sima=(atan2(m.x,m.y)+1)%1
				simp=2.9
				simx=0
				simj=0
			else--]]
			sima=rnd()
			simp=rnd(2.5)+0.3
					--if rnd() < 0.5 then
						simx=flr(rnd(128))-64
					--else
					--	simx=0
					--end
				
			--end
			
			--if rnd()<0.5 then
			--	sima = 0.5 - simp
			--end
			
			
			

			simj=-1
			--end
		end
	
		startai(cman, simx, sima, simp, simbt, simj)
		
	end
	
	if simulate() then
		local s=aistate.score/ai_fly_iter
		if s >= ai.score then
			ai.score = s
			ai.x=aistate.mx+aistate.ox
			ai.mx=aistate.mx
			if aistate.score > 0 then
				ai.p=aistate.p
			else
				ai.p = 0
			end
			ai.a=(aistate.a+1)%1
			ai.bt=aistate.bt
			ai.j=aistate.j
		end
		aistate.working=false
	end
	end
	
	if (rnd() < ai.score*0.1*(statetime/25000)) or
	 (statetime>25*30 and ai.score > 0 and rnd() < 0.2) then
		ai.done = true
		--ai.p=max(0.1,ai.p-rnd(0.075))
		ai.a=(ai.a+rnd(0.015)-0.0075+1)%1
		sfx(-1,0)
		ai.frame=0
	end
end

function _update()
	
	cp_lookups=0

	was_simulating=false
	windpos += wind*30
	
	if state!=8 then
		if messagetime > 0 then
			messagetime -= 1
			helpc=min(10,helpc+1)
		end
	
		if messagetime < 7 then
			helpc-=2
			--stop()
		end
	end

	tick+=1
	resetmen()

	if state == 0 then
		if btn(4,turn-1) then
			if not menuopened then
				menuvisible=true
				sfx(15)
			end
			menuopened=true
		else
			if menuopened then
				sfx(16)
			end
			menuvisible=false
			menuopened=false
		end
	 
		if btn(0,turn-1) or btn(1,turn-1)
		or btn(3,turn-1) or btn(2,turn-1) then
			menuvisible=false
		end			
	
		if menuvisible then
			menuflyout=min(1,menuflyout+0.4)
		else
			menuflyout=max(-0.5,menuflyout-0.4)
		end
	
		if abs(scrollx-targetx)<16 then
			statetime += 1
		end
		
		if cman.dead or cman.dmg > 0 or statetime > 30*30 then
			--statetime=0
			statedelay=30
			state=2
			sfx(-1,0)
			if statetime >= 900 then
				setmsg("out of time!",30,10)
			else
				messagetime=0
			end
			
		else
	
			if not teams[turn].ai or ai.done then
				local ctl=turn-1
				local cj = btnp(5,ctl)
				local cl = btn(0,ctl) and not btn(4,ctl)
				local cr = btn(1,ctl) and not btn(4,ctl)
				local cup = btn(2,ctl) and not btn(4,ctl)
				local cdn = btn(3,ctl) and not btn(4,ctl)
				local cfire = btn(4,ctl) and btn(3,ctl)
				local csl = btn(4,ctl) and btn(0,ctl)
				local csr = btn(4,ctl) and btn(1,ctl)
				local cw = btn(4,ctl) and btnp(2,ctl)
			
				if teams[turn].ai and ai.done then
					cl = cman.x > ai.x
					cr = cman.x < ai.x
					
					if abs(cman.x-ai.x) < 1 then
						cl=false
						cr=false
					end
					
					if not cl and not cr then
						cup = cman.a < ai.a
						cdn = cman.a > ai.a
					else
						cup=false
						cdn=false
					end
					
					if not cl and not cr and
					not cup and not cdn then
						cw=(tick%8)==0 and cman.bt != ai.bt
					else
						cw=false
					end
					
					if abs(cman.a - ai.a) < abs(ts) then
						ts = 0.001
					end
					
					if abs(cman.a - ai.a) < 0.005 then
						cman.a = ai.a
						cup=false
						cdn=false
					end

					cfire = (not cup and not cdn
					and not cl and not cr) 
					and ai.p > power and ai.bt==cman.bt

					if (ai.score <= 0 or ai.p == 0) and not cr and not cl then
						state=2
						statedelay=10
						cfire=false
					end
							
					if power>ai.p then
						power=ai.p+rnd(0.02)-0.01
					end
						
					cj=ai.frame==ai.j
					ai.frame+=1
				end
				
				if csr then
					targetx+=4
					targety=64
				elseif csl then
					targetx-=4
					targety=64
				else
					targetx=cman.x+cos(cman.a)*48
					targety=cman.y+sin(cman.a)*48
				end
			
				cman.walking=false
			
				if cj then
					if (jump(cman)) sfx(1)
				elseif cw then
					cman.bt = cman.bt%#bombtype+1
					sfx(6)
				elseif not cfire and power > 0 then
					-- *** lines above and below can be anded
					if weap[turn][cman.bt] > 0 then
						state=1
						weap[turn][cman.bt]-=1
						fire(cman.bt,cman.x,cman.y-4,cman.a,power)
						sfx(4,0)
					end
				elseif cfire then
					if weap[turn][cman.bt] > 0 then
						if power == 0 then
							sfx(2,0)
						end
						power = min(3,power+0.075)
					end
				elseif cl then
					cman.d=-1
					
					if cman.ground then
						cman.x -= 1
						cman.walking=1
					end
					if cman.a < 0.25 then
						cman.a = 0.5-cman.a
					elseif cman.a > 0.75 then
						cman.a = 0.75-(cman.a-0.75)
					end
				elseif cr then
					cman.d=1
					if cman.ground then
						cman.x += 1
						cman.walking=-1
					end
					if cman.a < 0.75 and cman.a>0.25 then
						cman.a = 0.75-(cman.a-0.75)
					end
				elseif cup then
					cman.a = (cman.a+ts)%1
					ts=min(0.02,ts+0.001)
				elseif cdn then
					cman.a = (cman.a-ts+1)%1
					ts=min(0.02,ts+0.001)
				else
					ts=0.005
				end
				
				if cman.walking and tick%4 == 0 then
					sfx(0)
				end

			else
				
				targetx=cman.x
				targety=cman.y
				if not ai.done then
					was_simulating=true
				end
			end
		end
	elseif state==1 then
		targetx=bomb.x+bomb.dx*16
		targety=bomb.y+bomb.dy*16
		
		if bomb.dead and #bombs==0 then
			targetx=bomb.x
			targety=bomb.y
			state=2
			statedelay=10
		end
	elseif state==2 then
		local gr=true
		
		for m in all(men) do
			if (not m.ground and not m.dead)
				or abs(m.dx)>0.01 then
				gr=false
				break
			end
		end
	
		if gr then
			statedelay-=1
		end
		if statedelay <= 0 then
			state=3
			statedelay=30
		end
	elseif state==3 then
		if statedelay==30 then
			local hd = 0
			for m in all(men) do
				if m.dmg > 0 then
					if m.dmg > hd then
						hd= m.dmg
						targetx=m.x
						targety=m.y
					end
					local t=""..flr(min(m.health,m.dmg))
					m.health=flr(max(0,m.health-m.dmg))
					add(parts,{t=3,x=m.x-#t*2,y=m.y-14,dx=0,dy=-0.25,txt=t,ttl=45,c=8})
					m.dmg=0
					sfx(17)
				end
			end
		end
		statedelay-=1
		if statedelay <= 0 then
			state=4
			statedelay=30
		end
	elseif state==4 then
		if statedelay == 30 then
			had=false
			for m in all(men) do
				if m.health <= 0 or m.y>=160 then
					m.dead = true
					targetx=m.x
					targety=m.y
					had=true
					setmsg("unit offline!",60,8)
					--printh("marked for death")
					break
				end
			end
		end
		
		statedelay-=1
		
		if statedelay <= 0 then
			if not had then
				state=6
				statedelay=10
				--printh("proceeding past kill state")
			else
				--printh("proceeding to kill state")
				sfx(12)
				state=5
				statedelay=30
			end
		end
	elseif state==5 then	
		if statedelay == 30 then
			for m in all(men) do
				if m.dead then
					del(men,m)
					splode(m.x,m.y-4,6,4.0)
					break
				end
			end
		end
		
		statedelay-=1
		
		if statedelay <= 0 then
			state=2
			statedelay=10
		end
		
	elseif state==6 then
		statedelay-=1
		if statedelay <= 0 and not had then
			t=turn
			if t==1 then
				t=2
			else
				t=1
			end
			beginturn(t)
		end
	elseif state==7 then
		if btnp(4) or btnp(5) then
			gotomenu()
		end
	elseif state==9 then
		udlevelscreen()
		--title menu
	elseif state==8 then
		if tick >= 120 then
			tick=0
			helpi=(helpi)%#helptext+1
		elseif tick > 111 then
			helpc-=1
		elseif tick < 9 then
			helpc+=1
		end
		
		if btnp(3) then
			menuitem = min(4,menuitem+1)
			sfx(6)
		elseif btnp(0) then
			menuside = (menuside + #teams)%#teams+1
			sfx(6)
		elseif btnp(1) then
			menuside = (menuside)%#teams+1
				sfx(6)
		elseif btnp(2) then
			menuitem = max(1,menuitem-1)
			sfx(6)
		elseif btnp(4) or btnp(5) then
			sfx(6)
			if menuitem==4 then
				--startgame()
				levelscreen()
			elseif menuitem==3 then
				if btnp(4) then
					if menuside == 1 then
						windscale=max(0,windscale-1)
					else
						totalmen=max(1,totalmen-1)
					end
				else
					if menuside == 1 then
						windscale=min(3,windscale+1)
					else
						totalmen=min(5,totalmen+1)
					end
				end
			elseif menuitem == 1 then
				teams[menuside].ai=not teams[menuside].ai
			elseif menuitem == 2 then
				teams[menuside].r=(teams[menuside].r)%#robottypes+1
				
				for t=1,#teams do
					if t!=menuside then
						if teams[t].r==teams[menuside].r then
							teams[menuside].r=(teams[menuside].r)%#robottypes+1
						end
					end
				end
			end
		end
	end

	--[[if rnd()<0.03 then
		m = men[flr(rnd(#men)+1)]
	add(bombs,{x=m.x,y=m.y,dx=rnd(4)-2,dy=-3})
	end
	--]]
	
	
	if not was_simulating and state~=9 then
		--[[for m in all(men) do
			if m.dmg>0 then
				if rnd()<0.2 then
					add(parts,{t=2,x=m.x+rnd(4)-2,y=m.y-4-rnd(3),dx=rnd(0.4)-0.2,dy=-1.4,ttl=rnd(120),c=9+flr(rnd(2))})
				end
			end
		end
		--]]
	
		updatebombs()
		updatebombs()
		updatebombs()
		updatebombs()
		updateparts()
		updatemen()
	end
	
	scrollx += min(8,max(-8, (targetx-scrollx)/4))
	scrolly += min(8,max(-8, (targety-scrolly)/4))
end

function drawmap(x,y,cl,nospr,skipspr)
	--[[if cl>0 then
		clip(64-ccsize,64-ccsize,ccsize*2,ccsize*2)
		rectfill(64-ccsize,64-ccsize,64+ccsize,64+ccsize,0)
	end--]]
	--cls()
	camera(flr(x),flr(y))
	
	map(x/8,y/8,x-x%8,y-y%8,17,17)
	
		for c in all(holes) do
			--if c.x-x+c.r>0 or c.y-y+c.r>0 or
			--	c.x-x-c.r<128 or c.y-y-c.r<128 then
				circfill(flr(c.x),flr(c.y),c.r,0)
			--end
		end
	
	if not nospr then
		palt(0,false)
		palt(14,true)
		for m in all(men) do
			if not skipspr or skipspr != m then
				local s=robottypes[teams[m.team].r].s
				spr(s,m.x-4,m.y-8)
			end
		end
		palt()
	end
		
	camera()
	clip()
end

function text(str,x,y,c,bc,sc)
	for dx=x-1,x+1 do
		for dy=y-1,y+1 do
			--if dx!=x or dy!=y then
			print(str,dx,dy,bc)
		--end
		end
	end
	if sc then
		local tab={
			{-1,-1},
			{0,-1},
			{1,-1},
			{1,0},
			{1,1},
			{0,1},
			{-1,1},
			{-1,0}
		}
		local i=flr(tick/2)%8+1
		print(str,x+tab[i][1],y+tab[i][2],sc)	
	end
	
	print(str,x,y,c)
end


function drawstars()
	local ctab={7,12,12,6,13,13,2,2,1,1}
	for s in all(stars) do
		local x=(s.x-scrollx/(s.z+2)+1024)%128
		local y=(s.y-scrolly/(s.z+2)+1024)%128
		if (pget(x,y)==0) pset(x,y,ctab[flr(s.z*2)+flr(rnd(2))+1])
	end
end

function drawmenuitem(txt,w,x,y,sel)
	palt(0,false)
	palt(14,true)
	if type(txt)=="string" then
		text(txt,x-#txt*2,y-3,9,0)
	else
		-- robots
		spr(txt,x-8,y-8,1,2)
		spr(txt,x,y-8,1,2,true)
	end
	-- arrows
	local s=sel and 55 or 39
	spr(s, x-w/2-8, y-4)
	spr(s, x+w/2, y-4, 1,1,true)
end

function setflash(enable)
	if enable then
		for i=0,15 do
			pal(i,7)
		end
	else
		for i=0,15 do
			pal(i,i)
		end
	end
end

function _draw()
	if was_simulating and statetime > 1 then
		simcycle()
	end
	
	if state~= 9 then
		-- goddamn this is a mess
		cls()
	end
	
	sx=flr(scrollx-64)
	sy=flr(scrolly-64)
	
	-- not title
	if state<8 then

		-- map
		drawmap(sx,sy,0,true)
		--bg
		drawstars()	
	
	
		-- particles
		for p in all(parts) do
			if p.t == 1 then
				spr(2,p.x-8+rnd(2)-1-sx+(tick%2)*4-2,p.y-8+rnd(2)-1-sy,2,2)
			elseif p.t==3 then
				print(p.txt,p.x-sx,p.y-sy,p.c)
			else
				pset(p.x-sx,p.y-sy,p.c)
			end
		end
	
		-- bombs
		for b in all(bombs) do
			spr(b.t.s,b.x-sx-4,b.y-4-sy)
			if b.t.timer then
				text(flr(b.ttl/30),b.x-2-sx,b.y-9-sy,10,0)
			end
		end
	
		-- bots
		palt(0,false)
		palt(14,true)

		for m in all(men) do

			local s=robottypes[teams[m.team].r].s
			local fx=false
			local fy=false
		
			if m.walking then
				s=robottypes[teams[m.team].r].w
				fx=(tick%4)<2
			end
					
			if m.dy > 0 and m.dmg>0 then
				fy = true
			end
			
			setflash(m.flash > 0 and tick % 2 == 0)		
			spr(s,m.x-sx-4,m.y-8-sy-1,1,1,fx,fy)
			setflash(false)
		end

		palt()
		
	
		
		--bot huds
		for m in all(men) do
			if state==4 then
				-- damage
				if m.dmg > 0 then
					local t=""..flr(m.dmg)
					text(t, m.x-sx-#t*2, m.y-9-6-sy, 8, 0)
				end
			-- think bubble
			elseif state==0 and teams[turn].ai and 
				m==cman and not ai.done then
				spr(37,m.x-sx-9+rnd(1.1),m.y-30-sy+rnd(1.1),2,2)
			elseif state==0 and not teams[turn].ai and m==cman then
				-- active arrow
				spr(23,m.x-sx-4,m.y-11-sy-16+(tick/4%3),1,1)
				-- equipped weapon
				spr(bombtype[cman.bt].s,m.x-sx-4,m.y-11-sy-8-1,1,1)
			end

			-- health bar
			local w=max(0,8*m.health/100-1)
			rect(m.x-4-sx,m.y-13-sy,m.x-4+7-sx,m.y-12-sy,8)
			palt(0,false)
			rect(m.x-4-sx,m.y-11-sy,m.x-4+7-sx,m.y-11-sy,0)
			palt()
			if m.health>0 then
				rect(m.x-4-sx,m.y-13-sy,m.x-4+w-sx,m.y-12-sy,11)
			end			
			--local t=""..flr(m.health)
			--print(t, m.x-sx-#t*2, m.y-9-6-sy-6, 10)
		end

		-- top hud
		if not hidehud then

			--time
			local t=""..flr(max(0,30-statetime/30))
			text(t, 64-#t*2, 8, 11, 0)
		
			--scores
			for i=1,2 do
				--	local bc=0
				--	if (turn==i) bc=2
				t=robottypes[teams[i].r].name
				local x
				local op
				if i==1 then
					x=16
					op=2
				else
					x=112
					op=1
				end
				-- team names
				text(t,x-#t*2,0,robottypes[teams[i].r].c,0)
				--scores
				--t=teams[i].score..""
				--text(t,x-#t*2,8,9,0)
				--remaining units
				t=""
				for i=1,totalmen-teams[op].score do
					 t=t.."-"
				end
				text(t,x-#t*2,4,robottypes[teams[i].r].c,0)
			end

			-- popup menu
			if state==0 and not teams[turn].ai and
			menuflyout and menuflyout>0 then
				local mr=menuflyout*12
				palt(0,false)
				palt(11,true)
				spr(5,cman.x-sx-4,cman.y-sy-8-mr)
				spr(6,cman.x-sx-4,cman.y-sy-8+mr)
				spr(21,cman.x-sx-4-mr,cman.y-sy-8)
				spr(22,cman.x-sx-4+mr,cman.y-sy-8)
				palt()
			end
		
			-- wind indicator
			if wind then
				if abs(wind)>0 then
					if wind < 0 then
						spr(17,64-16-8,0)
					else
						spr(17,64+16,0,1,1,true)
					end
				end
				clip(64-16,0,32,8)
				for i=0,5 do
					spr(7,windpos%8+64-32+i*8,0)
				end
				clip()
				local t=flr(abs(wind)*1000)..""
				text(t,64-#t*2,1,12,0)
			end
		end

		if state==0 then
			tx=cman.x-sx+cos(cman.a)*32
			ty=cman.y-sy-4+sin(cman.a)*32
			
			ptx=cos(cman.a)
			pty=sin(cman.a)
			
			-- power bar
			if power>0 then
				local x=cman.x-sx+ptx*4
				local y=cman.y-sy-4+pty*4
				local ctab={1,2,8,9,10,7}
				for l=0,power,0.1 do
					circfill(x,y,1,ctab[flr(l*6/3)+1])
					x+=ptx
					y+=pty
				end
			end
		
			---crosshair
			palt(0,false)
			palt(11,true)
			
			spr(16,tx-4,ty-4)
			
			palt()
		end

		--water
		--[[
		local water=140+sin(tick/30/2)*4-sy
		if 140+sin(tick/30/2)*4-sy < 128 then
		rectfill(0,water,127,127,8)
		line(0,water,127,water,14)
		end
		--]]

		for x=0,127 do
			local water=140+sin(tick/30/2+(x+sx)/32)*sin(tick/15)*3-sy	
			if water < 128 then
				rect(x,water,x,127,watercolor[tilebase*2+1])
				pset(x,water,watercolor[tilebase*2+2])
			end
		end

		--weapon hud
		if turn and not hidehud then
			rectfill(0,121,127,127,0)
		  
			-- bot thinking
			if teams[turn].ai 
			and not ai.done and state < 7 then
				--  rectfill(0,121,127,127,8)  
				local t="the machines are plotting..."
				--local t=""..ai.score.." "..cp_lookups
				text(t,64-#t*2,122,8,0)
			else
				-- ammo display
				for i=1,#bombtype do
					spr(bombtype[i].s,i*15-17,121)
					local t=weap[turn][i]..""
					text(t,i*15-#t*2-7,122,2,0)
				end
				-- active weapon name        
				if cman then
					local n = bombtype[cman.bt].name
					text(n, 105-#n*2, 122, 9, 0)
					-- highlight active
					t=weap[turn][cman.bt]..""
					text(t,cman.bt*15-#t*2-7,122,12,0)
				end
			end
		end
	end
	
	-- game end
	if state==7 then
		local txt
		if winner==0 then
			txt="mutual destruction"
			text(txt, 64-#txt*2,62,11,0)
			txt="war is hell"
			text(txt, 64-#txt*2,74,8,0)
		else
			if teams[winner].ai then
				txt=robottypes[teams[winner].r].name.." win!"
			else
				txt="player "..winner.." wins!"
			end
			text(txt, 64-#txt*2,70,robottypes[teams[winner].r].c,0)
			for i=1,13 do
				pal(i,0,0)
			end

			palt(0,false)
			palt(14,true)

			local prec = max(0,cos(tick/30))*8

			for dx=-1,1 do
				for dy=-1,1 do
					spr(robottypes[teams[winner].r].l,56+dx,50-prec+dy,1,2)
					spr(robottypes[teams[winner].r].l,64+dx,50-prec+dy,1,2,true)
				end
			end
			--*** look into this, ilkke
			pal()
			palt(0,false)
			palt(14,true)

			spr(robottypes[teams[winner].r].l,56,50-prec,1,2)
			spr(robottypes[teams[winner].r].l,64,50-prec,1,2,true)
		end
	elseif state==9 then
		drawlevelscreen()
 	-- title menu
	elseif state==8 then

		drawbg()
		palt(14,true)		
		drawlogo()
	
		for p=1,2 do
			x=p*64-64+32
			local txt=p==1 and "home team" or "away team"
			text(txt, x-#txt*2, 52, 12, 0)
			--team names
			local r=robottypes[teams[p].r]
			--man or machine
			drawmenuitem((teams[p].ai and "cpu" or "human"), 24, x, 64, (menuside==p and menuitem == 1))
			--team select
			local rt=r.l
			drawmenuitem(rt, 24, x, 78, (menuside==p and menuitem == 2))	
		end
		
		local windnames={
			"calm",
			"breeze",
			"windy",
			"storm"
		}
		
		palt()
		
		text(helptext[helpi],64-#helptext[helpi]*2,41,colfade[helpc+1],0)
		text("weather", 18, 93, 12, 0)
		drawmenuitem(totalmen.." bots", 32, 96, 104, (menuitem == 3 and menuside == 2))
		text("team size", 78, 93, 12, 0)
		drawmenuitem(windnames[windscale+1], 32, 32, 104, (menuitem == 3 and menuside == 1))	
		
		--vs
		spr(0,56,71,2,1)
		
		--start game
		rectfill(0,112,127,120,menuitem == 4 and 8 or 12)
		print("start game", 45, 114, menuitem == 4 and 7 or 0)

		--spr(robottypes[teams[winner].r].s,56,50,1,2)
		--spr(robottypes[teams[winner].r].s,64,50,1,2,true)
		
	end

	-- draw status messages	
	if message and messagetime > 0 then
		text(message,64-#message*2,40,helpc>7 and messagec or colfade[helpc+1], 0)
	end

	-- cpu	
	--	print(stat(0).." "..flr(stat(1)*100).."%",0,109,7)
	-- if state!=8 then
	--	print(state.." ai: "..ai.score.." c: "..flr(stat(1)*100).." h:"..cp_cachehits.." l:"..cp_lookups, 0,115,7)
	--	end

end

--[[

-- title label
function _draw()
	cls()
	palt(14,true)
	palt(0,false)
	for y=0,128,8 do
		line(0,y,127,y,1)
	end
	spr(192,16,16,12,4)
	for i=0,3 do
		spr(64+i,i*32+8,70,1,2)
		spr(64+i,i*32+16,70,1,2,true)
	end
	print("but it's robots so it's ok", 12, 106, 8)
end
--]]
__gfx__
00000000000000000000888888800000000000007777777b7777777b00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0007000707cc70000088888888888000000000007777777077777c7000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000c101c0c000000088888888888880000aaa00077ccc77077777770c0101010ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0001c0c107cc7000088880000088880000a0a00077c7c770777c7770c0101010ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0000c1c00000c000888800000008888000aaa00077ccc77077777770c0101010ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00001c100000c0008880000a0000888000000000777777707c77777000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0000070007cc70008880000a0000888000000000777777707777777000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000000000000088800aaaaa00888000000000b0000000b000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
bb000bbb000007008880000a00008880000000007777777b7777777b88888888ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
bb070bbb0000c0008880000a000088800cc0cc007777c77077c7777018888881ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000c000b000c000088880000000888800cc0cc00777cc77077cc777001888810ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
07c7c70b0070000008888000008888000000000077ccc77077ccc77000188100ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000c000b000c000008888888888888000cc0cc00777cc77077cc777000011000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
bb070bbb0000c00000888888888880000cc0cc007777c77077c7777000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
bb000bbb00000700000088888880000000000000777777707777777000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
bbbbbbbb00000000000000000000000000000000b0000000b000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
e1c77c1e59977995ee9779eeaaeeeeaa000000000000000000000000eeee00eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
7ddccdd788899888e449944eaa3bb3aa0abbba000000000000000000eee0c0eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
1ddccdd187899878e479974e553333550b000b000000000000000000ee0cc0eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
5dd00dd582800828e029920e000110000b0b0b00000c777777777c00e0ccc0eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0011110012222221e949949eeb3bb3be0b000b0000c77777777777c0e00cc0eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ecdcc5ce00822800e402204ee0b00b0e0abbba000077777777777770ee00c0eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ed0000dee900009ee4e00e4ee30ee03e000000000077777777777770eee000eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
e07ee70ee08ee80ee09ee90ee0beeb0e000000000077771717177770eeee00eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
e1c77c1e59977995ee9779eeaaeeeeaa000000000077777777777770eee080eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
7ddccdd788899888e449944eaa3bb3aa088888000077777777777770ee0880eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
1ddccdd187899878e479974e553333550888880000c77777777777c0e08880eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
5dd00dd582800828e029929e000110b008808800000c777777777c00088880eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
001111c012222221e9499404eb3bbb0e088888000000000777000000e08880eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ec5cc50500822890e40220e4e0b0003e088888000000000070000000ee0880eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
e50000ece900008ee4e00ee9e30eeb0e000000000000000000000000eee080eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
e0ceeee0e08eee0ee09eeee0e0bee0ee000000000000000000000000eeee00eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ee15dcc7e5999977eeee4977eeeeeeee00000000eeeeeeeec1111111c1111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
e5ddccc759999977eee49977e9a9eeee00000000eeeeeeee1111111110000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
771dcccc88888899ee24449959995bba00666000eeeeeeee1111111110000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
771ddccc88888899ee42774959a95bba00666000eeeeeeee1111111110000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
115dddcc22772299ee427749311133150066600000eee0001111111110000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
5dddddc798778288ee4411993333313b00000000700e00701111111110000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
5ddddc0288118000ee244497eeeeee11000000000c000c001111111110000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
5dddc00088888299eeeeee99eeeeee550000000000c0c00e1111111110000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
eeeeee1188888288ee99ee99eeeeeeab0ccccc00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
eeeeee1012222222ee992499eaa155bbccccccc0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
eecc557ceeee9818eee4ee22eebbeee3cc777cc0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
eecceecceee882e2ee99ee2eeeebbeeecc777cc0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
eee5eeeeee89eeeeee44eeeeeee3eeeecc777cc0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
eeee5eeeee988eeeee44eeeeeebeeeeeccccccc0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
eeeee5eeeee8282eeee22eeeeee3eeee0ccccc00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
eeeecceeeeee998eeeee99eeeeeebbee00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
7777777776666667ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ddddddddddddddddffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
5115d55d55555555ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0d56ddc000111100ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
006ddc5000555500ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
06ddc55d76666667ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
76666667ddddddddffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
dddddddd11111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
111111111111111111111111ffffffff222222222222222222222222ffffffff555555555555555555555555ffffffff444444444444444444444444ffffffff
111111111111111111111111ffffffff222222222222222222444422ffffffff555555555555555555555555ffffffff44444444457444444c777c44ffffffff
11c11111113a3111113aa311ffffffff224442222224422224200242ffffffff551111555566665556666655ffffffff445544445779444457771754ffffffff
1101111111c0c11111c00c11ffffffff229092222290092229000092ffffffff5500005552dddd252ddddd25ffffffff445544445157944457177d54ffffffff
11111111113c311111c00c11ffffffff229a92222290092229000092ffffffff5500005552dddd252ddddd25ffffffff44444444445179445d665654ffffffff
1111111111000111113cc311ffffffff22222222224aa42229200292ffffffff55dddd55551111552ddddd25ffffffff444444544445177551161144ffffffff
111111111111111111000011ffffffff2222222222222222249aa942ffffffff555555555555555551111155ffffffff444444444444571445112544ffffffff
111111111111111111111111ffffffff222222222222222222222222ffffffff555555555555555552222255ffffffff444444444444415444444444ffffffff
000aa00031111113accccccc311111110000000ac111111c0000000ac1111111ccccccca11111113cccccccc11111111a00000001111111ccccccccc11111111
00c11c00311111300311111103111111000000333111111300000031311111111111113011111130111111111111111113000000111111131111111111111111
0c1111c0311113000031111100311111000003133111111300000311311111111111130011111300111111111111111111300000111111131111111111111111
c111111c311130000003111100031111000031133111111300003111311111111111300011113000111111111111111111130000111111131111111111111111
31111113311300000000311100003111000311133111111300031111311111111113000011130000111111111111111111113000111111131111111111111111
03111130313000000000031100000311003111133111111300311111311111111130000011300000111111111111111111111300111111131111111111111111
00311300330000000000003100000031031111133111111303111111311111111300000013000000111111111111111111111130111111131111111111111111
000cc000c00000000000000c0000000c31111113311111133111111131111111c0000000c0000000333333333333333311111113111111131111111111111111
000aa000a222222499940499422222220000000aa222222a0000000aa222222299404999222222249940499922222222a00000002222222a9940499922222222
00922900422222400424942204222222000000944222222400000092422222222249424022222240224942222222222229000000222222242249422222222222
09222400422244000042222200442222000009244222222400000922422222222222240022224400222222222222222222900000222222242222222222222222
92222299222400000004422200004222000042222222222200004222222222222224400022240000222222222222222222240000222222222222222222222222
42222224022900000000042200009222000042200222222000004222022222222240000022290000222222222222222222240000222222202222222222222222
04422240924000000000092200000422009922299222222900992222922222222290000022400000222222222222222222229900222222292222222222222222
00042400440000000000004200000042092222244222222409222222422222222400000024000000222444222224442222222290222222242222222222222222
00044000400000000000000400000004422222244222222442222222422222224000000040000000444101444441014422222224222222242222222222222222
00066000755555521666166625555555000000077555555700000007755555556661666155555552666166615555555570000000555555576661666155555555
002dd200d55555200ddd2ddd02555555000000ddd555555d000000ddd5555555ddd2ddd055555520ddd2ddd255555555dd0000005555555dddd2ddd255555555
0d2dd2d0d22661000ddd21110016662500000dddd555555d00000dddd55555551112ddd0526661001115ddd555555555ddd000005555555d1115ddd555555555
d551155d122dd0000001dd25000ddd250000ddd1155555510000ddd11555555552dd100052ddd00055551115555555551ddd0000555555515555111555555555
25555552662dd00000001125000ddd2500015d166555555600015d15655555555211000052ddd000555555555555555551d51000555555565555555555555555
06625520dd10000000000255000001550062115dd555555d00621155d555555555200000551000005555555555555555551126005555555d5555555555555555
0dd25200dd00000000000025000000250dd1555dd555555d0dd15555d55555555200000052000000555555555555555555551dd05555555d5555555555555555
00011000100000000000000200000002dd15555115555551dd1555551555555520000000200000002221222222212222555551dd555555515555555555555555
00aaaa0074444442aaaaaaaa244444440000000a744444470000000a44444444aaaaaaaa44444442aaaaaaaa44444444a000000044444444aaaaaaaa44444444
00bbbb0094444420bbbbbbbb0244444400000092944444490000009224444444bbbbbbbb44444420bbbbbbbb444444442900000044444442bbbbbbbb44444444
093bb390944442003bb3bbb300244444000009249444444900000924024444443bbb3bb3444442003bbb3bb34444444442900000444444203bbb3bb344444444
94211249944440000112111200044444000092449444444900009244044444442111211044444000211121114444444444290000444444402111211144444444
24444442942420000002424400024244000924449444444900092444044444444424200044242000444444444444444444429000444444404444444444444444
02444420941000000000014400000144009244449444444900924444244444444410000044100000444444444444444444442900444444424444444444444444
00244200420000000000002400000024092444449444444909244444444444444200000042000000444424424444244244444290444444444444444444444444
00011000000000000000000200000002924444449444444992444444444444442000000020000000122100001221000044444429444444444444444444444444
eeeeeee07000c00000000007100000007cc7cc70000000000007ccc7000000017cccccc7000000007cc7ccc70eeeeeeeffffffffffffffffffffffffffffffff
eeeeeee0cc000000000000cc01000000000c00010000000000c0000100000010c000000c00000001c000000c0eeeeeeeffffffffffffffffffffffffffffffff
eeeeeee0c0c000c000000c0c00100000000c0000100000000c00000100000010c0800b0c00000010c000000c0eeeeeeeffffffffffffffffffffffffffffffff
eeeeeee0c00c00000000c00c00010000000c0000100000007000000100000100c000000c00000100c009900c0eeeeeeeffffffffffffffffffffffffffffffff
eeeeeee0c000c000000c000c00001000000c00000100000070000000000001007ccc7cc700001000c009900c0eeeeeeeffffffffffffffffffffffffffffffff
eeeeeee0c0000c0000c0000c00000100000c0000010000001c00000100001000c0000c0000010000c000000c0eeeeeeeffffffffffffffffffffffffffffffff
eeeeeee0c00000c00c00000c00000000000c00000010000010c0000000000000c00000c000100000c000000c0eeeeeeeffffffffffffffffffffffffffffffff
eeeeeee07000000770000007000000007cc7cc70000000001007ccc70000000070000007000000007cccccc70eeeeeeeffffffffffffffffffffffffffffffff
eeeeeee0010000000100000010000000100000010000000010000001000000010000001000000001000000100eeeeeeeffffffffffffffffffffffffffffffff
eeeeeeee00100000001000000100000001000000100000001000000100000010000001000000001000000100eeeeeeeeffffffffffffffffffffffffffffffff
eeeeeeeee001000000010000001000000100000010000000100000010000001000001000000001000000100eeeeeeeeeffffffffffffffffffffffffffffffff
eeeeeeeeee0010000000100000010000001000000100000010000001000001000001000000001000000100eeeeeeeeeeffffffffffffffffffffffffffffffff
eeeeeeeeeee00100000001000000100000100000010000001000000100000100001000000001000000100eeeeeeeeeeeffffffffffffffffffffffffffffffff
eeeeeeeeeeee001000000010000001000001000000100000100000010000100001000000001000000100eeeeeeeeeeeeffffffffffffffffffffffffffffffff
eeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
7000000cc00000071000000070000007100000007cccccc7000000007ccc7000000000017cccccc7000000017cccccc7ffffffffffffffffffffffffffffffff
cc000000110000cc010000000100000001000000c000000c00000000c0000c0000000010c000000c00000010c000000cffffffffffffffffffffffffffffffff
c0c0000001100c0c001000000010000000100000c0800b0c00000000c00000c000000100c088880c00000100c0800b0cffffffffffffffffffffffffffffffff
c00c00000011c00c000100000001000000010000c000000c00000000c000000700001000c000000c00001000c000000cffffffffffffffffffffffffffffffff
c000c000000c000c0000100070001007000010007ccc7cc700000000c000000c000100007cccccc7000100007ccc7cc7ffffffffffffffffffffffffffffffff
c0000c0000c0000c00000100c100010c10000100c0000c0100000000c000000c00100000c000000000100000c0000c00ffffffffffffffffffffffffffffffff
c00000c00c00000c00000000c010000c01000000c00000c000000000c000000c00000000c000000000000000c00000c0ffffffffffffffffffffffffffffffff
7000000770000007000000007cccccc70010000070000007000000007cccccc7000000007cccccc70000000070000007ffffffffffffffffffffffffffffffff
010000001000000010000000010000001001000010000000100000010000000100000001000000100000000100000010ffffffffffffffffffffffffffffffff
001000000100000001000000001000000100100001000000100000010000001000000010000001000000001000000100ffffffffffffffffffffffffffffffff
e0010000001000000010000000010000001001000100000010000001000000100000010000001000000001000000100effffffffffffffffffffffffffffffff
ee00100000010000000100000000100000010000001000000100001000000100000010000001000000001000000100eeffffffffffffffffffffffffffffffff
eee001000000100000001000000001000000100000100000010000100000010000010000001000000001000000100eeeffffffffffffffffffffffffffffffff
eeee0010000001000000010000000010000001000001000001000010000010000010000001000000001000000100eeeeffffffffffffffffffffffffffffffff
eeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeffffffffffffffffffffffffffffffff
eeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeffffffffffffffffffffffffffffffff
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111107000c00000000007100000007cc7cc70000000000007ccc7000000017cccccc7000000007cc7ccc7011111111111111111111111
000000000000000000000000cc000000000000cc01000000000c00010000000000c0000100000010c000000c00000001c000000c000000000000000000000000
000000000000000000000000c0c000c000000c0c00100000000c0000100000000c00000100000010c0800b0c00000010c000000c000000000000000000000000
000000000000000000000000c00c00000000c00c00010000000c0000100000007000000100000100c000000c00000100c009900c000000000000000000000000
000000000000000000000000c000c000000c000c00001000000c00000100000070000000000001007ccc7cc700001000c009900c000000000000000000000000
000000000000000000000000c0000c0000c0000c00000100000c0000010000001c00000100001000c0000c0000010000c000000c000000000000000000000000
000000000000000000000000c00000c00c00000c00000000000c00000010000010c0000000000000c00000c000100000c000000c000000000000000000000000
0000000000000000000000007000000770000007000000007cc7cc70000000001007ccc70000000070000007000000007cccccc7000000000000000000000000
11111111111111111111111001000000010000001000000010000001000000001000000100000001000000100000000100000010011111111111111111111111
00000000000000000000000000100000001000000100000001000000100000001000000100000010000001000000001000000100000000000000000000000000
00000000000000000000000000010000000100000010000001000000100000001000000100000010000010000000010000001000000000000000000000000000
00000000000000000000000000001000000010000001000000100000010000001000000100000100000100000000100000010000000000000000000000000000
00000000000000000000000000000100000001000000100000100000010000001000000100000100001000000001000000100000000000000000000000000000
00000000000000000000000000000010000000100000010000010000001000001000000100001000010000000010000001000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111117000000cc00000071000000070000007100000007cccccc7000000007ccc7000000000017cccccc7000000017cccccc71111111111111111
0000000000000000cc000000110000cc010000000100000001000000c000000c00000000c0000c0000000010c000000c00000010c000000c0000000000000000
0000000000000000c0c0000001100c0c001000000010000000100000c0800b0c00000000c00000c000000100c088880c00000100c0800b0c0000000000000000
0000000000000000c00c00000011c00c000100000001000000010000c000000c00000000c000000700001000c000000c00001000c000000c0000000000000000
0000000000000000c000c000000c000c0000100070001007000010007ccc7cc700000000c000000c000100007cccccc7000100007ccc7cc70000000000000000
0000000000000000c0000c0000c0000c00000100c100010c10000100c0000c0100000000c000000c00100000c000000000100000c0000c000000000000000000
0000000000000000c00000c00c00000c00000000c010000c01000000c00000c000000000c000000c00000000c000000000000000c00000c00000000000000000
00000000000000007000000770000007000000007cccccc70010000070000007000000007cccccc7000000007cccccc700000000700000070000000000000000
11111111111111110100000010000000100000000100000010010000100000001000000100000001000000010000001000000001000000101111111111111111
00000000000000000010000001000000010000000010000001001000010000001000000100000010000000100000010000000010000001000000000000000000
00000000000000000001000000100000001000000001000000100100010000001000000100000010000001000000100000000100000010000000000000000000
00000000000000000000100000010000000100000000100000010000001000000100001000000100000010000001000000001000000100000000000000000000
00000000000000000000010000001000000010000000010000001000001000000100001000000100000100000010000000010000001000000000000000000000
00000000000000000000001000000100000001000000001000000100000100000100001000001000001000000100000000100000010000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000015dcc77ccd510000000000000000000599997777999950000000000000000000004977779400000000000000000000000000000000000000000000
0000000005ddccc77cccdd500000000000000000599999777799999500000000000000000004997777994000000000000000000009a9000000009a9000000000
11111111771dccccccccd1771111111111111111888888999988888811111111111111111124449999444211111111111111111159995bbaabb5999511111111
00000000771ddccccccdd1770000000000000000888888999988888800000000000000000042774994772400000000000000000059a95bbaabb59a9500000000
00000000115dddccccddd51100000000000000002277229999227722000000000000000000427749947724000000000000000000311133155133111300000000
000000005dddddc77cddddd5000000000000000098778288882877890000000000000000004411999911440000000000000000003333313bb313333300000000
000000005ddddc0220cdddd500000000000000008811800000081188000000000000000000244497794442000000000000000000000000111100000000000000
000000005dddc000000cddd500000000000000008888829999288888000000000000000000000099990000000000000000000000000000555500000000000000
00000000000000111100000000000000000000008888828888288888000000000000000000990099990099000000000000000000000000abba00000000000000
000000000000001001000000000000000000000012222222222222210000000000000000009924999942990000000000000000000aa155bbbb551aa000000000
1111111111cc557cc755cc111111111111111111111198188189111111111111111111111114112222114111111111111111111111bb11133111bb1111111111
0000000000cc00cccc00cc0000000000000000000008820220288000000000000000000000990020020099000000000000000000000bb000000bb00000000000
00000000000500000000500000000000000000000089000000009800000000000000000000440000000044000000000000000000000300000000300000000000
0000000000005000000500000000000000000000009880000008890000000000000000000044000000004400000000000000000000b0000000000b0000000000
00000000000005000050000000000000000000000008282002828000000000000000000000022000000220000000000000000000000300000000300000000000
000000000000cc0000cc0000000000000000000000009980089900000000000000000000000099000099000000000000000000000000bb0000bb000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000088808080888000008880888008000880000088800880888008808880088000000880088000008880888008000880000008808080000000000000
00000000000080808080080000000800080080008000000080808080808080800800800000008000808000000800080080008000000080808080000000000000
00000000000088008080080000000800080000008880000088008080880080800800888000008880808000000800080000008880000080808800000000000000
00000000000080808080080000000800080000000080000080808080808080800800008000000080808000000800080000000080000080808080000000000000
00000000000088800880080000008880080000008800000080808800888088000800880000008800880000008880080000008800000088008080000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
00010000296202e0600f0300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000060500a0500d05010050130501505017050190501b0501e0502005024050260502835028340293302b310000000000000000000000000000000000000000000000000000000000000000000000000000
0104151907315083150a3250b3150d3250e3150f335103251133513325143251633517325193351b3251c3351e32520335223252433526325273352832528335273252f335007050070000000000000000000000
000200000d3701834027340333403f6403e6303d6303b6303a6303863038630366303563034620333203262031320306202f3202d6202c3202a61029310276102631025610243102261026310256102431022610
0001000025445356350e56522655166550b640236400c6400c130196300c1301a6300e130226200d1200d6200d3200d6202332022610236101761023610226102201021610180100c61000610006100061000610
000100001a320100600b13000000120000c300090000610000000000000c310090100615000000000000000000000000000160001600136000000000000000000000000000000000000000000000000000000000
000200003305033020330102005020020200100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200003f7713f0203f0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0109000011073000001107300000302513c251000000000029665000001d5550000011073000001105300000305361b536000000000011073000001d62400000296650000000000000000c5710c5710057100000
0109000011073000001107300000302513c251000000000029665000001d5550000011073000001105300000305361b536000000000011073000001d624000002966500000296651d616356161d6240000000000
010900000c3420c34218332000000c140001000014200142242173c0170c3400c3400c21024207003000c3000c3400c3400c4100c30000140001400c3400c30024227000000c254000001b7160f7161b7160f716
010800000f3511b0511b0511b0511b0510c05118051180511605116051160511605116051160510c0511805118051180510000000000000000000000000000000000000000000000000000000000000000000000
010200000c455344553545539455394553845537455374553645335453344533445335453364033845339453000032b4532a453000032c4532c4532c45338403214532145320453384031b453234531d03302033
01020000356313563135621080510605106051080510c05111051160511f0512963029630296201d6201d61011610116101161011610056100561005610056100561005610056100561005610056100561005610
0107001a002201803017010001400c02010030094100404002320100301451011740080300e52017740000100c030044200f0400c3100b0200c210170400371000030170200c040040301501004040020200c010
010600000f1500f0501b050270203302033000140001a000210002700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500
0105000003774037700f7000f000200001b000140000d000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003e620000003d610000003d62001000396103860038610356003f6103b6002c610000003f6200000021610000003f61000000236203f6103c610366002f6102a610236001c620166000e6100960002610
0109000011073000001107300000302003c20000000000002966500000000500005011073000001105300000305361b5360005000050305061b506305361b5362966500000110731d60600000000000000000000
010900000c3420c34218332000000c140001000014200142242173c0170f3400f3400f21018000003000c3000c3400c3400c4100c30000140001400c3400c3400c4100c4100c0100c0100c0000c0000c0000c000
010900001b7501b7501b7501b7501b7501b7501b7101b710167501675016750167501671016710187501875018750187501871018710000000000000000000000000000000000000000000000000000000000000
__music__
01 080a4b44
00 090a4344
00 080a0b44
02 090a4344
00 410a4344
02 410a4344
04 1412130b

