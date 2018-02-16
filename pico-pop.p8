pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

isdebug=1

--gamestates:1=game
gamestate=1
gametimercount=10
xbtnspeed=8

gridwidth=6
gridheight=12
gridtop=30

p1grid={}
p1gridoffset=1
p1gridend=49

p2grid={}
p2gridoffset=79
p2gridend=127

xgrid=0
ygrid=0

--orientation:1=horizontal-12,2=vertical-21,3=horizontal=21,4=vertical-12
p1block1x, p1block1y, p1block2x, p1block2y, p1block1, p1block2, p1orientation, p1timer = 0,0,0,0,0,0,1,0

--picostates:0=none,1=red,2=green,3=blue,4=yellow,5=pink
picostate1spr=11
picostate2spr=49
picostate3spr=17
picostate4spr=33
picostate5spr=1

function _init()

	if gamestate==1 then
		for i=1,gridwidth,1 do
		
			p1grid[i]={}
			p2grid[i]={}
			
			for j=1,gridheight,1 do
				p1grid[i][j]=0
				p2grid[i][j]=0
			end
		end
	end
end

function transgridxpos(p,x)
	xoffset=p1gridoffset

	if p==2 then
		xoffset=p2gridoffset
	end

	xpos=((x-xoffset)/8)+1

	return xpos
end

function transgridypos(y)
	yoffset=gridtop
	ypos=flr((y-yoffset)/8)+1

	return ypos
end

function insertintotable(p,x,y,b)
	if p==1 then
		p1grid[x][y]=b
	else
		p2grid[x][y]=b
	end
end

function _update60()
	
	if gamestate==1 then

		if p1timer>32000 then
			p1timer=0
		end

		if p1block1==0 then
			--get next blocks
			p1block1=flr(rnd(5))+1
			p1block2=flr(rnd(5))+1
			p1block1x=1
			p1block2x=p1block1x+8
			p1block1y=30
			p1block2y=30
			p1orientation=1
			p1timer=0
		end

		p1timer+=1

		if btnp(0) then
			p1block1x-=xbtnspeed
			p1block2x-=xbtnspeed

			if p1orientation == 3 and p1block2x < p1gridoffset then
				p1block2x=p1gridoffset
				p1block1x=p1gridoffset+8
			elseif p1orientation == 1 and p1block1x < p1gridoffset then
				p1block1x=p1gridoffset
				p1block2x=p1gridoffset+8
			elseif p1block1x < p1gridoffset then
				p1block1x=p1gridoffset
				p1block2x=p1gridoffset
			end

		elseif btnp(1) then
			p1block1x+=xbtnspeed
			p1block2x+=xbtnspeed

			if p1block1x > p1gridend-16 then
				p1block1x=p1gridend-16
			end

			if p1orientation == 1 and p1block2x > p1gridend-8 then
				p1block1x=p1gridend-16
				p1block2x=p1gridend-8
			elseif p1orientation == 3 and p1block1x > p1gridend-8 then
				p1block1x=p1gridoffset-8
				p1block2x=p1gridoffset-16
			elseif p1block1x > p1gridend-8 then
				p1block1x=p1gridoffset-8
				p1block2x=p1gridoffset-8
			end
		end

		if btnp(3) then
			p1block1y+=8
			p1block2y+=8
		end

		if p1timer%gametimercount==0 then
			p1block1y+=1
			p1block2y+=1
		end

		if orientation == 2 and p1block1y+8 >= 127 then
			p1block1y=127-8
			p1block2y=127-16
		elseif orientation == 4 and p1block2y+8 >= 127 then
			p1block1y=127-16
			p1block2y=127-8
		elseif p1block1y+8 >= 127 then
			p1block1y=127-8
			p1block2y=127-8
		end

		b1xgrid=transgridxpos(1, p1block1x)
		b1ygrid=transgridypos(p1block1y)

		b2xgrid=transgridxpos(1, p1block2x)
		b2ygrid=transgridypos(p1block2y)

		if b1ygrid==gridheight or b2ygrid==gridheight then
			insertintotable(1, b1xgrid, b1ygrid, p1block1)
			insertintotable(1, b2xgrid, b2ygrid, p1block2)
			p1block1=0
		end
	end
