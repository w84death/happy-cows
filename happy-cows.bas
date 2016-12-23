''
''	KRZYSZTOF JANKOWSKI
''	HAPPY COWS V03
''
''	(c) 2016 P1X
''

screenres 900, 600, 8, 4

'' CGArne COLOR PALETTE
palette 0, 0,0,0
palette 1, 34,52,209
palette 2, 12,126,69
palette 3, 68,170,204
palette 4, 138,54,34
palette 5, 92,46,120
palette 6, 170,92,61
palette 7, 181,181,182
palette 8, 94,96,110
palette 9, 76,129,251
palette 10, 108,217,71
palette 11, 123,226,249
palette 12, 235,138,96
palette 13, 226,61,105
palette 14, 225,217,63
palette 15, 255,255,255

randomize ,1

dim ascii_terrain(5) as integer => {0, 176, 177, 178, 219}
dim ascii_forest(5) as integer => {23, 30, 5, 6, 237}
dim ascii_water(4) as integer => {0, 0, 176, 177}

dim palette_grass(4) as integer  => {10,2}
dim palette_forest(3) as integer  => {0, 5, 4}
dim palette_cow(6) as integer  => {15, 15, 15, 15, 7, 7}

dim as integer max_cows = 32
dim as integer cow(max_cows, 3)

dim as integer max_x = LoWord(width)
dim as integer max_y = HiWord(width)
dim as integer terrain(max_x, max_y)
dim as integer no_go(max_x, max_y, 4)

dim as boolean game_over = 0
dim as string key
dim as integer i, x, y, t, no = 0, frames = 0
dim as integer new_pos_x, new_pos_y, length
dim as integer lake_x, lake_y, lake_size
dim as integer max_forest = 1 + rnd*3
dim as integer starting_forest(4, 2),starting_forest_id
dim as integer grass_max, grass_hp
dim as integer cows_movement, cows_hunger

do
grass_max = 0
grass_hp = 0
cows_hunger = 5
cows_movement = 25
lake_size = 28
lake_x = max_x / 2
lake_y = max_y / 2
max_forest = 1 + rnd*3
starting_forest_id = 0

'' GENERATE COWS
for i = 0 to max_cows
	cow(i, 0) = 12 + rnd*8
	cow(i, 1) = 12 + rnd*8
	cow(i, 2) = rnd*5
next

'' GENERATE FOREST
for i = 0 to max_forest
	x = rnd*max_x
	y = rnd*max_y
	no_go(x, y, 0) = ascii_forest(rnd*4)
	no_go(x, y, 1) = palette_forest(rnd*2)
	no_go(x, y, 2) = 10
	no_go(x, y, 3) = 0
	starting_forest(starting_forest_id, 0) = x
	starting_forest(starting_forest_id, 1) = y
	starting_forest_id = starting_forest_id + 1
next



'' GENERATE TERRAIN
for y = 0 to max_y
for x = 0 to max_x

	'' GRASS
	terrain(x, y) = 2 + rnd*1
	
	'' EMPTY SPACE
	no_go(x, y, 0) = -1
	no_go(x, y, 3) = -1
	
	'' FOREST
	for i = 0 to max_forest
		length = sqr((starting_forest(i, 0)-x)^2 + (starting_forest(i, 1)-y)^2)
		if length < 2 + rnd*12 and rnd*10<7 then
			no_go(x, y, 0) = ascii_forest(rnd*4)
			no_go(x, y, 1) = palette_forest(rnd*2)
			no_go(x, y, 2) = 10
			no_go(x, y, 3) = 0
		end if
	next

	'' LAKES
	if rnd*100 < 5 then
		lake_x = lake_x + (1 - rnd*2)
		lake_y = lake_y + (1 - rnd*2)
	end if
	length = sqr((lake_x-x)^2 + (lake_y-y)^2)
	if  ( length < lake_size - 1 ) or ( length < lake_size and rnd*10 < 3 ) then
		no_go(x, y, 0) = ascii_water(rnd*3)
		no_go(x, y, 1) = 11
		no_go(x, y, 2) = 3
		no_go(x, y, 3) = 1
	end if

	'' COUNT GRASS
	if terrain(x, y) > 0 and no_go(x, y, 0) < 0 then
		grass_max = grass_max + 1
	end if
next
next

'' START SIMULATION
color 0, 15
cls

do
key = Inkey()

ScreenLock()
grass_hp = 0

'' RENDER TERRAIN (ANIMATE WATER)
for y = 0 to max_y
for x = 0 to max_x
	locate y, x
	if no_go(x, y, 0) > -1 then
		color no_go(x, y, 1), no_go(x, y, 2)
		'' ANIMATE WATER
		if no_go(x, y, 3) > 0 and rnd*100 < 5 then
			no_go(x, y, 0) = ascii_water(rnd*3)
		end if
		'' RENDER NO-GO (trees, water, fences..)
		print chr(no_go(x, y, 0));
	else
		color palette_grass(0), palette_grass(1)
		
		'' GRASS GROWING
		if terrain(x, y) > 0 and terrain(x,y) < 4 and rnd*2000<1 then
			terrain(x, y) = terrain(x, y) + 1
		end if

		'' RENDER TERRAIN
		print chr(ascii_terrain(terrain(x, y)));
		
		'' COUNT GRASS HP
		if terrain(x, y) > 0 then
			grass_hp = grass_hp + 1
		end if
	end if
next
next
 
'' RENDER COW
for i = 0 to max_cows
	locate cow(i,1), cow(i,0)
	color palette_cow(cow(i, 2)), palette_grass(1)
	print chr(64);
next

'' AI
for i = 0 to max_cows
	if rnd*100 < cows_movement then
		new_pos_x = cow(i, 0) - 1 + rnd*2
		if new_pos_x < max_x and new_pos_x > 0 and no_go(new_pos_x, cow(i, 1), 0) < 0 then
			cow(i, 0) = new_pos_x
		end if
	end if
	if rnd*100 < cows_movement then
		new_pos_y = cow(i, 1) - 1 + rnd*2
		if new_pos_y < max_y and new_pos_y > 0 and no_go(cow(i, 0), new_pos_y, 0) < 0  then
			cow(i, 1) = new_pos_y
		end if
	end if

	if rnd*100 < cows_hunger then
		t = terrain(cow(i, 0), cow(i, 1))
		if t > 0 then
			terrain(cow(i, 0), cow(i, 1)) = t - 1
		end if
	end if
next

'' HUD
locate 2, 2
	color 14, 13
	print "DAY ";
	print no;
locate 2, 16
	print "COWS ";
	print max_cows;
locate 2, 32
	print "GRASS HP ";
	print grass_hp;
	print "/";
	print grass_max
locate 2, max_x - 14
	print "HAPPY COWS V03"

'' CLOCKS
frames = frames + 1
if frames > 24*60 then
	frames = 0
	no = no + 1
end if
ScreenUnlock()

sleep(18, 1)

'' DELETE
loop until key = chr(255, 83) or key = chr(27)
'' ESC
loop until key = chr(27)

sleep
