--- Auto updater Variables
local SCRIPT_FILE_NAME = GetScriptName();
local SCRIPT_FILE_ADDR = "https://raw.githubusercontent.com/gotzer/Legit-lua/master/legit.lua";
local BETA_SCIPT_FILE_ADDR = "https://raw.githubusercontent.com/gotzer/Legit-lua/master/betalegit.lua"
local VERSION_FILE_ADDR = "https://raw.githubusercontent.com/gotzer/Legit-lua/master/version.txt"; --- in case of update i need to update this. (Note by superyu'#7167 "so i don't forget it."
local VERSION_NUMBER = "1.45"; --- This too
local version_check_done = false;
local update_downloaded = false;
local update_available = false;
local betaUpdateDownloaded = false;
local isBeta = false;

--- Auto Updater GUI Stuff
local GOTZY_UPDATER_TAB = gui.Tab(gui.Reference("Settings"), "gotzy.updater.tab", "Gotzy™ Autoupdater")
local GOTZY_UPDATER_GROUP = gui.Groupbox(GOTZY_UPDATER_TAB, "Auto Updater for Gotzy™ | v" .. VERSION_NUMBER, 15, 15, 600, 600)
local GOTZY_UPDATER_TEXT = gui.Text(GOTZY_UPDATER_GROUP, "")

local GOTZY_CHANGELOG_CONTENT = http.Get("https://raw.githubusercontent.com/gotzer/Legit-lua/master/changelog.txt")
if GOTZY_CHANGELOG_CONTENT ~= nil or GOTZY_CHANGELOG_CONTENT ~= "" then
    local GOTZY_CHANGELOG_TEXT = gui.Text(GOTZY_UPDATER_GROUP, GOTZY_CHANGELOG_CONTENT)
end

---Somewhat important variables
local xO = client.GetConVar("viewmodel_offset_x"); 
local yO = client.GetConVar("viewmodel_offset_y"); 
local zO = client.GetConVar("viewmodel_offset_z");
local fO = client.GetConVar("viewmodel_fov");  
local activeVotes = {};
local font = draw.CreateFont('Arial', 14, 14);
local votecolor = {};
local animend = 0;
local votername = ""
local votetype = 0
local votetarget = ""
local enemyvote = 0
local yescount = 0
local nocount = 0
local voteresult = 0
local displayed = 0


--- Main
local visuals_ref = gui.Reference( "Visuals" );
local tab = gui.Tab( visuals_ref, "extra", "Gotzy™" );
local group_1 = gui.Groupbox( tab, "Visuals", 15, 15, 315);
local group_2 = gui.Groupbox( tab, "Viewmodel changer", 345, 15, 275);
local group_3 = gui.Groupbox( tab, "2", 345, 305, 275);
local group_4 = gui.Groupbox( tab, "3", 15, 305, 315);
local ref = gui.Reference("Misc", "Movement", "Strafe");

local visuals_menu = gui.Reference("visuals", "Gotzy™", "Viewmodel changer")
local visuals_custom_viewmodel_editor = gui.Checkbox( visuals_menu, "lua_custom_viewmodel_editor", "Custom Viewmodel Editor", 0 );

local g_Group = gui.Groupbox(gui.Reference("MISC", "Enhancement"), "Vote Revealer", 327,315, 297)
local g_BroadcastMode = gui.Combobox(g_Group, "msc_voterevealer_broadcast", "Vote Revealer Broadcast Mode", "Off", "Broadcast Team", "Broadcast All", "Broadcast Console")
local g_Draw = gui.Checkbox(g_Group, "msc_voterevealer_draw", "Vote Revealer Draw", false)
local g_DrawVotes = gui.Checkbox(g_Group, "msc_voterevealer_drawvotes", "Vote Revealer Draw Votes", false)
g_Draw:SetValue(true)
g_DrawVotes:SetValue(true)

---Items
gui.Checkbox( group_1, "old_wep_esp", "Old weapon ESP", false );
gui.Checkbox( group_1, "old_hp_esp", "Old HP indicator", false );
gui.Checkbox( group_1, "nade_esp", "Grenade ESP", false );
gui.Checkbox( group_1, "night_mode", "Night mode", false );
local old_night_mode_value = gui.GetValue( "esp.extra.night_mode" );

---Other
gui.Checkbox( group_1, "vis_sniper_crosshair", "Sniper crosshair", 0)

local xS = gui.Slider(visuals_menu, "lua_x", "X", xO, -20, 20);  
local yS = gui.Slider(visuals_menu, "lua_y", "Y", yO, -100, 100);  
local zS = gui.Slider(visuals_menu, "lua_z", "Z", zO, -20, 20);  
local vfov = gui.Slider(visuals_menu, "vfov", "Viewmodel FOV", fO, 0, 120);

---AutoStrafe
local pLocal = entities.GetLocalPlayer()
function js_fix()
    pLocal = entities.GetLocalPlayer()
    local velocity = math.sqrt(pLocal:GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + pLocal:GetPropFloat( "localdata", "m_vecVelocity[1]" )^2)

    if velocity > 5 then
        gui.SetValue("misc.strafe.enable", true)
    else
        gui.SetValue("misc.strafe.enable", false)
    end
end

---Snipercrosshair
local function drawing_callback()

local player_local = entities.GetLocalPlayer();

if player_local == nil then
    return;
end


local scoped = player_local:GetProp("m_bIsScoped");

if scoped == 1 then
client.SetConVar("weapon_debug_spread_show", 0, true);
end
if scoped == 0 then
client.SetConVar("weapon_debug_spread_show", 1, true);
client.SetConVar("weapon_debug_spread_gap", 5, true);
end
end
callbacks.Register("Draw", "force_crosshair_draw", drawing_callback);

---Old esp
local function GetWpnName( x )
	if x == 1 then return "desert eagle" end
	if x == 2 then return "dual berettas" end
	if x == 3 then return "five-seven" end
	if x == 4 then return "glock-18" end
	if x == 7 then return "ak-47" end
	if x == 8 then return "aug" end
	if x == 9 then return "awp" end
	if x == 10 then return "famas" end
	if x == 11 then return "g3sg1" end
	if x == 13 then return "galil ar" end
	if x == 14 then return "m249" end
	if x == 16 then return "m4a4" end
	if x == 17 then return "mac-10" end
	if x == 19 then return "p90" end
	if x == 23 then return "mp5-sd" end
	if x == 24 then return "ump-45" end
	if x == 25 then return "xm1014" end
	if x == 26 then return "pp-bizon" end
	if x == 27 then return "mag-7" end
	if x == 28 then return "negev" end
	if x == 29 then return "sawed-off" end
	if x == 30 then return "tec-9" end
	if x == 31 then return "zeus x27" end
	if x == 32 then return "p2000" end
	if x == 33 then return "mp7" end
	if x == 34 then return "mp9" end
	if x == 35 then return "nova" end
	if x == 36 then return "p250" end
	if x == 37 then return "ballistic shield" end
	if x == 38 then return "scar-20" end
	if x == 39 then return "sg 553" end
	if x == 40 then return "ssg 08" end
	if x == 41 then return "knife" end
	if x == 42 then return "knife" end
	if x == 43 then return "flashbang" end
	if x == 44 then return "high explosive grenade" end
	if x == 45 then return "smoke grenade" end
	if x == 46 then return "molotov" end
	if x == 47 then return "decoy grenade" end
	if x == 48 then return "incendiary grenade" end
	if x == 49 then return "c4 explosive" end
	if x == 50 then return "kevlar vest" end
	if x == 51 then return "kevlar + helmet" end
	if x == 52 then return "heavy assault suit" end
	if x == 54 then return "item_nvg" end
	if x == 55 then return "defuse kit" end
	if x == 56 then return "rescue kit" end
	if x == 57 then return "medi-shot" end
	if x == 58 then return "music kit" end
	if x == 59 then return "knife" end
	if x == 60 then return "m4a1-s" end
	if x == 61 then return "usp-s" end
	if x == 60 then return "m4a1-s" end
	if x == 61 then return "usp-s" end
	if x == 63 then return "cz75-auto" end
	if x == 64 then return "r8 revolver" end
	if x == 68 then return "tactical awareness grenade" end
	if x == 69 then return "bare hands" end
	if x == 70 then return "breach charge" end
	if x == 72 then return "tablet" end
	if x == 75 then return "axe" end
	if x == 76 then return "hammer" end
	if x == 78 then return "wrench" end
	if x == 80 then return "spectral shiv" end
	if x == 81 then return "fire bomb" end
	if x == 82 then return "diversion device" end
	if x == 83 then return "frag grenade" end
	if x == 84 then return "snowball" end
	if x == 85 then return "bump mine" end
	if x == 5027 then return "bloodhound gloves" end
	if x == 5028 then return "default t gloves" end
	if x == 5029 then return "default ct gloves" end
	if x == 5030 then return "sport gloves" end
	if x == 5031 then return "driver gloves" end
	if x == 5032 then return "hand wraps" end
	if x == 5033 then return "moto gloves" end
	if x == 5034 then return "specialist gloves" end
	if x == 5035 then return "hydra gloves" end
	if x == 5036 then return "local t agent" end
	if x == 5037 then return "local ct agent" end
end

local function DarkenMaterials( mat )
	local group = mat:GetTextureGroupName();

	if group == "World textures" or group == "StaticProp textures" or group == "SkyBox textures" then
		local modulate = ( group == "StaticProp textures" ) and 0.5 or 0.25;
		mat:ColorModulate( modulate, modulate, modulate );
	end
end

local function RestoreMaterials( mat ) 
	mat:ColorModulate( 1.0, 1.0, 1.0 );
end

--------------------
-- callbacks
--------------------
local function OnDrawESP( builder )
    local ent = builder:GetEntity();
    local localply = entities.GetLocalPlayer();
	
	--------------------
	-- old esp
	--------------------
	if ent:IsPlayer() and ent:GetTeamNumber() ~= localply:GetTeamNumber() then
		if gui.GetValue( "esp.extra.old_wep_esp" ) then
			local id = ent:GetWeaponID();
	    	builder:AddTextBottom( GetWpnName( id ) );
		end

		if gui.GetValue( "esp.extra.old_hp_esp" ) then
			builder:AddTextLeft( ent:GetHealth() .. " HP" .. " " );
		end 
	end
end

local function OnDraw( )
	--------------------
	-- nightmode ui check
	--------------------
	if gui.GetValue( "esp.extra.night_mode" ) ~= old_night_mode_value then
		if gui.GetValue( "esp.extra.night_mode" ) then
			materials.Enumerate( DarkenMaterials )
		else
			materials.Enumerate( RestoreMaterials )
		end
	end

	old_night_mode_value = gui.GetValue( "esp.extra.night_mode" );

	--------------------
	-- ugly wip nade esp
	--------------------
	if gui.GetValue( "esp.extra.nade_esp") then
		local nades = entities.FindByClass( "CBaseCSGrenadeProjectile" );
		for i = 1, #nades do
			local x, y = client.WorldToScreen( nades[ i ]:GetAbsOrigin() );
			if x ~= nil then
				draw.Color( 0, 0, 0, 250 )
				draw.FilledRect( x - 1, y - 1, x + 7, y + 7);

				draw.Color( 255, 0, 0, 255 );			
				draw.FilledRect( x, y, x + 5, y + 5);
			end
		end
	end
end

local function OnEvent( event )
	local name = event:GetName();

	--------------------
	-- check nightmode on round start, respawn, etc
	--------------------
	if name == "round_start" or name == "round_end" or name == "cs_pre_restart" or name == "start_halftime" or ( name == "player_spawned" and event:GetInt( "userid" ) == client.GetLocalPlayerIndex( ) ) then
		if gui.GetValue( "esp.extra.night_mode" ) then
			materials.Enumerate( DarkenMaterials )
		else
			materials.Enumerate( RestoreMaterials )
		end
	end
end

callbacks.Register( "DrawESP", OnDrawESP );
callbacks.Register( "Draw", OnDraw );
callbacks.Register( "FireGameEvent", OnEvent );

---Fov Changer
-- Field of View Changer by GhostZ (https://aimware.net/forum/user-271217.html)
local function fieldofview()
    if fieldofviewchanger_checkbox:GetValue() and viewfov_slider:GetValue() and viewmodelfov_slider:GetValue() and viewmodeloffsetx_slider:GetValue() and viewmodeloffsety_slider:GetValue() and viewmodeloffsetz_slider:GetValue() then
        client.SetConVar("fov_cs_debug", viewfov_slider:GetValue(), true)
        client.SetConVar("viewmodel_fov", viewmodelfov_slider:GetValue(), true);
        client.SetConVar("viewmodel_offset_x", viewmodeloffsetx_slider:GetValue(), true);
        client.SetConVar("viewmodel_offset_y", viewmodeloffsety_slider:GetValue(), true);
        client.SetConVar("viewmodel_offset_z", viewmodeloffsetz_slider:GetValue(), true);
    end
end

callbacks.Register("Draw", "Custom Viewmodel Editor", Visuals_Viewmodel)

---vote reveal
local timer = timer or {}
local timers = {}

local function timerCreate(name, delay, times, func)

  table.insert(timers, {["name"] = name, ["delay"] = delay, ["times"] = times, ["func"] = func, ["lastTime"] = globals.RealTime()})

end

local function timerRemove(name)

  for k,v in pairs(timers or {}) do

    if (name == v["name"]) then table.remove(timers, k) end

  end

end

local function timerTick()

  for k,v in pairs(timers or {}) do

    if (v["times"] <= 0) then table.remove(timers, k) end

    if (v["lastTime"] + v["delay"] <= globals.RealTime()) then
      timers[k]["lastTime"] = globals.RealTime()
      timers[k]["times"] = timers[k]["times"] - 1
      v["func"]()
    end

  end

end

callbacks.Register( "Draw", "timerTick", timerTick);

local function startTimer()
  timerCreate("sleep", 4, 1, function() animend = 1; enemyvote = 0; voteresult = 0; displayed = 0 end)
end

local function getVoteEnd(um)
  if gui.GetValue("misc.master") == false then return end
  if um:GetID() == 47 or um:GetID() == 48 then
    startTimer()
    yescount = 0
    nocount = 0
    enemyvote = 2

    if um:GetID() == 47 then
      voteresult = 1
      if (g_BroadcastMode:GetValue() == 1) then
        client.ChatTeamSay("Vote Passed")
      elseif (g_BroadcastMode:GetValue() == 2) then
        client.ChatSay("Vote Passed")
      elseif (g_BroadcastMode:GetValue() == 3) then
        print("Vote Passed")
      end
    end
    if um:GetID() == 48 then
      voteresult = 2
      if (g_BroadcastMode:GetValue() == 1) then
        client.ChatTeamSay("Vote Failed")
      elseif (g_BroadcastMode:GetValue() == 2) then
        client.ChatSay("Vote Failed")
      elseif (g_BroadcastMode:GetValue() == 3) then
        print("Vote Failed")
      end
    end
  end

  if um:GetID() == 46 then
    local localPlayer = entities.GetLocalPlayer();
    local team = um:GetInt(1)
    local idx = um:GetInt(2)
    votetype = um:GetInt(3)
    votetarget = um:GetString(5)
    votername = client.GetPlayerNameByIndex(idx)
    if localPlayer:GetTeamNumber() ~= team and votetype ~= 1 then
      enemyvote = 1
      displayed = 1
    end

    if votetype == 0 then
      votetypename = "kick player: "
    elseif votetype == 6 then
      votetypename = "Surrender"
    elseif votetype == 13 then
      votetypename = "Call a timeout"
    end

    if (g_BroadcastMode:GetValue() == 1) then
      client.ChatTeamSay(votername .. " wants to " .. votetypename .. votetarget)
    elseif (g_BroadcastMode:GetValue() == 2) then
      client.ChatSay(votername .. " wants to " .. votetypename .. votetarget)
    elseif (g_BroadcastMode:GetValue() == 3) then
      print(votername .. " wants to " .. votetypename .. votetarget)
    end
  end
  end;

  callbacks.Register("DispatchUserMessage", getVoteEnd)

  -- Vote revealer by Cheeseot


  local function add(time, ...)
    table.insert(activeVotes, {
      ["text"] = { ... },
      ["time"] = time,
      ["delay"] = globals.RealTime() + time,
      ["color"] = {votecolor, {10, 10, 10}},
      ["x_pad"] = -11,
      ["x_pad_b"] = -11,
    })
  end

  local function getMultiColorTextSize(lines)
    local fw = 0
    local fh = 0;
    for i = 1, #lines do
      draw.SetFont(font);
      local w, h = draw.GetTextSize(lines[i][4])
      fw = fw + w
      fh = h;
    end
    return fw, fh
  end

  local function drawMultiColorText(x, y, lines)
    local x_pad = 0
    for i = 1, #lines do
      local line = lines[i];
      local r, g, b, msg = line[1], line[2], line[3], line[4]
      draw.SetFont(font);
      draw.Color(r, g, b, 255);
      draw.Text(x + x_pad, y, msg);
      local w, _ = draw.GetTextSize(msg)
      x_pad = x_pad + w
    end
  end

  local function showVotes(count, color, text, layer)
    local y = 650 + (42 * (count - 1));
    local w, h = getMultiColorTextSize(text)
    local mw = w < 50 and 50 or w
    if globals.RealTime() < layer.delay then
      if layer.x_pad < mw then layer.x_pad = layer.x_pad + (mw - layer.x_pad) * 0.05 end
      if layer.x_pad > mw then layer.x_pad = mw end
      if layer.x_pad > mw / 1.09 then
        if layer.x_pad_b < mw - 6 then
          layer.x_pad_b = layer.x_pad_b + ((mw - 6) - layer.x_pad_b) * 0.05
        end
      end
      if layer.x_pad_b > mw - 6 then
        layer.x_pad_b = mw - 6
      end
    elseif animend == 1 then
      if layer.x_pad_b > -11 then
        layer.x_pad_b = layer.x_pad_b - (((mw - 5) - layer.x_pad_b) * 0.05) + 0.01
      end
      if layer.x_pad_b < (mw - 11) and layer.x_pad >= 0 then
        layer.x_pad = layer.x_pad - (((mw + 1) - layer.x_pad) * 0.05) + 0.01
      end
      if layer.x_pad < 0 then
        table.remove(activeVotes, count)
      end
    end
    local c1 = color[1]
    local c2 = color[2]
    local a = 255;
    if(g_DrawVotes:GetValue()) then
      draw.Color(c1[1], c1[2], c1[3], a);
      draw.FilledRect(layer.x_pad - layer.x_pad, y, layer.x_pad + 28, (h + y) + 20);
      draw.Color(c2[1], c2[2], c2[3], a);
      draw.FilledRect(layer.x_pad_b - layer.x_pad, y, layer.x_pad_b + 22, (h + y) + 20);
      drawMultiColorText(layer.x_pad_b - mw + 18, y + 9, text)
    end
  end

  -- Vote revealer by Cheeseot


  local function voteCast(e)
    if gui.GetValue("misc.master") == false then return end
    if (e:GetName() == "vote_cast") then
      timerRemove("sleep")
      animend = 0;
      local index = e:GetInt("entityid");
      local vote = e:GetInt("vote_option");
      local name = client.GetPlayerNameByIndex(index)

      local votearray = {};
      local namearray = {};
      if vote == 0 then
        votearray = { 150, 185, 1, "YES" }
        namearray = { 150, 185, 1, name }
        votecolor = { 150, 185, 1}
        yescount = yescount + 1
      elseif vote == 1 then
        votearray = { 185, 20, 1, "NO" }
        namearray = { 185, 20, 1, name }
        votecolor = { 185, 20, 1}
        nocount = nocount + 1
      else
        votearray = { 150, 150, 150, "??" }
        namearray = { 150, 150, 150, name }
        votecolor = { 150, 150, 150}
      end

      if (g_BroadcastMode:GetValue() == 1) then
        client.ChatTeamSay(name .. " voted: " .. votearray[4])
      elseif (g_BroadcastMode:GetValue() == 2) then
        client.ChatSay(name .. " voted: " .. votearray[4])
      elseif (g_BroadcastMode:GetValue() == 3) then
        print(name .. " voted: " .. votearray[4])
      end

      add(3,
      namearray,
      { 255, 255, 255, " voted: " },
      votearray,
      { 255, 255, 255, "   " });
    end
    end;

    callbacks.Register('FireGameEvent', voteCast)

    local function makeVote()
      for index, votes in pairs(activeVotes) do
        showVotes(index, votes.color, votes.text, votes)
      end
      end;

      callbacks.Register('Draw', makeVote)

      client.AllowListener("vote_cast")


      local function drawVote()
        if gui.GetValue("misc.master") == false then return end
        local font2 = draw.CreateFont('Arial', 20, 20);
        draw.SetFont(font2)
        local votetypename = ""
        if(g_Draw:GetValue()) then
          if enemyvote == 1 then
            if votetype == 0 then
              votetypename = "kick player: "
            elseif votetype == 6 then
              votetypename = "Surrender"
            elseif votetype == 13 then
              votetypename = "Call a timeout"
            else return
            end
            draw.Color(255,150,0,255)
            draw.FilledRect(0, 525, draw.GetTextSize(votername .. " wants to " .. votetypename .. votetarget) + 30, 625)
            draw.Color(10,10,10,255)
            draw.FilledRect(0, 525, draw.GetTextSize(votername .. " wants to " .. votetypename .. votetarget) + 20, 625)
            draw.Color(150,185,1,255)
            draw.Text(5 + (draw.GetTextSize(votername .. " wants to " .. votetypename .. votetarget) / 2) - 25 - (draw.GetTextSize("  Yes")), 595, yescount .. " Yes")
            draw.Color(185,20,1,255)
            draw.Text(5 + (draw.GetTextSize(votername .. " wants to " .. votetypename .. votetarget) / 2) + 25 , 595, nocount .. " No")
            draw.Color(255,150,0,255)
            draw.Text(5, 550, votername)
            draw.Color(255,255,255,255)
            draw.Text(draw.GetTextSize(votername .. " ") + 5, 550, "wants to ")
            if votetype == 0 then draw.Color(255,255,255,255) else draw.Color(255,150,0,255) end
            draw.Text(draw.GetTextSize(votername .. " wants to ") + 5, 550, votetypename)
            draw.Color(255,150,0,255)
            draw.Text(draw.GetTextSize(votername .. " wants to " .. votetypename) + 5, 550, votetarget)
          elseif enemyvote == 2 and displayed == 1 then
            if voteresult == 1 then
              draw.Color(150,185,1,255)
              draw.FilledRect(0, 525, draw.GetTextSize(votername .. " wants to " .. votetypename .. votetarget) + 30, 625)
              draw.Color(10,10,10,255)
              draw.FilledRect(0, 525, draw.GetTextSize(votername .. " wants to " .. votetypename .. votetarget) + 20, 625)
              draw.Color(150,185,1,255)
              draw.Text(5, 575 - 10 , "Vote Passed.")
            elseif voteresult == 2 then
              draw.Color(185,20,1,255)
              draw.FilledRect(0, 525, draw.GetTextSize("Vote Failed.") + 110, 625)
              draw.Color(10,10,10,255)
              draw.FilledRect(0, 525, draw.GetTextSize("Vote Failed.") + 100, 625)
              draw.Color(185,20,1,255)
              draw.Text(50, 575 - 10, "Vote Failed.")
            end
          end
        end
      end

      callbacks.Register("Draw", drawVote)

      local function reset()
        if entities.GetLocalPlayer() == nil then
          enemyvote = 0;
          activeVotes = {};
          displayed = 0;
        end
      end
      callbacks.Register("Draw", reset)
	  
--- Auto updater by ShadyRetard/Shady#0001
local function handleUpdates()

    if (update_available and not update_downloaded) then
        GOTZY_UPDATER_TEXT:SetText("Update is getting downloaded.")
        local new_version_content = http.Get(SCRIPT_FILE_ADDR);
        local old_script = file.Open(SCRIPT_FILE_NAME, "w");
        old_script:Write(new_version_content);
        old_script:Close();
        update_available = false;
        update_downloaded = true;
    end

    if (update_downloaded) then
        GOTZY_UPDATER_TEXT:SetText("Update available, please reload the script.")
        return;
    end

    if (not version_check_done) then
        version_check_done = true;
        local version = http.Get(VERSION_FILE_ADDR);
        if (version ~= VERSION_NUMBER) then
            update_available = true;
        end
        if not betaUpdateDownloaded then
            if isBeta then
                GOTZY_UPDATER_TEXT:SetText("You are using the newest Beta client. Current Version: v" .. VERSION_NUMBER .. " Beta Build")
            else
                GOTZY_UPDATER_TEXT:SetText("Your client is up to date. Current Version: v" .. VERSION_NUMBER .. " Stable Build")
            end
        end
    end
end

callbacks.Register("Draw", handleUpdates)
