﻿-- Copyright © 2016 Rympex <Rympex@noemail>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Cascade Badge Quest'
local description = 'From Cerulean to Route 5'
local level       = 10

local dialogs = {
	npcMisty = Dialog:new({
		"Oh!! You found it!",
		"Have you enjoyed the Cruise yet?"
	}),
	npcafterbeat = Dialog:new({
		"Good luck!",
		"And remember: expect the unexpected!"
	})
}

local CascadeBadgeQuest = Quest:new()

function CascadeBadgeQuest:new()
	return Quest.new(CascadeBadgeQuest, name, description, level, dialogs , state)
end

function CascadeBadgeQuest:isDoable()
	if self:hasMap() and not hasItem("HM01 - Cut") then
		return true
	end
	return false
end

function CascadeBadgeQuest:isDone()
	if getMapName() == "Route 5" then
		return true
	else
		return false
	end
end

function Quest:askForTrainerInfo()
  return askForTrainerInfo()
end 

function CascadeBadgeQuest:CeruleanCity()
	 state = false 
    if self:needPokecenter()  or not game.isTeamFullyHealed() then
		return moveToCell(162,114)
	elseif self:needPokemart() then
		return moveToCell(166,133) -- pokemart
	elseif  not self:isTrainingOver() then
		return moveToCell(39,0)-- Route 24 Bridge
	elseif self:checkBadge() <= 1 and self:checkBadge() >= 0  then
		return moveToCell(177,114) -- 2nd Gym
	elseif not dialogs.billTicketDone.state then
		return moveToCell(39,0)-- Route 24 Bridge
	elseif isNpcOnCell(43,23) then
		talkToNpcOnCell(43,23)
	else
		return moveToCell(23,50) -- Route 5
	end
end

function CascadeBadgeQuest:CeruleanHouse6()
	if not hasItem("TM28") then
		return talkToNpcOnCell(9,8)
	else 
		moveToMap("Cerulean City")
	end
end

function CascadeBadgeQuest:CeruleanPokémonMart()
	self:pokemart("Cerulean City")
end

function CascadeBadgeQuest:CeruleanPokémonCenter()
 if not game.isTeamFullyHealed() then
	return self:pokecenter("Cerulean City")
  else
  return moveToCell(61,26)
  end 
end

function CascadeBadgeQuest:Route24Bridge()
if (not self:isTrainingOver()
			or not dialogs.billTicketDone.state)
		and not self:needPokecenter()
	then
		return moveToCell(14,0)
	else
		return moveToCell(14,31)
	end
end

function CascadeBadgeQuest:Route24Grass()
	if not self:isTrainingOver() then
	  moveToGrass()
	  else 
		return moveToCell(8,0)
	end 
end

function CascadeBadgeQuest:Route24()
	if game.inRectangle(14, 0, 15, 31) then
		return self:Route24Bridge()
	elseif game.inRectangle(6, 0, 12, 31) then
		return self:Route24Grass()
	else
		error("CascadeBadgeQuest:Route24(): [" .. getPlayerX() .. "," .. getPlayerY() .. "] is not a known position")
	end
end

function CascadeBadgeQuest:Route25()
	if not self:isTrainingOver() then
		moveToCell(8,30)
	elseif hasItem("Nugget") then
		return moveToMap("Item Maniac House") -- sell Nugget give $15.000
	elseif self:needPokecenter() then
		moveToCell(14, 30)
	elseif isNpcOnCell(16, 27) then -- RocketGuy -> Give Nugget($15.000)
		return talkToNpcOnCell(16, 27)
	elseif not dialogs.billTicketDone.state then
		return moveToMap("Bills House")
	else
		moveToCell(14, 30)
	end
end

function CascadeBadgeQuest:BillsHouse() -- get ticket 
	if dialogs.billTicketDone.state then
		return moveToMap("Route 25")
	else
		if dialogs.bookPillowDone.state then
			return talkToNpcOnCell(11, 3)
		else
			return talkToNpcOnCell(18, 2)
		end
	end
end

function CascadeBadgeQuest:ItemManiacHouse() -- sell nugget
	if hasItem("Nugget") then
		return talkToNpcOnCell(6, 5)
	else
		return moveToMap("Route 25")
	end
end

function CascadeBadgeQuest:CeruleanGym() -- get Cascade Badge
    state = false 
	if  not game.isTeamFullyHealed() then
		return moveToCell(51,136)
	elseif self:checkBadge() <= 1 and self:checkBadge() >= 0 then
		return talkToNpcOnCell(51, 109)
	elseif self:checkBadge() == 2  and not dialogs.npcafterbeat.state then 
	     return talkToNpcOnCell(55, 131)
	else 
	   return  moveToCell(51,136)
	end
end

return CascadeBadgeQuest
