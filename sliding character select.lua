
topLine = 0
slideTimeStart = 12
slideTimeSide = {slideTimeStart, slideTimeStart}
slideDirection = {1,1}
controllingPlayer = 1
--;===========================================================
--; SELECT SCREEN
--;===========================================================
function start.updateDrawList()
	local drawList = {}
	
	return drawList
end
function start.newUpdateDrawList()
	local drawList = {}
	--if main.cpuSide[2] == true then
	if true then-- TODO: Add functionality for 2 player select screens.
		for row = 1, motif.select_info.rows do
			for col = 1, motif.select_info.columns do
				local cellIndex = ((row - 1 + topLine) % #start.t_grid) * motif.select_info.columns + col
				local t = start.t_grid[row][col]
				--local t = start.t_grid[((row + topLine - 1) % #start.t_grid) + 1][col]
				local c = (col - 1) * ((slideTimeSide[1] / slideTimeStart) * col)
				local r = row - 1
				--t.y = ((slideTimeSide[1] / slideTimeStart) * (100)) + start.t_grid[row][col].y
				if t.skip ~= 1 then
					local charData = start.f_selGrid(cellIndex)
					local function getTransforms(base)
						return {
							facing      = getCellFacing(base.facing, c, r),
							scale       = getCellTransform(c, r, "scale", base.scale),
							xshear      = getCellTransform(c, r, "xshear", base.xshear),
							angle       = getCellTransform(c, r, "angle", base.angle),
							xangle      = getCellTransform(c, r, "xangle", base.xangle),
							yangle      = getCellTransform(c, r, "yangle", base.yangle),
							projection  = getCellTransform(c, r, "projection", base.projection),
							focallength = getCellTransform(c, r, "focallength", base.focallength)
						}
					end

					if (charData and charData.char ~= nil and (charData.hidden == 0 or charData.hidden == 3)) or motif.select_info.showemptyboxes then
						local item = getTransforms(motif.select_info.cell.bg)
						item.anim = motif.select_info.cell.bg.AnimData
						item.x = motif.select_info.pos[1] + t.x
						item.y = motif.select_info.pos[2] + t.y + (slideDirection[1] * (slideTimeSide[1] / slideTimeStart) * motif.select_info.cell.spacing[2])
						table.insert(drawList, item)
					end

					if charData and (charData.char == 'randomselect' or charData.hidden == 3) then
						local item = getTransforms(motif.select_info.cell.random)
						item.anim = motif.select_info.cell.random.AnimData
						item.x = motif.select_info.pos[1] + t.x + motif.select_info.portrait.offset[1]
						item.y = motif.select_info.pos[2] + t.y + motif.select_info.portrait.offset[2] +(slideDirection[1] * (slideTimeSide[1] / slideTimeStart) * motif.select_info.cell.spacing[2])
						table.insert(drawList, item)
					end

					if charData and charData.char_ref ~= nil and charData.hidden == 0 then
						local item = getTransforms(motif.select_info.portrait)
						item.anim = charData.cell_data
						item.x = motif.select_info.pos[1] + t.x + motif.select_info.portrait.offset[1]
						item.y = motif.select_info.pos[2] + t.y + motif.select_info.portrait.offset[2] + (slideDirection[1] * (slideTimeSide[1] / slideTimeStart) * motif.select_info.cell.spacing[2])
						-- apply cell scale override while preserving portrait resolution factor
						if item.scale ~= nil then
							local charInfo = main.t_selChars[charData.char_ref + 1]
							if charInfo then
								local portraitScale = charInfo.portraitscale or 1
								local charLocalcoord = charInfo.localcoord or motif.info.localcoord[1]
								-- recompute resolution compensation factor
								local resFix = portraitScale * motif.info.localcoord[1] / charLocalcoord
								item.scale = {
									item.scale[1] * resFix,
									item.scale[2] * resFix
								}
							end
						end
						table.insert(drawList, item)
					end
				end
			end
		end
	end
	return drawList
end

hook.add("start.f_selectScreen", "selectScreenDecider", function()
	local function updateForNewPlayer()
		topLine = start.c[controllingPlayer].selY
		newDrawList = start.newUpdateDrawList()
	end
	if newDrawList == nil then
		newDrawList = {}
	end
	if start.p[1].teamEnd == false then
		topLine = start.c[1].selY or 0
		newDrawList = start.newUpdateDrawList()
	end
	
	if false then --TODO: Split Select Screen
		
	else
		if start.p[1].t_selected[1] == nil and controllingPlayer ~= 1 then
			controllingPlayer = 1
			updateForNewPlayer()
		end
		
		if main.coop then
			if main.cpuSide[2] == false then

				if start.p[1].t_selected[1] ~= nil then
					if start.p[2].t_selected[1] ~= nil then
						if start.p[1].t_selected[2] ~= nil then
							if controllingPlayer ~= 4 then
								controllingPlayer = 4
								updateForNewPlayer()
							end
						else
							if controllingPlayer ~= 3 then
								controllingPlayer = 3
								updateForNewPlayer()
							end
						end
					else
						if controllingPlayer ~= 2 then
							controllingPlayer = 2
							updateForNewPlayer()
						end
					end
					
				end
				
			else
			
				for c, v in pairs(start.p[1].t_selected) do
					if c == controllingPlayer then
						controllingPlayer = c + 1
						updateForNewPlayer()
					end
				end
			
			end
			
			
		else
			if controllingPlayer == 1 and start.p[1].selEnd == true then
				if main.cpuSide[2] == true then
					controllingPlayer = 2
					updateForNewPlayer()
				else
					controllingPlayer = 2
					updateForNewPlayer()
				end
			end
			--If CPU case
		end
		
		
		
		
		
		if slideTimeSide[1] > 0 then
			slideTimeSide[1] = slideTimeSide[1] - 1
			newDrawList = start.newUpdateDrawList()
		end
		batchDraw(newDrawList)
		cursorsToDraw = 1
		if main.selectMenu[2] or main.cpuSide[2] == false then
			cursorsToDraw = cursorsToDraw * 2
		end
		if main.coop then
			cursorsToDraw = cursorsToDraw * 2
			if main.cpuSide[2] == true then
				cursorsToDraw = start.p[1].numChars
			end
		end
		
		
		
		
		for side = 1, cursorsToDraw do
			BottomLine = (topLine + motif.select_info.rows - 1) % #start.t_grid
			if start.c[side].selY >= topLine and  start.c[side].selY < topLine + motif.select_info.rows then
				start.f_drawNewCursor(side, start.c[side].selX, (start.c[side].selY - topLine) + 1, 'active', false)
			elseif ((BottomLine < motif.select_info.rows - 1) and start.c[side].selY <= BottomLine) and topLine > BottomLine then
				start.f_drawNewCursor(side, start.c[side].selX, start.c[side].selY + (motif.select_info.rows - BottomLine), 'active', false)				
			end
		end
	end
end)



--draw cursor
function start.f_drawCursor(pn, x, y, param, done)
	
end

--draw cursor
function start.f_drawNewCursor(pn, x, y, param, done)
	local pData = start.f_getCursorData(pn)
	-- calculate target cell coordinates using the pre-calculated grid
	local cellData = start.t_grid[y] and start.t_grid[y][x + 1]
	local baseX, baseY
	if cellData then
		-- cellData already includes all spacing and offsets
		baseX = motif.select_info.pos[1] + cellData.x
		baseY = motif.select_info.pos[2] + cellData.y
	end
	cd = {}
	-- draw
	local params = pData.cursor[param].default
	local key = x .. '-' .. y
	if pData.cursor[param][key] ~= nil then
		params = pData.cursor[param][key]
	end
	local a = params.AnimData
	animSetFacing(a, getCellFacing(params.facing, x, y))
	local scale = getCellTransform(x, y - 1, "scale", params.scale)
	animSetScale(a, scale[1], scale[2])
	animSetXShear(a, getCellTransform(x, y - 1, "xshear", params.xshear))
	animSetAngle(a, getCellTransform(x, y - 1, "angle", params.angle))
	animSetXAngle(a, getCellTransform(x, y - 1, "xangle", params.xangle))
	animSetYAngle(a, getCellTransform(x, y - 1, "yangle", params.yangle))
	animSetProjection(a, getCellTransform(x, y - 1, "projection", params.projection))
	animSetFocalLength(a, getCellTransform(x, y - 1, "focallength", params.focallength))
	animUpdate(a)
	main.f_animPosDraw(a, baseX, baseY, getCellFacing(params.facing, x, y))
end

--returns correct cell position after moving the cursor
function start.f_cellMovement(selX, selY, cmd, side, snd, dir)
	local tmpX = selX
	local tmpY = selY
	local found = false
	if getInput(cmd, motif.select_info.cell.up.key) or dir == 'U' then
		for i = 1, motif.select_info.rows do
			selY = selY - 1
			if selY < 0 then
				selY = #start.t_grid - 1
			end
			print(topLine)
			print(selY)
			if (topLine == selY + 1 or selY == #start.t_grid - 1) and (cmd == controllingPlayer or main.cpuSide[2]) then
				topLine = topLine - 1
				if topLine < 0 then
					topLine = topLine % #start.t_grid
				end
				slideTimeSide[1] = slideTimeStart
				slideDirection[1] = -1
			end
			if dir ~= nil then
				found, selX = start.f_searchEmptyBoxes(selX, selY, side, -1)
			elseif (start.t_grid[selY + 1][selX + 1].char ~= nil or motif.select_info.moveoveremptyboxes) and start.t_grid[selY + 1][selX + 1].skip ~= 1 and (gameOption('Options.Team.Duplicates') or start.t_grid[selY + 1][selX + 1].char == 'randomselect' or not t_reservedChars[side][start.t_grid[selY + 1][selX + 1].char_ref]) and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
				break
			elseif motif.select_info.searchemptyboxesup then
				found, selX = start.f_searchEmptyBoxes(selX, selY, side, 1)
			end
			if found then
				break
			end
		end
	elseif getInput(cmd, motif.select_info.cell.down.key) or dir == 'D' then
		for i = 1, #start.t_grid do
			selY = selY + 1
			if selY >= #start.t_grid then
				selY = 0
			end
			if (topLine + motif.select_info.rows) % #start.t_grid == selY and  (cmd == controllingPlayer or main.cpuSide[2]) then
				topLine = topLine + 1
				if topLine > #start.t_grid - 1 then
					topLine = topLine % #start.t_grid
				end
				slideTimeSide[1] = slideTimeStart
				slideDirection[1] = 1
			end
			if dir ~= nil then
				found, selX = start.f_searchEmptyBoxes(selX, selY, side, 1)
			elseif (start.t_grid[selY + 1][selX + 1].char ~= nil or motif.select_info.moveoveremptyboxes) and start.t_grid[selY + 1][selX + 1].skip ~= 1 and (gameOption('Options.Team.Duplicates') or start.t_grid[selY + 1][selX + 1].char == 'randomselect' or not t_reservedChars[side][start.t_grid[selY + 1][selX + 1].char_ref]) and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
				break
			elseif motif.select_info.searchemptyboxesdown then
				found, selX = start.f_searchEmptyBoxes(selX, selY, side, 1)
			end
			if found then
				break
			end
		end
	elseif getInput(cmd, motif.select_info.cell.left.key) or dir == 'B' then
		if dir ~= nil then
			found, selX = start.f_searchEmptyBoxes(selX, selY, side, -1)
		else
			for i = 1, motif.select_info.columns do
				selX = selX - 1
				if selX < 0 then
					if motif.select_info.wrapping then
						selX = motif.select_info.columns - 1
					else
						selX = tmpX
					end
				end
				if (start.t_grid[selY + 1][selX + 1].char ~= nil or motif.select_info.moveoveremptyboxes) and start.t_grid[selY + 1][selX + 1].skip ~= 1 and (gameOption('Options.Team.Duplicates') or start.t_grid[selY + 1][selX + 1].char == 'randomselect' or not t_reservedChars[side][start.t_grid[selY + 1][selX + 1].char_ref]) and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
					break
				end
			end
		end
		displayX = selX
	elseif getInput(cmd, motif.select_info.cell.right.key) or dir == 'F' then
		if dir ~= nil then
			found, selX = start.f_searchEmptyBoxes(selX, selY, side, 1)
		else
			for i = 1, motif.select_info.columns do
				selX = selX + 1
				if selX >= motif.select_info.columns then
					if motif.select_info.wrapping then
						selX = 0
					else
						selX = tmpX
					end
				end
				if (start.t_grid[selY + 1][selX + 1].char ~= nil or motif.select_info.moveoveremptyboxes) and start.t_grid[selY + 1][selX + 1].skip ~= 1 and (gameOption('Options.Team.Duplicates') or start.t_grid[selY + 1][selX + 1].char == 'randomselect' or not t_reservedChars[side][start.t_grid[selY + 1][selX + 1].char_ref]) and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
					break
				end
			end
		end
		displayX = selX
	end
	if (tmpX ~= selX or tmpY ~= selY) then
		if dir == nil then
			sndPlay(motif.Snd, snd[1], snd[2])
		end
	end
	return selX, selY
end






local cnt = motif.select_info.columns + 1
local row = 1
local col = 0
start.t_grid = {[row] = {}}
for i = 1, #main.t_selGrid do
	if i == cnt then
		row = row + 1
		cnt = cnt + motif.select_info.columns
		start.t_grid[row] = {}
	end
	col = #start.t_grid[row] + 1
	local cell_spacing = getCellSpacing(col - 1, row - 1)
	local cell_offset = getCellOffset(col - 1, row - 1)
	start.t_grid[row][col] = {
		x = (col - 1) * (motif.select_info.cell.size[1] + cell_spacing[1]) + cell_offset[1],
		y = (row - 1) * (motif.select_info.cell.size[2] + cell_spacing[2]) + cell_offset[2]
	}
	if start.f_selGrid(i).char ~= nil then
		start.t_grid[row][col].char = start.f_selGrid(i).char
		start.t_grid[row][col].char_ref = start.f_selGrid(i).char_ref
		start.t_grid[row][col].hidden = start.f_selGrid(i).hidden
		for j = 1, #main.t_selGrid[i].chars do
			start.f_selGrid(i, j).row = row
			start.f_selGrid(i, j).col = col
		end
	end
	local overrideSkip = getCellSkip(col - 1, row - 1)
	if start.f_selGrid(i).skip == 1 or overrideSkip then
		start.t_grid[row][col].skip = 1
	end
end
for i = 1, motif.select_info.rows do
	if start.t_grid[#start.t_grid][i] == nil then
		start.t_grid[#start.t_grid][i] = {}
		start.t_grid[row][i].char = "randomselect"
		start.t_grid[row][i].char_ref = 0
		start.t_grid[row][i].hidden = 2
	end
end

onePlayerMenuPos = motif.select_info.pos