end

function getsprite(state) 
	if state==1 then
		return picostate1spr
	elseif state==2 then
		return picostate2spr
	elseif state==3 then
		return picostate3spr
	elseif state==4 then
		return picostate4spr
	elseif state==5 then
		return picostate5spr
	end
end

function _draw()

	if gamestate==1 then

		rectfill(0,0,127,127,0)

		line(p1gridoffset-1, gridtop-8, p1gridoffset-1, 127, 7)
		line(p1gridend, gridtop-8, p1gridend, 127, 7)
		line(p1gridoffset-1, 127, p1gridend, 127, 7)

		line(p2gridoffset-1, gridtop-8, p2gridoffset-1, 127, 7)
		line(p2gridend, gridtop-8, p2gridend, 127, 7)
		line(p2gridoffset-1, 127, p2gridend, 127, 7)

		for i=1,gridwidth,1 do 		

			local p1gridlinex = (p1gridoffset-1+((i-1)*8))+8
			line(p1gridlinex, gridtop-8, p1gridlinex, 126, 13)

			local p2gridlinex = (p2gridoffset-1+((i-1)*8))+8
			line(p2gridlinex, gridtop-8, p2gridlinex, 126, 13)

			for j=1,gridheight,1 do
				
				local gridliney = (gridtop+((j-1)*8))+8
				line(p1gridoffset, gridliney, p1gridend-1, gridliney)
				line(p2gridoffset, gridliney, p2gridend-1, gridliney)

				p1spr=16
				p2spr=16

				local p1griditem=p1grid[i][j]

				p1spr=getsprite(p1griditem);

				local p2griditem=p2grid[i][j]

				p2spr=getsprite(p2griditem);

				spr(p1spr, (((i-1)*8)+p1gridoffset), (gridtop+((j-1)*8)))
				spr(p2spr, (((i-1)*8)+p2gridoffset), (gridtop+((j-1)*8)))		
			end
		end

		local p1s1=getsprite(p1block1)
		local p1s2=getsprite(p1block2)

		spr(p1s1, p1block1x, p1block1y)
		spr(p1s2, p1block2x, p1block2y)
	end

	if isdebug==1 then
		print('mem:'..stat(0).." / ", 0, 0, 13)
		print('cpu:'..stat(1).." / ", 55, 0, 13)
		print('fps:'..stat(7), 105, 0, 13)

		print('b1:'..p1block1.."/", 0, 6, 13)
		print('b2:'..p1block2.."/", 28, 6, 13)
		print('o:'..p1orientation.."/", 55, 6, 13)
		print('x:'..p1block1x.."/", 75, 6, 13)
		print('y:'..p1block1y.."/", 100, 6, 13)

		print('xg:'..xgrid.."/", 0, 12, 13)
		print('yg:'..ygrid.."/", 55, 12, 13)
	end
end

