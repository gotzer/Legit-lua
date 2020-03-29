--- Auto updater Variables
local SCRIPT_FILE_NAME = GetScriptName();
---local SCRIPT_FILE_ADDR = "https://raw.githubusercontent.com/gotzer/Legit-lua/master/legit.lua";
local BETA_SCIPT_FILE_ADDR = "https://raw.githubusercontent.com/gotzer/Legit-lua/master/betalegit.lua"
local VERSION_FILE_ADDR = "https://raw.githubusercontent.com/gotzer/Legit-lua/master/version.txt"; --- in case of update i need to update this. (Note by superyu'#7167 "so i don't forget it."
local VERSION_NUMBER = "1.23"; --- This too
local version_check_done = false;
local update_downloaded = false;
local update_available = false;
local betaUpdateDownloaded = false;
local isBeta = true;

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
local WALK_SPEED = 100;
local DRAW_MARKER_DISTANCE = 100;
local GH_ACTION_COOLDOWN = 30;
local GAME_COMMAND_COOLDOWN = 40;
local GRENADE_SAVE_FILE_NAME = "grenade_helper_data.dat";

--- Main
local visuals_ref = gui.Reference( "Visuals" );
local tab = gui.Tab( visuals_ref, "extra", "Gotzy™" );
local group_1 = gui.Groupbox( tab, "Visuals", 15, 15, 315);
local group_2 = gui.Groupbox( tab, "Viewmodel changer", 345, 15, 275);
local group_3 = gui.Groupbox( tab, "2", 345, 305, 275);
local group_4 = gui.Groupbox( tab, "3", 15, 305, 315);
local ref = gui.Reference("Misc", "Movement", "Strafe")

local TabPosition = gui.Reference("VISUALS");

local TAB = gui.Tab(TabPosition, "gh_tab", "Grenade Helper");

local MULTIBOX = gui.Groupbox(TAB, "Grenade Helper", 15, 15, 295, 400);

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

--- Ghelper

local GH_ENABLED = gui.Checkbox( MULTIBOX, "gh_enabled", "Grenade Helper Enabled", 1 );
local RECT_SIZE = gui.Slider(MULTIBOX, "gh_rect_size", "Throw Rect Size", 10, 0, 25);
local GH_CHECKBOX_THROWRECT = gui.Checkbox( MULTIBOX, "gh_ch_throw", "Throw Rectangle Enabled", 1 );
local GH_CHECKBOX_HELPERLINE = gui.Checkbox( MULTIBOX, "gh_ch_throwline", "Throw Helper Line Enabled", 1 );
local GH_CHECKBOX_BOXSTAND = gui.Checkbox( MULTIBOX, "gh_ch_standbox", "Stand Box Enabled", 1 );
local GH_CHECKBOX_OOD = gui.Checkbox( MULTIBOX, "gh_ch_standbox_ood", "Stand Box Out of Distance Custom Color Enabled", 1 );
local GH_CHECKBOX_TEXT = gui.Checkbox( MULTIBOX, "gh_ch_text", "Text Enabled (Name)", 1 );
local GH_VISUALS_DISTANCE_SL = gui.Slider(MULTIBOX, "gh_max_distance", "Max Distance", 3000, 0, 5000);
local THROW_RADIUS = gui.Slider(MULTIBOX, "gh_box_radius", "GH Box Size", 20, 0, 50);


local GH_CHECKBOX_KEYBINDS = gui.Checkbox( MULTIBOX, "gh_ch_keybinds", "Enable Keybinds", 0 );
local GH_ADD = gui.Keybox(MULTIBOX, "gh_kb_add", "Add Throw", 0);
local GH_REMOVE = gui.Keybox(MULTIBOX, "gh_kb_rem", "Remove Throw", 0);

local CLR_THROW = gui.ColorPicker(GH_CHECKBOX_THROWRECT, "gh_clr_throw", "Grenade Helper Throw Point", 255, 0, 0, 255);
local CLR_HELPER_LINE = gui.ColorPicker(GH_CHECKBOX_HELPERLINE, "gh_clr_helper", "Grenade Helper Line Color", 233, 212, 96, 255);
local CLR_STAND_BOX = gui.ColorPicker(GH_CHECKBOX_BOXSTAND, "gh_clr_standbox", "Grenade Helper Location", 0, 230, 64, 255);
local CLR_STAND_BOX_OOD = gui.ColorPicker(GH_CHECKBOX_OOD, "gh_clr_standbox_oop", "Grenade Helper Location (Out)", 22, 160, 133, 255);
local CLR_TEXT = gui.ColorPicker(GH_CHECKBOX_TEXT, "gh_clr_text", "Grenade Helper Text Color", 255, 255, 255, 255);

---Ghelper shit
local maps = {}

local GH_WINDOW_ACTIVE = false;

local window_show = false;
local window_cb_pressed = true;
local should_load_data = true;
local last_action = globals.TickCount();
local throw_to_add;
local chat_add_step = 1;
local message_to_say;
local my_last_message = globals.TickCount();
local screen_w, screen_h = 0,0;
local should_load_data = true;

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
local function Visuals_Viewmodel()

   if visuals_custom_viewmodel_editor:GetValue() then 
client.SetConVar("viewmodel_offset_x", xS:GetValue(), true);
client.SetConVar("viewmodel_offset_y", yS:GetValue(), true);
client.SetConVar("viewmodel_offset_z", zS:GetValue(), true);
client.SetConVar("viewmodel_fov", vfov:GetValue(), true);
   end
   end
local function Visuals_Disable_Post_Processing()
       if visuals_disable_post_processing:GetValue() then 
           client.SetConVar( "mat_postprocess_enable", 0, true );
   else
       client.SetConVar( "mat_postprocess_enable", 1, true );
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
	  
---More ghelper
local nade_type_mapping = {
    "auto",
    "smokegrenade",
    "flashbang",
    "hegrenade",
    "molotovgrenade";
    "decoy";
}

local throw_type_mapping = {
    "stand",
    "jump",
    "run",
    "crouch",
    "right",
	"leftright",
	"jumpcrouch",
	"jumpleftright",
	"jumpright",
	"runjump";
}

local chat_add_messages = {
    "[GH] Welcome to GH Setup. Type 'cancel' at any time to cancel. Please enter the name of the throw (e.g. CT to B site):",
    "[GH] Please enter the throw type (stand / jump / run / crouch / right / leftright / jumpcrouch / runjump / jumpleftright / jumpright):"
}

-- Just open up the file in append mode, should create the file if it doesn't exist and won't override anything if it does
local my_file = file.Open(GRENADE_SAVE_FILE_NAME, "a");
my_file:Close();

local current_map_name;

function gameEventHandler(event)
	if (GH_ENABLED:GetValue() == false) then
		return
	end

	local event_name = event:GetName();
	
    if (event_name == "player_say" and throw_to_add ~= nil) then
        local self_pid = client.GetLocalPlayerIndex();
        print(self_pid);
        local chat_uid = event:GetInt('userid');
        local chat_pid = client.GetPlayerIndexByUserID(chat_uid);
        print(chat_pid);

        if (self_pid ~= chat_pid) then
            return;
        end

        my_last_message = globals.TickCount();

        local say_text = event:GetString('text');

        if (say_text == "cancel") then
            message_to_say = "[GH] Throw cancelled";
            throw_to_add = nil;
            chat_add_step = 0;
            return;
        end

        -- Don't use the bot's messages
        if (string.sub(say_text, 1, 4) == "[GH]") then
            return;
        end

        -- Enter name
        if (chat_add_step == 1) then
            throw_to_add.name = say_text;
        elseif (chat_add_step == 2) then
            if (hasValue(throw_type_mapping, say_text) == false) then
                message_to_say = "[GH] The throw type '" .. say_text .. "' is invalid, please enter one of the following values: stand / jump / run / crouch / right";
                return;
            end

            throw_to_add.type = say_text;
            message_to_say = "[GH] Your throw '" .. throw_to_add.name .. "' - " .. throw_to_add.type .. " has been added.";
            table.insert(maps[current_map_name], throw_to_add);
            throw_to_add = nil;
            local value = convertTableToDataString(maps);
            local data_file = file.Open(GRENADE_SAVE_FILE_NAME, "w");
            if (data_file ~= nil) then
                data_file:Write(value);
                data_file:Close();
            end

            chat_add_step = 0;
            return;
        else
            chat_add_step = 0;
            return;
        end

        chat_add_step = chat_add_step + 1;
        message_to_say = chat_add_messages[chat_add_step];

        return;
    end
end

function doAdd(cmd)
	local me = entities.GetLocalPlayer();
    if (current_map_name == nil or maps[current_map_name] == nil or me == nil or not me:IsAlive()) then
        return;
    end
	
	local myPos = me:GetAbsOrigin();
	local angles = cmd:GetViewAngles();
	local nade_type = getWeaponName(me);
    if (nade_type ~= nil and nade_type ~= "smokegrenade" and nade_type ~= "flashbang" and nade_type ~= "molotovgrenade" and nade_type ~= "hegrenade" and nade_type ~= "decoy") then
        return;
    end
	
	local new_throw = {
        name = "",
        type = "not_set",
        nade = nade_type,
        pos = {
            x = myPos.x,
            y = myPos.y,
            z = myPos.z
        },
        ax = angles.x,
        ay = angles.y
    };
	
	throw_to_add = new_throw;
    chat_add_step = 1;
    message_to_say = chat_add_messages[chat_add_step];
end

function removeFirstThrow(throw)
    for i, v in ipairs(maps[current_map_name]) do
        if (v.name == throw.name and v.pos.x == throw.pos.x and v.pos.y == throw.pos.y and v.pos.z == throw.pos.z) then
            return table.remove(maps[current_map_name], i);
        end
    end
end

function doDel(throw)
	if (current_map_name == nil or maps[current_map_name] == nil) then
        return;
    end

    removeFirstThrow(throw);

    local value = convertTableToDataString(maps);
    local data_file = file.Open(GRENADE_SAVE_FILE_NAME, "w");
    if (data_file ~= nil) then
        data_file:Write(value);
        data_file:Close();
    end
end

function moveEventHandler(cmd)

	if (GH_ENABLED:GetValue() == false) then
		return
	end

	local me = entities.GetLocalPlayer();
	

    if (current_map_name == nil or maps == nil or maps[current_map_name] == nil or me == nil or not me:IsAlive()) then
        throw_to_add = nil;
        chat_add_step = 1;
        message_to_say = nil;
        return;
    end
	
	if (throw_to_add ~= nil) then
        return;
    end
	
	local add_keybind = GH_ADD:GetValue();
    local del_keybind = GH_REMOVE:GetValue();
	
	if (GH_CHECKBOX_KEYBINDS:GetValue() == false or (add_keybind == 0 and del_keybind == 0)) then
        return;
    end
	
	if (last_action ~= nil and last_action > globals.TickCount()) then
        last_action = globals.TickCount();
    end

    if (add_keybind ~= 0 and input.IsButtonDown(add_keybind) and globals.TickCount() - last_action > GH_ACTION_COOLDOWN) then
        last_action = globals.TickCount();
        return doAdd(cmd);
    end

    local closest_throw, distance = getClosestThrow(maps[current_map_name], me, cmd);
    if (closest_throw == nil or distance > THROW_RADIUS:GetValue()) then
        return;
    end

    if (del_keybind ~= 0 and input.IsButtonDown(del_keybind) and globals.TickCount() - last_action > GH_ACTION_COOLDOWN) then
        last_action = globals.TickCount();
        return doDel(closest_throw);
    end
end

function drawEventHandler()
	if (GH_ENABLED:GetValue() == false) then
		return
	end

    if (should_load_data) then
        loadData();
        should_load_data = false;
    end

    screen_w, screen_h = draw.GetScreenSize();

    local active_map_name = engine.GetMapName();

    -- If we don't have an active map, stop
    if (active_map_name == nil or maps == nil) then
        return;
    end

    if (maps[active_map_name] == nil) then
        maps[active_map_name] = {};
    end

    if (current_map_name ~= active_map_name) then
        current_map_name = active_map_name;
    end

    if (maps[current_map_name] == nil) then
        return;
    end

    if (my_last_message ~= nil and my_last_message > globals.TickCount()) then
        my_last_message = globals.TickCount();
    end

    if (message_to_say ~= nil and globals.TickCount() - my_last_message > 100) then
        client.ChatTeamSay(message_to_say);
        message_to_say = nil;
    end

    showNadeThrows();
end


function loadData()
    local data_file = file.Open(GRENADE_SAVE_FILE_NAME, "r");
    if (data_file == nil) then
        return;
    end
    local throw_data = data_file:Read();
    data_file:Close();
    if (throw_data ~= nil and throw_data ~= "") then
       maps = parseStringifiedTable(throw_data);
    end
end

function showNadeThrows()
    local me = entities:GetLocalPlayer();
	if (me == nil) then
        return;
    end

	local myPos = me:GetAbsOrigin();
    local weapon_name = getWeaponName(me);

    if (weapon_name ~= nil and weapon_name ~= "smokegrenade" and weapon_name ~= "flashbang" and weapon_name ~= "molotovgrenade" and weapon_name ~= "hegrenade" and weapon_name ~= "decoy") then
		if GH_CHECKBOX_FIXSTRAFE:GetValue() then
			gui.SetValue("misc.strafe.enable", 1);
		end
		if GH_CHECKBOX_FIXSTRAFEAIR:GetValue() then
			gui.SetValue("misc.strafe.air", 1);
		end
        return;
    end


    local throws_to_show, within_distance = getActiveThrows(maps[current_map_name], me, weapon_name);

	if GH_CHECKBOX_FIXSTRAFE:GetValue() then
		gui.SetValue("misc.strafe.enable", 1);
	end
	if GH_CHECKBOX_FIXSTRAFEAIR:GetValue() then
		gui.SetValue("misc.strafe.air", 1);
	end
	
    for i=1, #throws_to_show do
        local throw = throws_to_show[i];
				
		local throwVector = Vector3(throw.pos.x, throw.pos.y, throw.pos.z);
        local cx, cy = client.WorldToScreen(throwVector);

        if (within_distance) then
			if GH_CHECKBOX_FIXSTRAFE:GetValue() then
				gui.SetValue("misc.strafe.enable", 0);
			end
			if GH_CHECKBOX_FIXSTRAFEAIR:GetValue() then
				gui.SetValue("misc.strafe.air", 0);
			end
            local z_offset = 64;
            if (throw.type == "crouch") then
                z_offset = 46;
            end

            local t_x, t_y, t_z = getThrowPosition(throw.pos.x, throw.pos.y, throw.pos.z, throw.ax, throw.ay, z_offset);
			local drawVector = Vector3(t_x, t_y, t_z);
            local draw_x, draw_y = client.WorldToScreen(drawVector);
            if (draw_x ~= nil and draw_y ~= nil) then
				-- Draw rectangle for throw point
				if GH_CHECKBOX_THROWRECT:GetValue() then
					draw.Color(CLR_THROW:GetValue());
					local rSize = RECT_SIZE:GetValue();
					draw.RoundedRect(draw_x - rSize, draw_y - rSize, draw_x + rSize, draw_y + rSize);
				end
				
                -- Draw a line from the center of our screen to the throw position
				if GH_CHECKBOX_HELPERLINE:GetValue() then
					draw.Color(CLR_HELPER_LINE:GetValue());
					draw.Line(draw_x, draw_y, screen_w / 2, screen_h / 2);				
				end
				              
				-- Draw throw type
				if GH_CHECKBOX_TEXT:GetValue() then
					draw.Color(CLR_TEXT:GetValue());
					local text_size_w, text_size_h = draw.GetTextSize(throw.name);
					draw.Text(draw_x - text_size_w / 2, draw_y - 30 - text_size_h / 2, throw.name);
					text_size_w, text_size_h = draw.GetTextSize(throw.type);
					draw.Text(draw_x - text_size_w / 2, draw_y - 20 - text_size_h / 2, throw.type);
				end
            end
        end
		
    	local ulVector = Vector3(throw.pos.x - THROW_RADIUS:GetValue() / 2, throw.pos.y - THROW_RADIUS:GetValue() / 2, throw.pos.z);
        local ulx, uly = client.WorldToScreen(ulVector);
		local blVector = Vector3(throw.pos.x - THROW_RADIUS:GetValue() / 2, throw.pos.y + THROW_RADIUS:GetValue() / 2, throw.pos.z);
        local blx, bly = client.WorldToScreen(blVector);
		local urVector = Vector3(throw.pos.x + THROW_RADIUS:GetValue() / 2, throw.pos.y - THROW_RADIUS:GetValue() / 2, throw.pos.z);
        local urx, ury = client.WorldToScreen(urVector);
		local brVector = Vector3(throw.pos.x + THROW_RADIUS:GetValue() / 2, throw.pos.y + THROW_RADIUS:GetValue() / 2, throw.pos.z);
        local brx, bry = client.WorldToScreen(brVector);
	

		if (cx ~= nil and cy ~= nil and ulx ~= nil and uly ~= nil and blx ~= nil and bly ~= nil and urx ~= nil and ury ~= nil and brx ~= nil and bry ~= nil) then

			if(throw.distance < GH_VISUALS_DISTANCE_SL:GetValue()) then



				-- Draw name
				if (throw.name ~= nil) then
					if GH_CHECKBOX_TEXT:GetValue() then
						local text_size_w, text_size_h = draw.GetTextSize(throw.name);
						draw.Color(CLR_TEXT:GetValue());
						draw.Text(cx - text_size_w / 2, cy - 20 - text_size_h / 2, throw.name);
					end
				end

				-- Show radius as green when in distance, blue otherwise
				if (within_distance) then
					
					if GH_CHECKBOX_BOXSTAND:GetValue() then
						draw.Color(CLR_STAND_BOX:GetValue());
					else
						draw.Color(255, 255, 255, 0);
					end
				else		
					if GH_CHECKBOX_OOD:GetValue() then
						draw.Color(CLR_STAND_BOX_OOD:GetValue());
					end
				end
				
				
		
				-- Top left to rest
				draw.Line(ulx, uly, blx, bly);
		
				draw.Line(ulx, uly, urx, ury);
				draw.Line(ulx, uly, brx, bry);

				-- Bottom right to rest
				draw.Line(brx, bry, blx, bly);
				draw.Line(brx, bry, urx, ury);

				-- Diagonal
				draw.Line(blx, bly, urx, ury);
			end
		end
    end
end


function getThrowPosition(pos_x, pos_y, pos_z, ax, ay, z_offset)
    return pos_x - DRAW_MARKER_DISTANCE * math.cos(math.rad(ay + 180)), pos_y - DRAW_MARKER_DISTANCE * math.sin(math.rad(ay + 180)), pos_z - DRAW_MARKER_DISTANCE * math.tan(math.rad(ax)) + z_offset;
end

function getWeaponName(me)
    local my_weapon = me:GetPropEntity("m_hActiveWeapon");
    if (my_weapon == nil) then
        return nil;
    end

    local weapon_name = my_weapon:GetClass();
    weapon_name = weapon_name:gsub("CWeapon", "");
    weapon_name = weapon_name:lower();

    if (weapon_name:sub(1, 1) == "c") then
        weapon_name = weapon_name:sub(2)
    end

    if (weapon_name == "incendiarygrenade") then
        weapon_name = "molotovgrenade";
    end

    return weapon_name;
end

function getDistanceToTarget(my_x, my_y, my_z, t_x, t_y, t_z)
    local dx = my_x - t_x;
    local dy = my_y - t_y;
    local dz = my_z - t_z;
    return math.sqrt(dx*dx + dy*dy + dz*dz);
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function getActiveThrows(map, me, nade_name)
    local throws = {};
    local throws_in_distance = {};
    -- Determine if any are within range, we should only show those if that's the case
    for i=1, #map do

        local throw = map[i];
		
        if (throw ~= nil and throw.nade == nade_name) then
            local myPos = me:GetAbsOrigin();

            local distance = getDistanceToTarget(myPos.x, myPos.y, throw.pos.z, throw.pos.x, throw.pos.y, throw.pos.z);
            throw.distance = distance;
	
            if (distance < THROW_RADIUS:GetValue()) then
                table.insert(throws_in_distance, throw);
            else
                table.insert(throws, throw);
            end
        end
    end

    if (#throws_in_distance > 0) then
        return throws_in_distance, true;
    end

    return throws, false;
end

function getClosestThrow(map, me, cmd)
    local closest_throw;
    local closest_distance;
    local closest_distance_from_center;
    local myPos = me:GetAbsOrigin();
    for i = 1, #map do
        local throw = map[i];
        local distance = getDistanceToTarget(myPos.x, myPos.y, throw.pos.z, throw.pos.x, throw.pos.y, throw.pos.z);
        local z_offset = 64;
        if (throw.type == "crouch") then
            z_offset = 46;
        end
        local pos_x, pos_y, pos_z = getThrowPosition(throw.pos.x, throw.pos.y, throw.pos.z, throw.ax, throw.ay, z_offset);
		local drawVector = Vector3(pos_x, pos_y, pos_z);
        local draw_x, draw_y = client.WorldToScreen(drawVector);
        local distance_from_center;

        if (draw_x ~= nil and draw_y ~= nil) then
            distance_from_center = math.abs(screen_w / 2 - draw_x + screen_h / 2 - draw_y);
        end

        if (
        closest_distance == nil
                or (
        distance <= THROW_RADIUS:GetValue()
                and (
        closest_distance_from_center == nil
                or (closest_distance_from_center ~= nil and distance_from_center ~= nil and distance_from_center < closest_distance_from_center)
        )
        )
                or (
        (closest_distance_from_center == nil and distance < closest_distance)
        )
        ) then
            closest_throw = throw;
            closest_distance = distance;
            closest_distance_from_center = distance_from_center;
        end
    end

    return closest_throw, closest_distance;
end

function parseStringifiedTable(stringified_table)
    local new_map = {};

    local strings_to_parse = {};
    for i in string.gmatch(stringified_table, "([^\n]*)\n") do
        table.insert(strings_to_parse, i);
    end

    for i=1, #strings_to_parse do
        local matches = {};

        for word in string.gmatch(strings_to_parse[i], "([^,]*)") do
            table.insert(matches, word);
        end

        local map_name = matches[1];
        if new_map[map_name] == nil then
            new_map[map_name] = {};
        end

        table.insert(new_map[map_name], {
            name = matches[3],
            type = matches[5],
            nade = matches[7],
            pos = {
                x = tonumber(matches[9]),
                y = tonumber(matches[11]),
                z = tonumber(matches[13])
            },
            ax = tonumber(matches[15]),
            ay = tonumber(matches[17]);
        });
    end

    return new_map;
end

function convertTableToDataString(object)
    local converted = "";
    for map_name, map in pairs(object) do
        for i, throw in ipairs(map) do
            if (throw ~= nil) then
                converted = converted..map_name.. ','..throw.name..','..throw.type..','..throw.nade..','..throw.pos.x..','..throw.pos.y..','..throw.pos.z..','..throw.ax..','..throw.ay..'\n';
            end
        end
    end

    return converted;
end

function hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end



client.AllowListener("player_say");
callbacks.Register("FireGameEvent", "GH_EVENT", gameEventHandler);
callbacks.Register("CreateMove", "GH_MOVE", moveEventHandler);
callbacks.Register("Draw", "GH_DRAW", drawEventHandler);

--- Auto updater by ShadyRetard/Shady#0001 aka stole from RageSu
--local function handleUpdates()

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
        GOTZY_UPDATER_TEXT:SetText("Updates everytime when loaded.")
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
