
--[[
=head1 NAME

applets.DaylightClock.DayLightClockMeta - Daylight Clock meta-info

=head1 DESCRIPTION

See L<applets.DaylightClock.DaylightClockApplet>.

=head1 FUNCTIONS

See L<jive.AppletMeta> for a description of standard applet meta functions.

=cut
--]]


local oo            = require("loop.simple")
local datetime         = require("jive.utils.datetime")

local AppletMeta    = require("jive.AppletMeta")
local jul           = require("jive.utils.log")

local appletManager = appletManager
local jiveMain      = jiveMain


module(...)
oo.class(_M, AppletMeta)


function jiveVersion(self)
	return 1, 1
end

function registerApplet(self)
        jiveMain:addItem(self:menuItem('appletDaylightClock', 'screenSettings', "SCREENSAVER_DAYLIGHTCLOCK_SETTINGS",
                function(applet, ...) applet:openSettings(...) end, 105))
end

function configureApplet(self)
	appletManager:callService("addScreenSaver", 
		self:string("SCREENSAVER_DAYLIGHTCLOCK"), 
		"DaylightClock",
		"openScreensaver", 
		_, 
		_, 
		90)
end

function defaultSettings(self)
        local defaultSetting = {}
        defaultSetting["perspective"] = "/earth/hemispheredawnduskmoon"
	if datetime:getHours()==12 then
	        defaultSetting["item1" ] = "%I:%M"
	else
	        defaultSetting["item1" ] = "%H:%M"
	end
        defaultSetting["item2" ] = "%a"
        defaultSetting["item3" ] = "%d %b"
        defaultSetting["copyright"] = "http://www.die.net/earth"
        defaultSetting["nowplaying"] = true
        return defaultSetting
end

--[[

=head1 LICENSE

Copyright (C) 2009 Erland Isaksson (erland_i@hotmail.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

=cut
--]]