__gfx__
000000000022ef000022ef000022ef000022ef000022ef000022ef000022ef000022ef000022ef000022ef0000228e0000228e0000228e0000228e0000228e00
0000000002eeeef002eeeef002eeeef002eeeef002eeeef002eeeef002eeeef002eeeef002eeeef002eeeef0028888e0028888e0028888e0028888e0028888e0
000000002e0707ee2e0707ee2e0707ee2e0707ee2e0707ee2e0707ee2e0707ee2e0707ee2e0707ee2e0707ee2807078828070788280707882807078828070788
000000002e7777ee2e7777ee2e7777ee2e7777ee2e7777ee2e7777ee2e7777ee2e7777ee2e7777ee2eeeeeee2877778828777788287777882877778828777788
000000002e555eee2ee88eee2e555eee2ee5eeee2ee5eeee2ee55eee2e888eee2eeeeeee2ee5eeee2eeeeeee28555888288ee888285558882885888828855888
000000002ee88eee2ee88eee2eeeeeee2ee5eeee2ee8eeee2ee55eee2e888eee2eeeeeee2eeeeeee2eeeeeee288ee888288ee888288888882885888828855888
0000000002eeeee002eeeee002eeeee002eeeee002eeeee002eeeee002eeeee002eeeee002eeeee002eeeee00288888002888880028888800288888002888880
000000000022ee000022ee000022ee000022ee000022ee000022ee000022ee000022ee000022ee000022ee000022880000228800002288000022880000228800
000000000011c6000011c6000011c6000011c6000011c6000011c6000011c6000011c6000011c6000011c60000228e0000228e0000228e0000228e0000000000
0000000001cccc6001cccc6001cccc6001cccc6001cccc6001cccc6001cccc6001cccc6001cccc6001cccc60028888e0028888e0028888e0028888e000000000
000000001c0707cc1c0707cc1c0707cc1c0707cc1c0707cc1c0707cc1c0707cc1c0707cc1c0707cc1c0707cc2807078828070788280707882807078800000000
000000001c7777cc1c7777cc1c7777cc1c7777cc1c7777cc1c7777cc1c7777cc1c7777cc1c7777cc1ccccccc2877778828777788287777882888888800000000
000000001c555ccc1cc88ccc1c555ccc1cc5cccc1cc5cccc1cc55ccc1c888ccc1ccccccc1cc5cccc1ccccccc28eee88828888888288588882888888800000000
000000001cc88ccc1cc88ccc1ccccccc1cc5cccc1cc8cccc1cc55ccc1c888ccc1ccccccc1ccccccc1ccccccc28eee88828888888288888882888888800000000
0000000001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc00288888002888880028888800288888000000000
000000000011cc000011cc000011cc000011cc000011cc000011cc000011cc000011cc000011cc000011cc000022880000228800002288000022880000000000
0000000000449a0000449a0000449a0000449a0000449a0000449a0000449a0000449a0000449a0000449a000000000000000000000000000000000000000000
00000000049999a0049999a0049999a0049999a0049999a0049999a0049999a0049999a0049999a0049999a00000000000000000000000000000000000000000
00000000490707994907079949070799490707994907079949070799490707994907079949070799490707990000000000000000000000000000000000000000
00000000497777994977779949777799497777994977779949777799497777994977779949777799499999990000000000000000000000000000000000000000
00000000495559994998899949555999499599994995999949955999498889994999999949959999499999990000000000000000000000000000000000000000
00000000499889994998899949999999499599994998999949955999498889994999999949999999499999990000000000000000000000000000000000000000
00000000049999900499999004999990049999900499999004999990049999900499999004999990049999900000000000000000000000000000000000000000
00000000004499000044990000449900004499000044990000449900004499000044990000449900004499000000000000000000000000000000000000000000
000000000033bf000033bf000033bf000033bf000033bf000033bf000033bf000033bf000033bf000033bf000000000000000000000000000000000000000000
0000000003bbbbf003bbbbf003bbbbf003bbbbf003bbbbf003bbbbf003bbbbf003bbbbf003bbbbf003bbbbf00000000000000000802280280000000000000000
000000003b0707bb3b0707bb3b0707bb3b0707bb3b0707bb3b0707bb3b0707bb3b0707bb3b0707bb3b0707bb0000000000000000802280280000000000000000
000000003b7777bb3b7777bb3b7777bb3b7777bb3b7777bb3b7777bb3b7777bb3b7777bb3b7777bb3bbbbbbb0000000000000000000000000000000000000000
000000003b555bbb3bb88bbb3b555bbb3bb5bbbb3bb5bbbb3bb55bbb3b888bbb3bbbbbbb3bb5bbbb3bbbbbbb0000000000000000228022280000000000000000
000000003bb88bbb3bb88bbb3bbbbbbb3bb5bbbb3bb8bbbb3bb55bbb3b888bbb3bbbbbbb3bbbbbbb3bbbbbbb0000000000000000228022280000000000000000
0000000003bbbbb003bbbbb003bbbbb003bbbbb003bbbbb003bbbbb003bbbbb003bbbbb003bbbbb003bbbbb00000000000000000000000000000000000000000
000000000033bb000033bb000033bb000033bb000033bb000033bb000033bb000033bb000033bb000033bb000000000000000000802280280000000000000000
000000000000000000000000000000000000000000000000051228ee000000000000000000000000000000000000000000777777777777777777777777777700
802280288022802880228028802280280000000000000000052288ee000000000655567000000000055555500000000007777777777777777777777777777770
802280288022802880228028802280280000000000000000051228ee000000007655567600000000055dc65000000000777bbbbbbbbbbbbbbbbbbbbbbbbbb777
000000000000000000000000000000000000000000000000052288ee000000007656667600000000051dc16000000000777bbbbbbbbbbbbbbbbbbbbbbbbbb777
228022280280222822802228028022280000000000000000051228ee000000007657767600000000051dc16000000000777bbbbbbbbbbbbbbbbbbbbbbbbbb777
228022280280222822802228028022280000000000000000052288ee000000007655567600000000051dc16000000000777bbbbbbbbbbbbbbbbbbbbbbbbbb777
000000000000000000000000000000000000000000000000051228ee000000007656667600000000051dc16000000000777bbb33333333333333333333bbb777
802280288022802880228028802280280000000000000000052288ee000000007657767600000000051dc16000000000777bbb33333333333333333333bbb777
000000000000000000000000000000000000000000000000051228ee000000007655567600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051122ee000000007655567600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051228ee000000007656667600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051122ee000000007657767600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051228ee000000007655567600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051122ee000000007656667600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051228ee000000007657767600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051122ee000000007655567600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051228ee000000007655567600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000052288ee000000007655567600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051228ee000000007656667600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000052288ee000000007657767600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051228ee000000007655567600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000052288ee000000007656667600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051228ee000000007657767600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000052288ee000000007655567600000000051dc16000000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051228ee0000000076555676000000000555555500000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051122ee000000007655567600000000051dc16100000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051228ee000000007656667600000000051dc16100000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051122ee000000007657767600000000051dc16100000000777bbb33000000000000000033bbb777
000000000000000000000000000000000000000000000000051228ee000000007655567600000000051dc1610000000077777777777777777777777777777777
000000000000000000000000000000000000000000000000051122ee000000007656667600000000051dc1610000000077777777777777777777777777777777
000000000000000000000000000000000000000000000000051228ee000000007657767600000000051dc161000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0
000000000000000000000000000000000000000000000000051122ee000000007655567600000000000000000000000000333333333333333333333333333300
000000000000000000000000000000000000000033333b43333b4433333b44555555555500000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000053333b4433b4444333b444555555555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005533b4444b4444444b4444553333333300000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000554b44444444444444444455bbbbbbbb00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000544444444444444444444500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003044444444444444444444030000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003b04444444444444444440350000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003bb0000000000000000000550000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033434333333b4333333b43550000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000533b4443443b433b443b43550000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000055b4444443b4334443b433550000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000554444444434443b443444550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000544444443b4444443b44450bbbbbbbb00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003044444444444444444444033333333300000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005304444444444444444440535555555500000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000053b0000000000000000000535555555500000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000353b43bb3333333b443b43550000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000554343b34333b443443b43550000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000554b434444b4443b44b433550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005544444444444443444444550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000544444444444444444444500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005044444444444444444444050000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005304444444444444444440350000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000053b0000000000000000000550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005544433b3433b333333b43550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005544443b43b44333443b43550000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000554444444444443b43b433550000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000554444444444443b443444550000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000054444444444444443b444500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003044444444444444444444030000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003304444444444444444440330000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000053b0000000000000000000350000000000000000000000000000000000000000000000000000000000000000
__map__
8586b70000000000008587888888858700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9596a70000000000009597000000a5a700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a5a697000000000000b5a7989898958700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a5a6a7000000000000b5a788888885b700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9596a700000000001bb597000000a5a700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a5a697000000041e0eb597000000959700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a596b7001108022725b5a7000000a58700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b5a69714171d191d2ab587989898959700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b5a6b7000000000000b5b798980085b700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
