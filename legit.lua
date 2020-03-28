--- Auto updater Variables
local SCRIPT_FILE_NAME = GetScriptName();
local SCRIPT_FILE_ADDR = "https://raw.githubusercontent.com/gotzer/Legit-lua/new/master";
local BETA_SCIPT_FILE_ADDR = "https://raw.githubusercontent.com/superyor/RageSU/master/RageSU%20Beta.lua"
local VERSION_FILE_ADDR = "https://raw.githubusercontent.com/superyor/RageSU/master/version.txt"; --- in case of update i need to update this. (Note by superyu'#7167 "so i don't forget it."
local VERSION_NUMBER = "4.1"; --- This too
local version_check_done = false;
local update_downloaded = false;
local update_available = false;
local betaUpdateDownloaded = false;
local isBeta = true;

--- Auto Updater GUI Stuff
local GOTZY_UPDATER_TAB = gui.Tab(gui.Reference("Settings"), "gotzy.updater.tab", "Gotzy™ Autoupdater")
local GOTZY_UPDATER_GROUP = gui.Groupbox(GOTZY_UPDATER_TAB, "Auto Updater for Gotzy™ | v" .. VERSION_NUMBER, 15, 15, 600, 600)
local GOTZY_UPDATER_TEXT = gui.Text(GOTZY_UPDATER_GROUP, "")

local GOTZY_CHANGELOG_CONTENT = http.Get("https://raw.githubusercontent.com/superyor/RageSU/master/changelog.txt")
if GOTZY_CHANGELOG_CONTENT ~= nil or GOTZY_CHANGELOG_CONTENT ~= "" then
    local GOTZY_CHANGELOG_TEXT = gui.Text(GOTZY_UPDATER_GROUP, GOTZY_CHANGELOG_CONTENT)
end

--- News GUI Stuff
local GOTZY_NEWS_TAB = gui.Tab(gui.Reference("Settings"), "Gotzy.news.tab", "Gotzy™ News")
local GOTZY_NEWS_GROUP = gui.Groupbox(GOTZY_NEWS_TAB, "Latest News for the Gotzy™ | v" .. VERSION_NUMBER, 15, 15, 600, 600)
local GOTZY_NEWS_CONTENT = http.Get("https://raw.githubusercontent.com/superyor/RageSU/master/news.txt")
if GOTZY_NEWS_CONTENT ~= nil or GOTZY_NEWS_CONTENT ~= "" then
    local GOTZY_NEWS_TEXT = gui.Text(GOTZY_NEWS_GROUP, GOTZY_NEWS_CONTENT)
end



---Somewhat important variables
local xO = client.GetConVar("viewmodel_offset_x"); 
local yO = client.GetConVar("viewmodel_offset_y"); 
local zO = client.GetConVar("viewmodel_offset_z");
local fO = client.GetConVar("viewmodel_fov");  


--- Main
local visuals_ref = gui.Reference( "Visuals" );
local tab = gui.Tab( visuals_ref, "extra", "Gotzy™" );
local group_1 = gui.Groupbox( tab, "Visuals", 15, 15, 315);
local group_2 = gui.Groupbox( tab, "1", 345, 15, 275);
local group_3 = gui.Groupbox( tab, "2", 345, 305, 275);
local group_4 = gui.Groupbox( tab, "3", 15, 305, 315);
local ref = gui.Reference("Misc", "Movement", "Strafe")
local cb = gui.Checkbox(ref,"active", "Strafe FIX", 0)

local visuals_menu = gui.Reference("visuals", "Gotzy™", "1")
local visuals_custom_viewmodel_editor = gui.Checkbox( visuals_menu, "lua_custom_viewmodel_editor", "Custom Viewmodel Editor", 0 );


---Items
gui.Checkbox( group_1, "old_wep_esp", "Old weapon ESP", false );
gui.Checkbox( group_1, "old_hp_esp", "Old HP indicator", false );
gui.Checkbox( group_1, "nade_esp", "Grenade ESP", false );
gui.Checkbox( group_1, "night_mode", "Night mode", false );
local old_night_mode_value = gui.GetValue( "esp.extra.night_mode" );

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

callbacks.Register("CreateMove", js_fix)
callbacks.Register("CreateMove", js_hc)

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
	-- fov changer
	--------------------
	if gui.GetValue( "esp.extra.fov_enable" ) then
		client.SetConVar( "fov_cs_debug", gui.GetValue("esp.extra.fov_val" ), true );
	else
		client.SetConVar( "fov_cs_debug", 0, true );
	end

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
