// -------------------Includes-------------------
#include <a_samp>
#include <YSI\Y_ini>
#include <sscanf2>
#include <a_mysql>
#include <strlib>
#include <cam>
#include <colors>
#include <streamer>
#include <zcmd>

// -------------------Defines-------------------
#define GAMEMODE "Türkiye Topluluðu"

#define COL_WHITE "{FFFFFF}"
#define COL_RED "{AA3333}"

#define MYSQL_HOST "127.0.0.1"
#define MYSQL_USERNAME "root"
#define MYSQL_PASSWORD ""
#define MYSQL_DATABASE "cnr"

#define MAX_HOUSES 20
#define MAX_JOBS 15

// -------------------Variable Declarations-------------------
new MySQL:g_SQL;
new currentsetting[MAX_PLAYERS];
new newhouseid;
new currenthouseid[MAX_PLAYERS] = -1;
new currenthousebuyid[MAX_PLAYERS] = -1;
new currenthousesellid[MAX_PLAYERS] = -1;
new currenthousesellprice[MAX_PLAYERS] = -1;
new currenthouseselltargetid[MAX_PLAYERS] = -1;
new currenthousepermid[MAX_PLAYERS] = -1;
new moneytimer[MAX_PLAYERS];
new passchances[MAX_PLAYERS];
new regflag[MAX_PLAYERS] = -1;

// Job Variables
new fruitsbuyprice;
new mealbuyprice;
new weaponpartsbuyprice;
new shoesbuyprice;
new weaponsbuyprice;
new ammobuyprice;
new fruitssellprice;
new mealsellprice;
new weaponpartssellprice;
new shoessellprice;
new weaponssellprice;
new ammosellprice;
new newjobid = 1;
new currentjobid = -1;
new truckerspawnpickup;
new isbuyingprod[MAX_PLAYERS];
new truckerpickedup[MAX_PLAYERS];
new truckervehid[MAX_PLAYERS];
new truckerspawned[MAX_PLAYERS];
new truckerboughtprod[MAX_PLAYERS];
new truckercurobj[MAX_PLAYERS];

enum PlayerInfo {
	playerID,
	playerName[255],
	playerEmail[255],
	playerPassword[129],
	playerAffiliateId,
	playerLoginDay,
	playerLoginMonth,
	playerLoginYear,
	playerLoginHour,
	playerLoginMin,
	playerLoginSec,
	playerCash,
	playerPmStatus,
	playerMusic,
	playerHitSound,
	playerPMColor,
	playerNotificationColor,
	playerSquadColor,
	playerGroupColor,
	playerGangColor,
	playerLocalColor,
	playerCarWhisperColor,
	playerWhisperColor,
	playerType,
	playerAdminLevel,
	playerHouses,
	playerHouse1,
	playerHouse2,
	playerHouse3,
	playerHouse4,
	playerLastSpawn,
	playerSkin,
	playerJob,
	playerTruckerRank,
	playerTruckerRankPoints
};
new Player[MAX_PLAYERS][PlayerInfo];

enum HouseInfo {
	houseID,
	Float:housePositionX,
	Float:housePositionY,
	Float:housePositionZ,
	Float:houseExitX,
	Float:houseExitY,
	Float:houseExitZ,
	houseOwner,
	housePrice,
	houseInterior,
	houseIcon,
	housePickup,
	houseActualInterior,
	houseLastPrice,
	houseGangEnterPerm,
	houseGangFurniturePerm,
	houseGangCasePerm,
	houseGangInventoryPerm,
	houseSquadEnterPerm,
	houseSquadFurniturePerm,
	houseSquadCasePerm,
	houseSquadInventoryPerm,
	houseGroupEnterPerm,
	houseGroupFurniturePerm,
	houseGroupCasePerm,
	houseGroupInventoryPerm,
	houseFriendsEnterPerm,
	houseFriendsFurniturePerm,
	houseFriendsCasePerm,
	houseFriendsInventoryPerm,
	houseOriginalPrice
};
new House[MAX_HOUSES][HouseInfo];

enum JobInfo {
	jobID,
	jobName[128],
	jobPickup,
	Float:jobPositionX,
	Float:jobPositionY,
	Float:jobPositionZ
};
new Job[MAX_JOBS][JobInfo];

enum dialogs {
	DIALOG_REGISTER_1,
	DIALOG_REGISTER_2,
	DIALOG_REGISTER_3,
	DIALOG_REGISTER_4,
	DIALOG_REGISTER_5,
	DIALOG_LOGIN,

	DIALOG_PM_OFF,

	DIALOG_COMMANDS,

	DIALOG_HELP,
	DIALOG_INVENTORY,
	DIALOG_SETTINGS,

	DIALOG_COLOR_SETTING,
	DIALOG_COLORS,
	DIALOG_COLOR_CODE,

	DIALOG_BUY_HOUSE,
	DIALOG_PLAYER_HOUSES,
	DIALOG_PLAYER_HOUSES_SQL,
	DIALOG_SELL_SYSTEM,
	DIALOG_SELL_PLAYER,
	DIALOG_BUY_HOUSE_CONFIRM,
	DIALOG_PERMISSIONS,
	DIALOG_SET_PERMISSIONS,
	DIALOG_PLAYER_PERM,
	DIALOG_SET_PERM_PLAYER,
	DIALOG_FURNITURE,
	DIALOG_FIND_HOUSE,

	DIALOG_SKIN,

	DIALOG_LEAVE_JOB,
	DIALOG_GET_JOB,
	DIALOG_MARKET,
	DIALOG_RANKS,
	DIALOG_TRUCKER_SPAWN
};

forward MysqlConnection();
forward CheckAccountExist(playerid);
forward OnCheckAccountExist(playerid);
forward PlayerRegister(playerid);
forward PlayerLogin(playerid);
forward OnPlayerLogin(playerid);
forward AssignAffiliateId(playerid);
forward OnAssignAffiliateId(playerid, affiliateid);
forward CheckReferralId(playerid, affiliateid);
forward WaitDialog(playerid);
forward OnCheckPM(message[], playerid, targetid);
forward OnPMOffList(playerid);
forward RangeLocalSend(Float:range, playerid, text[], color);
forward LoadHouses();
forward OnLoadHouses();
forward UpdateHouse(houseid, removeold);
forward GetNearestHouse(playerid);
forward GetHouseSQL(houseid);
forward SaveHouse(houseid);
forward SaveAccount(playerid);
forward SafeGetPlayerMoney(playerid);
forward SafeGivePlayerMoney(playerid, amount);
forward SafeSetPlayerMoney(playerid, amount);
forward CheckMoney(playerid);
forward SetHouseDetails(houseid, interior);
forward PutPlayerInHouse(playerid, houseid);
forward CheckPlayerSQL(playerid, playersqlid);
forward OnHouseSQL(playerid, playersqlid);
forward OnPlayerPermissions(playerid, targetid, houseid);
forward DelayedKick(playerid);
forward LoadPrices();
forward OnLoadPrices();
forward LoadJobs();
forward OnLoadJobs();
forward UpdateJob(jobid, removeold);
forward ChangePrices();
forward GetNearestJob(playerid);
forward CreateTruckerIcons();

native WP_Hash(buffer[], len, const str[]);

// --------------------------------------
main() {
	print("Server has started...");
}

// -------------------Built - In Functions-------------------
public OnGameModeInit() {
	new hour, minute, second;

	MysqlConnection();

	SetGameModeText(GAMEMODE);
	ShowPlayerMarkers(2);
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	UsePlayerPedAnims();
	// ManualVehicleEngineAndLights();

	print("\n\n");
	print("\t#########################");
	print("\t##                     ##");
	print("\t##                     ##");
	print("\t##                     ##");
	print("\t##  Türkiye Topluluðu  ##");
	print("\t##                     ##");
	print("\t##                     ##");
	print("\t##                     ##");
	print("\t#########################");
	print("\n\n");

	
	
	gettime(hour, minute, second);

	SetTimer("ChangePrices", 1000, true);

	LoadHouses();
	LoadPrices();
	LoadJobs();
	CreateTruckerIcons();

	return 1;
}

public OnGameModeExit() {
	mysql_close(g_SQL);

	return 1;
}

public OnPlayerConnect(playerid) {
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	PlayAudioStreamForPlayer(playerid, "https://www.youtube.com/watch?v=CpS827SuJQE", x, y, z, 50.0);
	TogglePlayerSpectating(playerid, true);
	
	new rand = random(6);

	switch(rand) {
		case 0: { // LSPD
			SetPlayerCamera(playerid, 1506.3668, -1673.6359, 19.2422, 1515.6772, -1673.6359, 19.2422, false);
		}
		case 1: { // Santa Maria Beach
			SetPlayerCamera(playerid, 382.9240, -2060.0405, 12.7300, 382.9240, -2065.2107, 12.7300, false);
		}
		case 2: { // Verona Mall
			SetPlayerCamera(playerid, 1024.2682, -1618.0051, 27.9937, 1037.3212, -1618.0051, 27.9937, false);
		}
		case 3: { // Ganton
			SetPlayerCamera(playerid, 2413.7517, -1811.3407, 13.3828, 2413.7517, -1822.7454, 13.3828, false);
		}
		case 4: { // Area 51
			SetPlayerCamera(playerid, 213.9412, 1840.7385, 23.6406, 213.9412, 1851.6323, 23.6406, false);
		}
		case 5: { // 4 Dragons
			SetPlayerCamera(playerid, 2055.5291, 1008.3906, 20.8017, 2047.7490, 1008.3906, 20.8017, false);
		}
		case 6: { // Wang Cars
			SetPlayerCamera(playerid, -2029.5713, 284.8300, 44.8122, -2015.0964, 284.8300, 44.8122, false);
		}
	}
	
	SetTimerEx("WaitDialog", 500, false, "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	SaveAccount(playerid);
	KillTimer(moneytimer[playerid]);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	switch(dialogid)
	{
		case DIALOG_REGISTER_1:
		{
			if(response)
			{
				new flag;
				if(strlen(inputtext) < 5)
				{
					flag = 0;
					ShowPlayerDialog(playerid, DIALOG_REGISTER_1, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Account Registration", ""COL_WHITE"Your password must contain at least 5 characters.\n"COL_WHITE"Please enter a password below to register your account.", "Next", "Quit");
				}
				else {
					flag = 1;
				}

				if(flag == 1) {
					WP_Hash(Player[playerid][playerPassword], 129, inputtext);

					ShowPlayerDialog(playerid, DIALOG_REGISTER_2, DIALOG_STYLE_INPUT, "Account Registration", "Please enter your email below.", "Next", "Back");
				}
			}
			else
				return Kick(playerid);
		}

		case DIALOG_REGISTER_2:
		{
			if(response)
			{
				new query[128];

				mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `players` WHERE `pemail` = '%e'", inputtext);
				new Cache:result = mysql_query(g_SQL, query, true);

				if(cache_num_rows() > 0) {
					ShowPlayerDialog(playerid, DIALOG_REGISTER_2, DIALOG_STYLE_INPUT, "Account Registration", "Email Already Exists.\nPlease enter a valid email below.", "Next", "Back");
				}
				else {
					strmid(Player[playerid][playerEmail], inputtext, 0, strlen(inputtext), 255);
					ShowPlayerDialog(playerid, DIALOG_REGISTER_1, DIALOG_STYLE_PASSWORD, "Account Registration", "Please enter a password below.", "Next", "Back");
				}
				ShowPlayerDialog(playerid, DIALOG_REGISTER_3, DIALOG_STYLE_INPUT, ""COL_WHITE"Account Registration", ""COL_WHITE"Please enter the referral ID, if you have one. Leave empty if you don't have any.", "Next", "Back");

				cache_delete(result);
			}
			else {
				ShowPlayerDialog(playerid, DIALOG_REGISTER_1, DIALOG_STYLE_PASSWORD, "Account Registration", "Please enter a password below.", "Next", "Quit");				
			}
		}

		case DIALOG_REGISTER_3:
		{
			if(response) {
				if(strlen(inputtext) < 1) {
					PlayerRegister(playerid);
				}
				else {
					new query[1024];
					mysql_format(g_SQL, query, sizeof(query), "SELECT `pname` FROM `players` WHERE `paffiliateid` = '%d' LIMIT 1", strval(inputtext));
					mysql_tquery(g_SQL, query, "CheckReferralId", "ii", playerid, strval(inputtext));
				}
			}
			else {
				ShowPlayerDialog(playerid, DIALOG_REGISTER_2, DIALOG_STYLE_INPUT, "Account Registration", "Please enter your email below.", "Next", "Back");
			}
		}

		case DIALOG_REGISTER_4:
		{
			if(response) {
				PlayerRegister(playerid);
			}
			else {
				ShowPlayerDialog(playerid, DIALOG_REGISTER_4, DIALOG_STYLE_INPUT, ""COL_WHITE"Account Registration", ""COL_WHITE"Please enter the referral ID, if you have one. Leave empty if you don't have any.", "Next", "Back");
			}
		}

		case DIALOG_LOGIN:
		{
			if(response)
			{
				new hashpass[129], name[255];
				name = GetName(playerid);

				WP_Hash(hashpass, sizeof(hashpass), inputtext);

				if(strcmp(hashpass, Player[playerid][playerPassword]) == 0)
				{
					PlayerLogin(playerid);
				}
				else {
					new text[255];

					if(passchances[playerid] >= 3) {
						SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are kicked from the server. Reason: 3 invalid password attempts.");
						SetTimerEx("DelayedKick", 1000, false, "i", playerid);
					}
					else {
						passchances[playerid]++;
						format(text, sizeof(text), "Wrong password, you have %d chances left.\n"COL_RED"You have entered an incorrect password.\n"COL_WHITE"Type your password below to login.", 3-passchances[playerid]);
						ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Login", text, "Login", "Quit");
					}
				}
			}
			else
				return Kick(playerid);
		}

		case DIALOG_SETTINGS:
		{
			if(response) {
				if(listitem == 1) {
					currentsetting[playerid] = 1;

					if(Player[playerid][playerPmStatus] == 0) {
						Player[playerid][playerPmStatus] = 1;

						SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "PMs turned on.");
					}
					else {
						Player[playerid][playerPmStatus] = 0;
						SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "PMs turned off.");
					}

					SaveAccount(playerid);
				}
				else if(listitem == 2) {
					currentsetting[playerid] = 2;

					if(Player[playerid][playerMusic] == 0) {
						new Float:x, Float:y, Float:z;
						PlayAudioStreamForPlayer(playerid, "https://somafm.com/thetrip.pls", x, y, z, 50.0);
						Player[playerid][playerMusic] = 1;

						SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "Music turned on.");
					}
					else {
						Player[playerid][playerMusic] = 0;
						StopAudioStreamForPlayer(playerid);
						SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "Music turned off.");
					}

					SaveAccount(playerid);
				}
				else if(listitem == 3) {
					new vstatus[255], engine, alarm, doors, bonnet, boot, objective;

					currentsetting[playerid] = 3;					

					vstatus = GetVehicleStatus(playerid);

					if(vstatus[0] == -1)
						return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not driving a vehicle.");

					if(vstatus[2] == 1) {
						SetVehicleParamsEx(vstatus[0], engine, 0, alarm, doors, bonnet, boot, objective);
						SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "Lights turned off.");
					}
					else {
						SetVehicleParamsEx(vstatus[0], engine, 1, alarm, doors, bonnet, boot, objective);
						SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "Lights turned on.");
					}
				}
				else if(listitem == 4) {
					currentsetting[playerid] = 4;

					if(Player[playerid][playerHitSound] == 1) {
						Player[playerid][playerHitSound] = 0;
						SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "Hit sound turned off.");
					}
					else {
						Player[playerid][playerHitSound] = 1;
						SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "Hit sound turned on.");
					}

					SaveAccount(playerid);
				}
				else if(listitem == 5) {
					currentsetting[playerid] = 5;
					ShowPlayerDialog(playerid, DIALOG_COLOR_SETTING, DIALOG_STYLE_LIST, "PM Color", "Colors\nColor Code", "Okay", "Cancel");
				}
				else if(listitem == 6) {
					currentsetting[playerid] = 6;
					ShowPlayerDialog(playerid, DIALOG_COLOR_SETTING, DIALOG_STYLE_LIST, "Notification Color", "Colors\nColor Code", "Okay", "Cancel");
				}
				else if(listitem == 7) {
					currentsetting[playerid] = 7;
					ShowPlayerDialog(playerid, DIALOG_COLOR_SETTING, DIALOG_STYLE_LIST, "Squad Color", "Colors\nColor Code", "Okay", "Cancel");
				}
				else if(listitem == 8) {
					currentsetting[playerid] = 8;
					ShowPlayerDialog(playerid, DIALOG_COLOR_SETTING, DIALOG_STYLE_LIST, "Group Color", "Colors\nColor Code", "Okay", "Cancel");
				}
				else if(listitem == 9) {
					currentsetting[playerid] = 9;
					ShowPlayerDialog(playerid, DIALOG_COLOR_SETTING, DIALOG_STYLE_LIST, "Gang Color", "Colors\nColor Code", "Okay", "Cancel");
				}
				else if(listitem == 10) {
					currentsetting[playerid] = 10;
					ShowPlayerDialog(playerid, DIALOG_COLOR_SETTING, DIALOG_STYLE_LIST, "Local Chat Color", "Colors\nColor Code", "Okay", "Cancel");
				}
				else if(listitem == 11) {
					currentsetting[playerid] = 11;
					ShowPlayerDialog(playerid, DIALOG_COLOR_SETTING, DIALOG_STYLE_LIST, "Car Whisper Color", "Colors\nColor Code", "Okay", "Cancel");
				}
				else if(listitem == 12) {
					currentsetting[playerid] = 12;
					ShowPlayerDialog(playerid, DIALOG_COLOR_SETTING, DIALOG_STYLE_LIST, "Whisper Color", "Colors\nColor Code", "Okay", "Cancel");
				}
			}
		}

		case DIALOG_COLOR_SETTING:
		{
			if(response) {
				new caption[128];

				if(currentsetting[playerid] == 5)
					strmid(caption, "PM Color", 0, 128, 128);
				else if(currentsetting[playerid] == 6)
					strmid(caption, "Notification Color", 0, 128, 128);
				else if(currentsetting[playerid] == 7)
					strmid(caption, "Squad Color", 0, 128, 128);
				else if(currentsetting[playerid] == 8)
					strmid(caption, "Group Color", 0, 128, 128);
				else if(currentsetting[playerid] == 9)
					strmid(caption, "Gang Color", 0, 128, 128);
				else if(currentsetting[playerid] == 10)
					strmid(caption, "Local Chat Color", 0, 128, 128);
				else if(currentsetting[playerid] == 11)
					strmid(caption, "Car Whisper Color", 0, 128, 128);
				else if(currentsetting[playerid] == 12)
					strmid(caption, "Whisper Color", 0, 128, 128);

				if(listitem == 0)
					ShowPlayerDialog(playerid, DIALOG_COLORS, DIALOG_STYLE_LIST, caption, "Light Blue\nRed\nGrey\nYellow\nPink\nBlue\nWhite\nOrange\nLemon\nBlack\nLight Green\nPurple\nBrown\nCyan", "Select", "Cancel");
				else if(listitem == 1)
					ShowPlayerDialog(playerid, DIALOG_COLOR_CODE, DIALOG_STYLE_INPUT, caption, "Enter a color code. (For example, 0x33CCFFAA)", "Okay", "Cancel");
			}
		}

		case DIALOG_COLORS:
		{
			if(response) {
				new text[128];
				if(currentsetting[playerid] == 5) {
					if(listitem == 0)
						Player[playerid][playerPMColor] = 0x33CCFFAA;
					else if(listitem == 1)
						Player[playerid][playerPMColor] = 0xAA3333AA;
					else if(listitem == 2)
						Player[playerid][playerPMColor] = 0xAFAFAFAA;
					else if(listitem == 3)
						Player[playerid][playerPMColor] = 0xFFFF00AA;
					else if(listitem == 4)
						Player[playerid][playerPMColor] = 0xFF66FFAA;
					else if(listitem == 5)
						Player[playerid][playerPMColor] = 0x0000BBAA;
					else if(listitem == 6)
						Player[playerid][playerPMColor] = 0xFFFFFFAA;
					else if(listitem == 7)
						Player[playerid][playerPMColor] = 0xFF9900AA;
					else if(listitem == 8)
						Player[playerid][playerPMColor] = 0xDDDD2357;
					else if(listitem == 9)
						Player[playerid][playerPMColor] = 0x00000000;
					else if(listitem == 10)
						Player[playerid][playerPMColor] = 0x24FF0AB9;
					else if(listitem == 11)
						Player[playerid][playerPMColor] = 0x800080AA;
					else if(listitem == 12)
						Player[playerid][playerPMColor] = 0x993300AA;
					else if(listitem == 13)
						Player[playerid][playerPMColor] = 0x99FFFFAA;

					format(text, sizeof(text), "PM color set to %06x.", Player[playerid][playerPMColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 6) {
					if(listitem == 0)
						Player[playerid][playerNotificationColor] = 0x33CCFFAA;
					else if(listitem == 1)
						Player[playerid][playerNotificationColor] = 0xAA3333AA;
					else if(listitem == 2)
						Player[playerid][playerNotificationColor] = 0xAFAFAFAA;
					else if(listitem == 3)
						Player[playerid][playerNotificationColor] = 0xFFFF00AA;
					else if(listitem == 4)
						Player[playerid][playerNotificationColor] = 0xFF66FFAA;
					else if(listitem == 5)
						Player[playerid][playerNotificationColor] = 0x0000BBAA;
					else if(listitem == 6)
						Player[playerid][playerNotificationColor] = 0xFFFFFFAA;
					else if(listitem == 7)
						Player[playerid][playerNotificationColor] = 0xFF9900AA;
					else if(listitem == 8)
						Player[playerid][playerNotificationColor] = 0xDDDD2357;
					else if(listitem == 9)
						Player[playerid][playerNotificationColor] = 0x00000000;
					else if(listitem == 10)
						Player[playerid][playerNotificationColor] = 0x24FF0AB9;
					else if(listitem == 11)
						Player[playerid][playerNotificationColor] = 0x800080AA;
					else if(listitem == 12)
						Player[playerid][playerNotificationColor] = 0x993300AA;
					else if(listitem == 13)
						Player[playerid][playerNotificationColor] = 0x99FFFFAA;

					format(text, sizeof(text), "Notification color set to %06x.", Player[playerid][playerNotificationColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 7) {
					if(listitem == 0)
						Player[playerid][playerSquadColor] = 0x33CCFFAA;
					else if(listitem == 1)
						Player[playerid][playerSquadColor] = 0xAA3333AA;
					else if(listitem == 2)
						Player[playerid][playerSquadColor] = 0xAFAFAFAA;
					else if(listitem == 3)
						Player[playerid][playerSquadColor] = 0xFFFF00AA;
					else if(listitem == 4)
						Player[playerid][playerSquadColor] = 0xFF66FFAA;
					else if(listitem == 5)
						Player[playerid][playerSquadColor] = 0x0000BBAA;
					else if(listitem == 6)
						Player[playerid][playerSquadColor] = 0xFFFFFFAA;
					else if(listitem == 7)
						Player[playerid][playerSquadColor] = 0xFF9900AA;
					else if(listitem == 8)
						Player[playerid][playerSquadColor] = 0xDDDD2357;
					else if(listitem == 9)
						Player[playerid][playerSquadColor] = 0x00000000;
					else if(listitem == 10)
						Player[playerid][playerSquadColor] = 0x24FF0AB9;
					else if(listitem == 11)
						Player[playerid][playerSquadColor] = 0x800080AA;
					else if(listitem == 12)
						Player[playerid][playerSquadColor] = 0x993300AA;
					else if(listitem == 13)
						Player[playerid][playerSquadColor] = 0x99FFFFAA;

					format(text, sizeof(text), "Squad color set to %06x.", Player[playerid][playerSquadColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 8) {
					if(listitem == 0)
						Player[playerid][playerGroupColor] = 0x33CCFFAA;
					else if(listitem == 1)
						Player[playerid][playerGroupColor] = 0xAA3333AA;
					else if(listitem == 2)
						Player[playerid][playerGroupColor] = 0xAFAFAFAA;
					else if(listitem == 3)
						Player[playerid][playerGroupColor] = 0xFFFF00AA;
					else if(listitem == 4)
						Player[playerid][playerGroupColor] = 0xFF66FFAA;
					else if(listitem == 5)
						Player[playerid][playerGroupColor] = 0x0000BBAA;
					else if(listitem == 6)
						Player[playerid][playerGroupColor] = 0xFFFFFFAA;
					else if(listitem == 7)
						Player[playerid][playerGroupColor] = 0xFF9900AA;
					else if(listitem == 8)
						Player[playerid][playerGroupColor] = 0xDDDD2357;
					else if(listitem == 9)
						Player[playerid][playerGroupColor] = 0x00000000;
					else if(listitem == 10)
						Player[playerid][playerGroupColor] = 0x24FF0AB9;
					else if(listitem == 11)
						Player[playerid][playerGroupColor] = 0x800080AA;
					else if(listitem == 12)
						Player[playerid][playerGroupColor] = 0x993300AA;
					else if(listitem == 13)
						Player[playerid][playerGroupColor] = 0x99FFFFAA;

					format(text, sizeof(text), "Group color set to %06x.", Player[playerid][playerGroupColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 9) {
					if(listitem == 0)
						Player[playerid][playerGangColor] = 0x33CCFFAA;
					else if(listitem == 1)
						Player[playerid][playerGangColor] = 0xAA3333AA;
					else if(listitem == 2)
						Player[playerid][playerGangColor] = 0xAFAFAFAA;
					else if(listitem == 3)
						Player[playerid][playerGangColor] = 0xFFFF00AA;
					else if(listitem == 4)
						Player[playerid][playerGangColor] = 0xFF66FFAA;
					else if(listitem == 5)
						Player[playerid][playerGangColor] = 0x0000BBAA;
					else if(listitem == 6)
						Player[playerid][playerGangColor] = 0xFFFFFFAA;
					else if(listitem == 7)
						Player[playerid][playerGangColor] = 0xFF9900AA;
					else if(listitem == 8)
						Player[playerid][playerGangColor] = 0xDDDD2357;
					else if(listitem == 9)
						Player[playerid][playerGangColor] = 0x00000000;
					else if(listitem == 10)
						Player[playerid][playerGangColor] = 0x24FF0AB9;
					else if(listitem == 11)
						Player[playerid][playerGangColor] = 0x800080AA;
					else if(listitem == 12)
						Player[playerid][playerGangColor] = 0x993300AA;
					else if(listitem == 13)
						Player[playerid][playerGangColor] = 0x99FFFFAA;

					format(text, sizeof(text), "Gang color set to %06x.", Player[playerid][playerGangColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 10) {
					if(listitem == 0)
						Player[playerid][playerLocalColor] = 0x33CCFFAA;
					else if(listitem == 1)
						Player[playerid][playerLocalColor] = 0xAA3333AA;
					else if(listitem == 2)
						Player[playerid][playerLocalColor] = 0xAFAFAFAA;
					else if(listitem == 3)
						Player[playerid][playerLocalColor] = 0xFFFF00AA;
					else if(listitem == 4)
						Player[playerid][playerLocalColor] = 0xFF66FFAA;
					else if(listitem == 5)
						Player[playerid][playerLocalColor] = 0x0000BBAA;
					else if(listitem == 6)
						Player[playerid][playerLocalColor] = 0xFFFFFFAA;
					else if(listitem == 7)
						Player[playerid][playerLocalColor] = 0xFF9900AA;
					else if(listitem == 8)
						Player[playerid][playerLocalColor] = 0xDDDD2357;
					else if(listitem == 9)
						Player[playerid][playerLocalColor] = 0x00000000;
					else if(listitem == 10)
						Player[playerid][playerLocalColor] = 0x24FF0AB9;
					else if(listitem == 11)
						Player[playerid][playerLocalColor] = 0x800080AA;
					else if(listitem == 12)
						Player[playerid][playerLocalColor] = 0x993300AA;
					else if(listitem == 13)
						Player[playerid][playerLocalColor] = 0x99FFFFAA;

					format(text, sizeof(text), "Local color set to %06x.", Player[playerid][playerLocalColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 11) {
					if(listitem == 0)
						Player[playerid][playerCarWhisperColor] = 0x33CCFFAA;
					else if(listitem == 1)
						Player[playerid][playerCarWhisperColor] = 0xAA3333AA;
					else if(listitem == 2)
						Player[playerid][playerCarWhisperColor] = 0xAFAFAFAA;
					else if(listitem == 3)
						Player[playerid][playerCarWhisperColor] = 0xFFFF00AA;
					else if(listitem == 4)
						Player[playerid][playerCarWhisperColor] = 0xFF66FFAA;
					else if(listitem == 5)
						Player[playerid][playerCarWhisperColor] = 0x0000BBAA;
					else if(listitem == 6)
						Player[playerid][playerCarWhisperColor] = 0xFFFFFFAA;
					else if(listitem == 7)
						Player[playerid][playerCarWhisperColor] = 0xFF9900AA;
					else if(listitem == 8)
						Player[playerid][playerCarWhisperColor] = 0xDDDD2357;
					else if(listitem == 9)
						Player[playerid][playerCarWhisperColor] = 0x00000000;
					else if(listitem == 10)
						Player[playerid][playerCarWhisperColor] = 0x24FF0AB9;
					else if(listitem == 11)
						Player[playerid][playerCarWhisperColor] = 0x800080AA;
					else if(listitem == 12)
						Player[playerid][playerCarWhisperColor] = 0x993300AA;
					else if(listitem == 13)
						Player[playerid][playerCarWhisperColor] = 0x99FFFFAA;

					format(text, sizeof(text), "Car Whisper color set to %06x.", Player[playerid][playerCarWhisperColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 12) {
					if(listitem == 0)
						Player[playerid][playerWhisperColor] = 0x33CCFFAA;
					else if(listitem == 1)
						Player[playerid][playerWhisperColor] = 0xAA3333AA;
					else if(listitem == 2)
						Player[playerid][playerWhisperColor] = 0xAFAFAFAA;
					else if(listitem == 3)
						Player[playerid][playerWhisperColor] = 0xFFFF00AA;
					else if(listitem == 4)
						Player[playerid][playerWhisperColor] = 0xFF66FFAA;
					else if(listitem == 5)
						Player[playerid][playerWhisperColor] = 0x0000BBAA;
					else if(listitem == 6)
						Player[playerid][playerWhisperColor] = 0xFFFFFFAA;
					else if(listitem == 7)
						Player[playerid][playerWhisperColor] = 0xFF9900AA;
					else if(listitem == 8)
						Player[playerid][playerWhisperColor] = 0xDDDD2357;
					else if(listitem == 9)
						Player[playerid][playerWhisperColor] = 0x00000000;
					else if(listitem == 10)
						Player[playerid][playerWhisperColor] = 0x24FF0AB9;
					else if(listitem == 11)
						Player[playerid][playerWhisperColor] = 0x800080AA;
					else if(listitem == 12)
						Player[playerid][playerWhisperColor] = 0x993300AA;
					else if(listitem == 13)
						Player[playerid][playerWhisperColor] = 0x99FFFFAA;

					format(text, sizeof(text), "Whisper color set to %06x.", Player[playerid][playerWhisperColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}

				SaveAccount(playerid);
			}
		}

		case DIALOG_COLOR_CODE:
		{
			if(response) {
				new text[128];
				if(currentsetting[playerid] == 5) {
					Player[playerid][playerPMColor] = HexToInt(inputtext);
				
					format(text, sizeof(text), "PM color set to %06x.", Player[playerid][playerPMColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);					
				}
				else if(currentsetting[playerid] == 6) {
					Player[playerid][playerNotificationColor] = HexToInt(inputtext);
				
					format(text, sizeof(text), "Notification color set to %06x.", Player[playerid][playerNotificationColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 7) {
					Player[playerid][playerSquadColor] = HexToInt(inputtext);
				
					format(text, sizeof(text), "Squad color set to %06x.", Player[playerid][playerSquadColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 8) {
					Player[playerid][playerGroupColor] = HexToInt(inputtext);
				
					format(text, sizeof(text), "Group color set to %06x.", Player[playerid][playerGroupColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 9) {
					Player[playerid][playerGangColor] = HexToInt(inputtext);
				
					format(text, sizeof(text), "Gang color set to %06x.", Player[playerid][playerGangColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 10) {
					Player[playerid][playerLocalColor] = HexToInt(inputtext);
				
					format(text, sizeof(text), "Local color set to %06x.", Player[playerid][playerLocalColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 11) {
					Player[playerid][playerCarWhisperColor] = HexToInt(inputtext);
				
					format(text, sizeof(text), "Car Whisper color set to %06x.", Player[playerid][playerCarWhisperColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}
				else if(currentsetting[playerid] == 12) {
					Player[playerid][playerWhisperColor] = HexToInt(inputtext);
				
					format(text, sizeof(text), "Whisper color set to %06x.", Player[playerid][playerWhisperColor] >>> 8);
					SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
				}

				SaveAccount(playerid);
			}
		}
		// @TODO: Pending (Allow buying from other players)
		case DIALOG_BUY_HOUSE:
		{
			new houseid = currenthousebuyid[playerid];
			if(response) {
				
				new cash = SafeGetPlayerMoney(playerid);

				SafeSetPlayerMoney(playerid, cash - House[houseid][housePrice]);
				House[houseid][houseLastPrice] = House[houseid][housePrice];

				House[houseid][housePrice] = 0;

				House[houseid][houseOwner] = Player[playerid][playerID];

				if(Player[playerid][playerHouse1] == -1)
					Player[playerid][playerHouse1] = House[houseid][houseID];
				else if(Player[playerid][playerHouse2] == -1)
					Player[playerid][playerHouse2] = House[houseid][houseID];
				else if(Player[playerid][playerHouse3] == -1)
					Player[playerid][playerHouse3] = House[houseid][houseID];
				else if(Player[playerid][playerHouse4] == -1)
					Player[playerid][playerHouse4] = House[houseid][houseID];

				Player[playerid][playerHouses]++;

				UpdateHouse(houseid, 1);
				SaveHouse(houseid);

				SaveAccount(playerid);

				SendClientMessage(playerid, COLOR_YELLOW, "Congratulations, you bought this house.");
				GameTextForPlayer(playerid, "Welcome", 1500, 7);

				currenthousebuyid[playerid] = -1;
			}
			currenthouseid[playerid] = houseid;
			PutPlayerInHouse(playerid, houseid);
		}

		case DIALOG_SELL_SYSTEM:
		{
			if(response) {
				new text[128];
				new houseid = currenthousesellid[playerid];
				new cash = SafeGetPlayerMoney(playerid);

				SafeSetPlayerMoney(playerid, cash - (House[houseid][houseLastPrice]/2));

				format(text, sizeof(text), "Congratulations, you sold this house for $%d.", House[houseid][houseLastPrice]/2);
				SendClientMessage(playerid, COLOR_YELLOW, text);

				House[houseid][houseLastPrice] = House[houseid][houseLastPrice]/2;
				House[houseid][housePrice] = 0;
				House[houseid][houseOwner] = -1;

				if(Player[playerid][playerHouse1] == House[houseid][houseID])
					Player[playerid][playerHouse1] = -1;
				else if(Player[playerid][playerHouse2] == House[houseid][houseID])
					Player[playerid][playerHouse2] = -1;
				else if(Player[playerid][playerHouse3] == House[houseid][houseID])
					Player[playerid][playerHouse3] = -1;
				else if(Player[playerid][playerHouse4] == House[houseid][houseID])
					Player[playerid][playerHouse4] = -1;

				Player[playerid][playerHouses]--;

				SaveAccount(playerid);

				UpdateHouse(houseid, 1);
				SaveHouse(houseid);

				currenthousesellid[playerid] = -1;
			}
		}

		case DIALOG_SELL_PLAYER:
		{
			if(response) {
				new text[128], targetid = currenthouseselltargetid[playerid];
				currenthouseselltargetid[targetid] = playerid;
				format(text, sizeof(text), "%s has offered you to buy his house for $%d. Do you wish to buy?", GetName(playerid), currenthousesellprice[playerid]);
				ShowPlayerDialog(targetid, DIALOG_BUY_HOUSE_CONFIRM, DIALOG_STYLE_MSGBOX, "Buy House", text, "Yes", "No");
			}
		}

		case DIALOG_BUY_HOUSE_CONFIRM:
		{
			new targetid = currenthouseselltargetid[playerid];
			if(response) {
				new text[128], text2[128];
				new houseid = Player[playerid][playerID];
				new pcash = SafeGetPlayerMoney(playerid);
				new tcash = SafeGetPlayerMoney(targetid);
				new price = currenthousesellprice[targetid];

				House[houseid][houseLastPrice] = currenthousesellprice[targetid];
				House[houseid][housePrice] = 0;
				House[houseid][houseOwner] = Player[playerid][playerID];

				if(Player[targetid][playerHouse1] == House[houseid][houseID])
					Player[targetid][playerHouse1] = -1;
				else if(Player[targetid][playerHouse2] == House[houseid][houseID])
					Player[targetid][playerHouse2] = -1;
				else if(Player[targetid][playerHouse3] == House[houseid][houseID])
					Player[targetid][playerHouse3] = -1;
				else if(Player[targetid][playerHouse4] == House[houseid][houseID])
					Player[targetid][playerHouse4] = -1;

				if(Player[playerid][playerHouse1] == -1)
					Player[playerid][playerHouse1] = House[houseid][houseID];
				else if(Player[playerid][playerHouse2] == -1)
					Player[playerid][playerHouse2] = House[houseid][houseID];
				else if(Player[playerid][playerHouse3] == -1)
					Player[playerid][playerHouse3] = House[houseid][houseID];
				else if(Player[playerid][playerHouse4] == -1)
					Player[playerid][playerHouse4] = House[houseid][houseID];

				Player[playerid][playerHouses]++;
				Player[targetid][playerHouses]--;

				currenthousesellid[playerid] = -1;
				currenthousesellid[targetid] = -1;

				currenthousesellprice[playerid] = -1;
				currenthousesellprice[targetid] = -1;

				currenthouseselltargetid[playerid] = -1;
				currenthouseselltargetid[targetid] = -1;

				SafeSetPlayerMoney(playerid, tcash - price);
				SafeSetPlayerMoney(targetid, pcash + price);

				SaveAccount(playerid);
				SaveAccount(targetid);

				UpdateHouse(houseid, 1);
				SaveHouse(houseid);

				format(text2, sizeof(text2), "Congratulations, you bought this house from %s for $%d.", Player[targetid][playerName], price);
				SendClientMessage(playerid, COLOR_YELLOW, text);

				format(text, sizeof(text), "Congratulations, you sold this house to %s for $%d.", GetName(playerid), price);
				SendClientMessage(targetid, COLOR_YELLOW, text);
			}
			else {
				new text[128];

				format(text, sizeof(text), "%s has rejected your offer to buy your house.", GetName(targetid));
				SendClientMessage(targetid, COLOR_LIGHTNEUTRALBLUE, text);
			}
		}

		case DIALOG_PERMISSIONS:
		{
			if(response) {
				new text[255], caption[128];
				new houseid = currenthousepermid[playerid];

				if(listitem == 0) {
					SetPVarInt(playerid, "cap", 1);
					strmid(caption, "Gang Permissions", 0, 128, 128);
					format(text, sizeof(text), "Name\tPermission\nEnter\t%d\nFurniture\t%d\nCase\t%d\nInventory\t%d", House[houseid][houseGangEnterPerm], House[houseid][houseGangFurniturePerm], House[houseid][houseGangCasePerm], House[houseid][houseGangInventoryPerm]);
				}
				else if(listitem == 1) {
					SetPVarInt(playerid, "cap", 2);
					strmid(caption, "Squad Permissions", 0, 128, 128);
					format(text, sizeof(text), "Name\tPermission\nEnter\t%d\nFurniture\t%d\nCase\t%d\nInventory\t%d", House[houseid][houseSquadEnterPerm], House[houseid][houseSquadFurniturePerm], House[houseid][houseSquadCasePerm], House[houseid][houseSquadInventoryPerm]);
				}
				else if(listitem == 2) {
					SetPVarInt(playerid, "cap", 3);
					strmid(caption, "Group Permissions", 0, 128, 128);
					format(text, sizeof(text), "Name\tPermission\nEnter\t%d\nFurniture\t%d\nCase\t%d\nInventory\t%d", House[houseid][houseGroupEnterPerm], House[houseid][houseGroupFurniturePerm], House[houseid][houseGroupCasePerm], House[houseid][houseGroupInventoryPerm]);
				}
				else if(listitem == 3) {
					SetPVarInt(playerid, "cap", 4);
					strmid(caption, "Friends Permissions", 0, 128, 128);
					format(text, sizeof(text), "Name\tPermission\nEnter\t%d\nFurniture\t%d\nCase\t%d\nInventory\t%d", House[houseid][houseFriendsEnterPerm], House[houseid][houseFriendsFurniturePerm], House[houseid][houseFriendsCasePerm], House[houseid][houseFriendsInventoryPerm]);
				}
				else if(listitem > 4) {
					new pid, hid, query[255], enter, furn, caseh, inv;
					SetPVarInt(playerid, "cap", 5);
					strmid(caption, "Player Permissions", 0, 128, 128);

					for(new i = 0; i < MAX_PLAYERS; i++) {
						if(strcmp(Player[i][playerName], inputtext) == 0) {
							pid = i;
							break;
						}
					}

					SetPVarInt(playerid, "permpid", pid);

					hid = currenthouseid[playerid];

					mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `permissions` WHERE `pid` = '%d' AND `hid` = '%d'", Player[pid][playerID], House[hid][houseID]);
					new Cache:result = mysql_query(g_SQL, query, true);

					cache_get_value_name_int(0, "enterperm", enter);
					cache_get_value_name_int(0, "furnperm", furn);
					cache_get_value_name_int(0, "caseperm", caseh);
					cache_get_value_name_int(0, "invperm", inv);

					format(text, sizeof(text), "Name\tPermission\nEnter\t%d\nFurniture\t%d\nCase\t%d\nInventory\t%d", enter, furn, caseh, inv);

					SetPVarInt(playerid, "dialogpenter", enter);
					SetPVarInt(playerid, "dialogpfurn", furn);
					SetPVarInt(playerid, "dialogpcase", caseh);
					SetPVarInt(playerid, "dialogpinv", inv);

					cache_delete(result);
				}

				if(listitem != 4) {
					strreplace(text, "-1", "{AA3333}OFF");
					strreplace(text, "1", "{33AA33}ON");
					strreplace(text, "0", "{AA3333}OFF");

					ShowPlayerDialog(playerid, DIALOG_SET_PERMISSIONS, DIALOG_STYLE_TABLIST_HEADERS, caption, text, "Change", "Cancel");
				}
				else if(listitem == 4) {
					SetPVarInt(playerid, "cap", 4);
					strmid(caption, "Add a Player", 0, 128, 128);
					ShowPlayerDialog(playerid, DIALOG_PLAYER_PERM, DIALOG_STYLE_INPUT, caption, "Enter Player Name/ID", "Set", "Cancel");
				}
			}
		}

		case DIALOG_SET_PERMISSIONS:
		{
			if(response) {
				new houseid = currenthousepermid[playerid];
				
				new val, caption[128];
				val = GetPVarInt(playerid, "cap");

				if(val == 1) {
					strmid(caption, "Gang Permissions", 0, 128, 128);
					if(listitem == 0) {
						if(House[houseid][houseGangEnterPerm] == 0)
							House[houseid][houseGangEnterPerm] = 1;
						else
							House[houseid][houseGangEnterPerm] = 0;
					}
					else if(listitem == 1) {
						if(House[houseid][houseGangFurniturePerm] == 0)
							House[houseid][houseGangFurniturePerm] = 1;
						else
							House[houseid][houseGangFurniturePerm] = 0;
					}
					else if(listitem == 2) {
						if(House[houseid][houseGangCasePerm] == 0)
							House[houseid][houseGangCasePerm] = 1;
						else
							House[houseid][houseGangCasePerm] = 0;
					}
					else if(listitem == 3) {
						if(House[houseid][houseGangInventoryPerm] == 0)
							House[houseid][houseGangInventoryPerm] = 1;
						else
							House[houseid][houseGangInventoryPerm] = 0;
					}
				}
				else if(val == 2) {
					strmid(caption, "Squad Permissions", 0, 128, 128);
					if(listitem == 0) {
						if(House[houseid][houseSquadEnterPerm] == 0)
							House[houseid][houseSquadEnterPerm] = 1;
						else
							House[houseid][houseSquadEnterPerm] = 0;
					}
					else if(listitem == 1) {
						if(House[houseid][houseSquadFurniturePerm] == 0)
							House[houseid][houseSquadFurniturePerm] = 1;
						else
							House[houseid][houseSquadFurniturePerm] = 0;
					}
					else if(listitem == 2) {
						if(House[houseid][houseSquadCasePerm] == 0)
							House[houseid][houseSquadCasePerm] = 1;
						else
							House[houseid][houseSquadCasePerm] = 0;
					}
					else if(listitem == 3) {
						if(House[houseid][houseSquadInventoryPerm] == 0)
							House[houseid][houseSquadInventoryPerm] = 1;
						else
							House[houseid][houseSquadInventoryPerm] = 0;
					}
				}
				else if(val == 3) {
					strmid(caption, "Group Permissions", 0, 128, 128);
					if(listitem == 0) {
						if(House[houseid][houseGroupEnterPerm] == 0)
							House[houseid][houseGroupEnterPerm] = 1;
						else
							House[houseid][houseGroupEnterPerm] = 0;
					}
					else if(listitem == 1) {
						if(House[houseid][houseGroupFurniturePerm] == 0)
							House[houseid][houseGroupFurniturePerm] = 1;
						else
							House[houseid][houseGroupFurniturePerm] = 0;
					}
					else if(listitem == 2) {
						if(House[houseid][houseGroupCasePerm] == 0)
							House[houseid][houseGroupCasePerm] = 1;
						else
							House[houseid][houseGroupCasePerm] = 0;
					}
					else if(listitem == 3) {
						if(House[houseid][houseGroupInventoryPerm] == 0)
							House[houseid][houseGroupInventoryPerm] = 1;
						else
							House[houseid][houseGroupInventoryPerm] = 0;
					}
				}
				else if(val == 4) {
					strmid(caption, "Friends Permissions", 0, 128, 128);
					if(listitem == 0) {
						if(House[houseid][houseFriendsEnterPerm] == 0)
							House[houseid][houseFriendsEnterPerm] = 1;
						else
							House[houseid][houseFriendsEnterPerm] = 0;
					}
					else if(listitem == 1) {
						if(House[houseid][houseFriendsFurniturePerm] == 0)
							House[houseid][houseFriendsFurniturePerm] = 1;
						else
							House[houseid][houseFriendsFurniturePerm] = 0;
					}
					else if(listitem == 2) {
						if(House[houseid][houseFriendsCasePerm] == 0)
							House[houseid][houseFriendsCasePerm] = 1;
						else
							House[houseid][houseFriendsCasePerm] = 0;
					}
					else if(listitem == 3) {
						if(House[houseid][houseFriendsInventoryPerm] == 0)
							House[houseid][houseFriendsInventoryPerm] = 1;
						else
							House[houseid][houseFriendsInventoryPerm] = 0;
					}
				}

				if(val != 5) {
					SaveHouse(houseid);
					cmd_permissions(playerid);
				}
				else if(val == 5) {
					strmid(caption, "Player Permissions", 0, 128, 128);
					new enter, furn, caseh, inv, text[128], query[255], pid, hid;

					enter = GetPVarInt(playerid, "dialogpenter");
					furn = GetPVarInt(playerid, "dialogpfurn");
					caseh = GetPVarInt(playerid, "dialogpcase");
					inv = GetPVarInt(playerid, "dialogpinv");

					pid = GetPVarInt(playerid, "permpid");
					hid = currenthouseid[playerid];

					if(listitem == 0) {
						if(enter == 0) 
							enter = 1;
						else
							enter = 0;
					}
					else if(listitem == 1) {
						if(furn == 0)
							furn = 1;
						else
							furn = 0;
					}
					else if(listitem == 2) {
						if(caseh == 0)
							caseh = 1;
						else
							caseh = 0;
					}
					else if(listitem == 3) {
						if(inv == 0)
							inv = 1;
						else
							inv = 0;
					}

					SetPVarInt(playerid, "dialogpenter", enter);
					SetPVarInt(playerid, "dialogpfurn", furn);
					SetPVarInt(playerid, "dialogpcase", caseh);
					SetPVarInt(playerid, "dialogpinv", inv);

					SetPVarInt(playerid, "cap", 5);
					format(text, sizeof(text), "Name\tPermission\nEnter\t%d\nFurniture\t%d\nCase\t%d\nInventory\t%d", enter, furn, caseh, inv);

					strreplace(text, "-1", "{AA3333}OFF");
					strreplace(text, "1", "{33AA33}ON");
					strreplace(text, "0", "{AA3333}OFF");

					mysql_format(g_SQL, query, sizeof(query), "UPDATE `permissions` SET `enterperm` = '%d', `furnperm` = '%d', `caseperm` = '%d', `invperm` = '%d' WHERE `pid` = '%d' AND `hid` = '%d'", enter, furn, caseh, inv, Player[pid][playerID], House[hid][houseID]);
					mysql_tquery(g_SQL, query);

					ShowPlayerDialog(playerid, DIALOG_SET_PERMISSIONS, DIALOG_STYLE_TABLIST_HEADERS, caption, text, "Change", "Cancel");
				}
			}
		}

		case DIALOG_PLAYER_PERM:
		{
			if(response) {
				new targetid;
				new houseid = currenthousepermid[playerid];

				if(sscanf(inputtext, "u", targetid))
					return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid Player!");
				
				if(IsPlayerConnected(targetid)) {
					new query[255];

					mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `permissions` WHERE `hid` = '%d' AND `pid` = '%d'", House[houseid][houseID], Player[targetid][playerID]);
					mysql_tquery(g_SQL, query, "OnPlayerPermissions", "iii", playerid, targetid, houseid);
				}
				else
					return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
			}
		}

		case DIALOG_SET_PERM_PLAYER:
		{
			if(response) {
				new enterperm, furnitureperm, casehperm, invperm, query[255], targetid, houseid;

				enterperm = GetPVarInt(playerid, "enter");
				furnitureperm = GetPVarInt(playerid, "furniture");
				casehperm = GetPVarInt(playerid, "caseh");
				invperm = GetPVarInt(playerid, "inv");
				targetid = GetPVarInt(playerid, "playerperm");
				houseid = GetPVarInt(playerid, "hidperm");

				if(listitem == 0) {
					if(enterperm == 1)
						enterperm = 0;
					else
						enterperm = 1;
				}
				else if(listitem == 1) {
					if(furnitureperm == 1)
						furnitureperm = 0;
					else
						furnitureperm = 1;
				}
				else if(listitem == 2) {
					if(casehperm == 1)
						casehperm = 0;
					else
						casehperm = 1;
				}
				else if(listitem == 3) {
					if(invperm == 1)
						invperm = 0;
					else
						invperm = 1;
				}

				mysql_format(g_SQL, query, sizeof(query), "UPDATE `permissions` SET `enterperm` = '%d', `furnperm` = '%d', `caseperm` = '%d', `invperm` = '%d' WHERE `pid` = '%d' AND `hid` = '%d'", enterperm, furnitureperm, casehperm, invperm, Player[targetid][playerID], House[houseid][houseID]);
				mysql_tquery(g_SQL, query);
			}
		}

		case DIALOG_FURNITURE:
		{
			// @TODO Pending
		}

		case DIALOG_FIND_HOUSE:
		{
			if(response) {
				new houseid;
				
				strreplace(inputtext, "House ", "", false, 0, -1, strlen(inputtext));

				houseid = strval(inputtext);

				SetPlayerCheckpoint(playerid, House[houseid][housePositionX], House[houseid][housePositionY], House[houseid][housePositionZ], 5.0);
			}
		}

		case DIALOG_SKIN:
		{
			if(response) {
				new skinid = strval(inputtext);
				SetPlayerSkin(playerid, skinid);
				Player[playerid][playerSkin] = skinid;

				SaveAccount(playerid);
				
				ShowPlayerDialog(playerid, DIALOG_REGISTER_5, DIALOG_STYLE_MSGBOX, ""COL_WHITE"Account Registration", ""COL_WHITE"Thank you for registering to the server. We hope you have an amazing experience.", "Okay", "");


			}
		}

		case DIALOG_LEAVE_JOB:
		{
			if(response) {
				new jobid = currentjobid;
				new text[128];

				Player[playerid][playerJob] = 0;

				SaveAccount(playerid);

				format(text, sizeof(text), "You left the %s job.", Job[jobid][jobName]);
				SendClientMessage(playerid, COLOR_YELLOW, text);

				currentjobid = -1;
			}
		}

		case DIALOG_GET_JOB:
		{
			if(response) {
				new jobid = currentjobid;
				new text[128];

				Player[playerid][playerJob] = jobid;

				SaveAccount(playerid);

				format(text, sizeof(text), "You are now a %s.", Job[jobid][jobName]);
				SendClientMessage(playerid, COLOR_YELLOW, text);

				currentjobid = -1;
			}
		}

		case DIALOG_TRUCKER_SPAWN:
		{
			if(response) {
				SetPlayerCheckpoint(playerid, 2764.5903, -2433.5596, 13.4663, 5.0);

				if(listitem == 0)
					truckervehid[playerid] = CreateVehicle(478, 2764.5903, -2433.5596, 13.4663, 0, random(255), random(255), -1); // Picador
				else if(listitem == 1)
					truckervehid[playerid] = CreateVehicle(422, 2764.5903, -2433.5596, 13.4663, 0, random(255), random(255), -1); // Bobcat
				else if(listitem == 2)
					truckervehid[playerid] = CreateVehicle(554, 2764.5903, -2433.5596, 13.4663, 0, random(255), random(255), -1); // Yosemite
				else if(listitem == 3)
					truckervehid[playerid] = CreateVehicle(482, 2764.5903, -2433.5596, 13.4663, 0, random(255), random(255), -1); // Burrito
				else if(listitem == 4)
					truckervehid[playerid] = CreateVehicle(414, 2764.5903, -2433.5596, 13.4663, 0, random(255), random(255), -1); // Mule

				truckerspawned[playerid] = 1;

				SetPlayerCheckpoint(playerid, 2748.6235, -2452.5361, 13.8623, 5.0);
				SendClientMessage(playerid, COLOR_YELLOW, "Follow the checkpoint and type /buybox to buy the products.");
			}
		}

		case DIALOG_MARKET:
		{
			if(response) {
				if(isbuyingprod[playerid] == 1) {

					if(truckerboughtprod[playerid] == 1)
						return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You need to deliver the current product before buying a new one.");

					ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 1, 1, 1, 1, 1);
					ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 1, 1, 1, 1, 1);

					RemovePlayerAttachedObject(playerid, 0);
					
					if(listitem == 0) {
						truckercurobj[playerid] = 19636;
						SetPlayerAttachedObject(playerid, 0, 19636, 13, 0.5, -0.01, -0.2, 75, 0, 0, 1, 1, 1);
					}
					else if(listitem == 1) {
						truckercurobj[playerid] = 1271;
						SetPlayerAttachedObject(playerid, 0, 1271, 13, 0.5, -0.3, -0.2, 75, 0, 0, 1, 1, 1);
					}
					else if(listitem == 2) {
						truckercurobj[playerid] = 2969;
						SetPlayerAttachedObject(playerid, 0, 2969, 13, 0.5, -0.01, -0.2, 75, 0, 0, 1, 1, 1);
					}
					else if(listitem == 3) {
						truckercurobj[playerid] = 2694;
						SetPlayerAttachedObject(playerid, 0, 2694, 13, 0.5, -0.01, -0.2, 75, 0, 0, 1, 1, 1);
					}
					else if(listitem == 4) {
						truckercurobj[playerid] = 3014;
						SetPlayerAttachedObject(playerid, 0, 3014, 13, 0.5, -0.01, -0.2, 75, 0, 0, 1, 1, 1);
					}
					else if(listitem == 5) {
						truckercurobj[playerid] = 2358;
						SetPlayerAttachedObject(playerid, 0, 2358, 13, 0.5, -0.01, -0.2, 75, 0, 0, 1, 1, 1);
					}

					truckerboughtprod[playerid] = 1;
				}
			}
		}
	}
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart) {
	new Float:x, Float:y, Float:z;

	if(Player[playerid][playerHitSound] == 1)
		PlayerPlaySound(playerid, 17802, x, y, z);

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(newkeys & KEY_YES) {
		new houseid, chid;

		chid = GetNearestHouse(playerid);

		if(chid != -1 && House[chid][housePrice] > 0 && House[houseid][houseOwner] != Player[playerid][playerID]) {
			new text[255];

			houseid = chid;

			if(Player[playerid][playerType] == 0) {
				if(Player[playerid][playerHouses] == 1) {
					PutPlayerInHouse(playerid, houseid);
					return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You cannot buy more houses. Please donate to the server for more slots.");
				}
			}
			else if(Player[playerid][playerType] == 1) {
				if(Player[playerid][playerHouses] == 3) {
					PutPlayerInHouse(playerid, houseid);
					return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You cannot buy more houses.");
				}
			}

			if(SafeGetPlayerMoney(playerid) < House[houseid][housePrice]) {
				PutPlayerInHouse(playerid, houseid);
				return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You do not have sufficient cash to buy this house.");
			}

			currenthousebuyid[playerid] = houseid;

			format(text, sizeof(text), "{FFFFFF}This house is for sale for {33AA33}$%d{FFFFFF}.\nAre you sure you want to buy this house?", House[houseid][housePrice]);
			ShowPlayerDialog(playerid, DIALOG_BUY_HOUSE, DIALOG_STYLE_MSGBOX, "Buy House", text, "Buy", "Cancel");

			return 1;
		}

		if(currenthouseid[playerid] != -1) {
			houseid = currenthouseid[playerid];
			if(IsPlayerInRangeOfPoint(playerid, 1.5, House[houseid][houseExitX], House[houseid][houseExitY], House[houseid][houseExitZ])) {
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
				SetPlayerPos(playerid, House[houseid][housePositionX], House[houseid][housePositionY], House[houseid][housePositionZ]);
				currenthouseid[playerid] = -1;
			}
		}
		else {
			houseid = chid;

			if(houseid != -1)
				PutPlayerInHouse(playerid, houseid);
		}

		if(houseid == -1 && chid == -1) {
			new nearestjobid = GetNearestJob(playerid);
			new text[128];

			if(nearestjobid != -1) {
				currentjobid = nearestjobid;
			 	if(Player[playerid][playerJob] == nearestjobid) {
					format(text, sizeof(text), "Do you want to leave the %s job?", Job[nearestjobid][jobName]);
					ShowPlayerDialog(playerid, DIALOG_LEAVE_JOB, DIALOG_STYLE_MSGBOX, "Leave Job", text, "Yes", "No");
				}
				else if(Player[playerid][playerJob] != 0) {
					if(Player[playerid][playerType] == 0)
						return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You need to quit your existing job before getting a new one.");
					else {
						format(text, sizeof(text), "Do you want to leave your existing job and get the %s job?", Job[nearestjobid][jobName]);
						ShowPlayerDialog(playerid, DIALOG_GET_JOB, DIALOG_STYLE_MSGBOX, "Get Job", text, "Yes", "No");
					}
				}
				else {
					format(text, sizeof(text), "Do you want to get the %s job?", Job[nearestjobid][jobName]);
					ShowPlayerDialog(playerid, DIALOG_GET_JOB, DIALOG_STYLE_MSGBOX, "Get Job", text, "Yes", "No");
				}
			}
		}
	}
	return 1;
}

public OnPlayerDeath(playerid) {
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);

	currenthouseid[playerid] = -1;
	return 1;
}

public OnPlayerSpawn(playerid) {
	new Float:x, Float:y, Float:z;

	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Player[playerid][playerCash]);

	regflag[playerid] = 0;

	GetPlayerPos(playerid, x, y, z);

	if(Player[playerid][playerMusic] == 1)
		PlayAudioStreamForPlayer(playerid, "https://somafm.com/thetrip.pls", x, y, z, 50.0);

	moneytimer[playerid] = SetTimerEx("CheckMoney", 3000, 1, "i", playerid);

	SetPlayerSkin(playerid, Player[playerid][playerSkin]);

	return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
	DisablePlayerCheckpoint(playerid);
	return 1;
}

public OnPlayerRequestSpawn(playerid) {
	if(regflag[playerid] == 0) { // Login
		new lastspawn = Player[playerid][playerLastSpawn];

		switch(lastspawn) {
			case 1: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 1919.1262, -1759.9194, 13.5469, 0, -1, -1, -1, -1, -1, -1);
			}
			case 2: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 1508.8857, -2287.2163, 13.5469, 270.0, -1, -1, -1, -1, -1, -1);
			}
			case 3: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 1560.4922, -1576.2225, 13.5469, 180.0, -1, -1, -1, -1, -1, -1);
			}
			case 4: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 1721.8879, -1608.5669, 13.5469, 0, -1, -1, -1, -1, -1, -1);
			}
			case 5: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 2095.5203, -1796.4194, 13.3828, 90.0, -1, -1, -1, -1, -1, -1);
			}
			case 6: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 1956.6259, -1222.3859, 20.0234, 330.0, -1, -1, -1, -1, -1, -1);
			}
			case 7: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 918.7571, -1103.3179, 24.2966, 270.0, -1, -1, -1, -1, -1, -1);
			}
		}
	}
	else { // Register
		new rand = 1 + random(6);

		Player[playerid][playerLastSpawn] = rand;

		switch(rand) {
			case 1: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 1919.1262, -1759.9194, 13.5469, 0, -1, -1, -1, -1, -1, -1);
			}
			case 2: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 1508.8857, -2287.2163, 13.5469, 270.0, -1, -1, -1, -1, -1, -1);
			}
			case 3: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 1560.4922, -1576.2225, 13.5469, 180.0, -1, -1, -1, -1, -1, -1);
			}
			case 4: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 1721.8879, -1608.5669, 13.5469, 0, -1, -1, -1, -1, -1, -1);
			}
			case 5: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 2095.5203, -1796.4194, 13.3828, 90.0, -1, -1, -1, -1, -1, -1);
			}
			case 6: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 1956.6259, -1222.3859, 20.0234, 330.0, -1, -1, -1, -1, -1, -1);
			}
			case 7: {
				SetSpawnInfo(playerid, 0, Player[playerid][playerSkin], 918.7571, -1103.3179, 24.2966, 270.0, -1, -1, -1, -1, -1, -1);
			}
		}

		SaveAccount(playerid);
	}

	SpawnPlayer(playerid);
}

public OnPlayerText(playerid, text[]) {
	new message[128];

	format(message, sizeof(message), "%s(%d): {FFFFFF}%s", GetName(playerid), playerid, text);
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(IsPlayerConnected(i))
			SendClientMessage(playerid, Player[i][playerLocalColor] >>> 8, message);
	}
	return 0;
}

public OnPlayerRequestClass(playerid, classid) {
	OnPlayerRequestSpawn(playerid);
	return 1;
}

// -------------------User Defined Functions-------------------
public MysqlConnection() { // Connects to the MySQL Database
	g_SQL = mysql_connect(MYSQL_HOST, MYSQL_USERNAME, MYSQL_PASSWORD, MYSQL_DATABASE);
	mysql_log(ERROR | DEBUG);

	return 1;
}

public CheckAccountExist(playerid) { // Checks if an account already exists with the same player name
	new query[256], name[255];
	name = GetName(playerid);

	mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `players` WHERE `pname` = '%e' LIMIT 1", name);
	mysql_tquery(g_SQL, query, "OnCheckAccountExist", "i", playerid);

	return 1;
}

public OnCheckAccountExist(playerid) { // Callback for CheckAccountExist() - Shows Login or Registration dialogs accordingly
	if(cache_num_rows() > 0) {
		new logintext[256];
		cache_get_value(0, "ppassword", Player[playerid][playerPassword], 129);
		cache_get_value_name_int(0, "ploginday", Player[playerid][playerLoginDay]);
		cache_get_value_name_int(0, "ploginmonth", Player[playerid][playerLoginMonth]);
		cache_get_value_name_int(0, "ploginyear", Player[playerid][playerLoginYear]);
		cache_get_value_name_int(0, "ploginhour", Player[playerid][playerLoginHour]);
		cache_get_value_name_int(0, "ploginmin", Player[playerid][playerLoginMin]);
		cache_get_value_name_int(0, "ploginsec", Player[playerid][playerLoginSec]);

		format(logintext, sizeof(logintext), ""COL_WHITE"""We found an account with this name.\nPlease enter your password below to login.");
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Account Login", logintext, "Login", "Quit");
	}
	else
		ShowPlayerDialog(playerid, DIALOG_REGISTER_1, DIALOG_STYLE_PASSWORD, "Account Registration", "Please enter a password below.", "Next", "Quit");

	return 1;
}

stock GetName(playerid) { // Returns the player name, according to the playerid
	new name[255];
	GetPlayerName(playerid, name, sizeof(name));

	return name;
}

public PlayerRegister(playerid) { // Registers the player to the server
	new query[1024], name[255], Cache:result, text[256], year, month, day, hour, minute, second, query2[255], query3[255], query4[512], query5[512];

	name = GetName(playerid);

	Player[playerid][playerName] = name;
	Player[playerid][playerHitSound] = 1;
	Player[playerid][playerTruckerRank] = 1;

	mysql_format(g_SQL, query, sizeof(query), "INSERT INTO `players`(`pname`, `pemail`, `ppassword`) VALUES ('%e', '%e', '%e')", Player[playerid][playerName], Player[playerid][playerEmail], Player[playerid][playerPassword]);
	result = mysql_query(g_SQL, query, true);

	Player[playerid][playerID] = cache_insert_id();

	AssignAffiliateId(playerid);

	TogglePlayerSpectating(playerid, false);

	getdate(year, month, day);
	gettime(hour, minute, second);

	name = GetName(playerid);

	mysql_format(g_SQL, query2, sizeof(query2), "UPDATE `players` SET `ploginday` = '%d', `ploginmonth` = '%d', `ploginyear` = '%d', `ploginhour` = '%d', `ploginmin` = '%d', `ploginsec` = '%d' WHERE `pname` = '%e' LIMIT 1", day, month, year, hour, minute, second, name);
	mysql_tquery(g_SQL, query2);

	mysql_format(g_SQL, query3, sizeof(query3), "UPDATE `players` SET `phouse1` = -1, `phouse2` = -1, `phouse3` = -1, `phouse4` = -1, `plastspawn` = '%d', `phitsound` = 1 WHERE `pname` = '%e' LIMIT 1", Player[playerid][playerLastSpawn], name);
	mysql_tquery(g_SQL, query3);

	mysql_format(g_SQL, query4, sizeof(query4), "UPDATE `players` SET `ppmcolor` = '%d', `pnotcolor` = '%d', `psquadcolor` = '%d', `pgroupcolor` = '%d', `pgangcolor` = '%d', `plocalcolor` = '%d', `pcarwcolor` = '%d', `pwcolor` = '%d', `ppmstatus` = 1 WHERE `pname` = '%e' LIMIT 1", 0xE1F01AAA, 0x1A72F0AA, 0x6196E1AA, 0xD5232CAA, 0x2AB048AA, 0x29D4C4AA, 0xEEF20CAA, 0x757631AA, name);
	mysql_tquery(g_SQL, query4);

	mysql_format(g_SQL, query5, sizeof(query5), "UPDATE `players` SET `ptruckerrank` = 1 WHERE `pname` = '%e' LIMIT 1", name);
	mysql_tquery(g_SQL, query5);

	SendClientMessage(playerid, COLOR_WHITE, "Welcome to SA-MP Türkiye Topluluðu (CnR/Freeroam/Jobs)");

	Player[playerid][playerLoginHour] = hour;
	Player[playerid][playerLoginMin] = minute;
	Player[playerid][playerLoginSec] = second;
	Player[playerid][playerLoginDay] = day;
	Player[playerid][playerLoginMonth] = month;
	Player[playerid][playerLoginYear] = year;

	Player[playerid][playerHouse1] = -1;
	Player[playerid][playerHouse2] = -1;
	Player[playerid][playerHouse3] = -1;
	Player[playerid][playerHouse4] = -1;

	Player[playerid][playerPmStatus] = 1;

	Player[playerid][playerPMColor] = 0xE1F01AAA;
	Player[playerid][playerNotificationColor] = 0x1A72F0AA;
	Player[playerid][playerSquadColor] = 0x6196E1AA;
	Player[playerid][playerGroupColor] = 0xD5232CAA;
	Player[playerid][playerGangColor] = 0x2AB048AA;
	Player[playerid][playerLocalColor] = 0x29D4C4AA;
	Player[playerid][playerCarWhisperColor] = 0xEEF20CAA;
	Player[playerid][playerWhisperColor] = 0x757631AA;

	SafeSetPlayerMoney(playerid, 5000); // @TODO: For testing, remove later

	regflag[playerid] = 1;

	ShowPlayerDialog(playerid, DIALOG_SKIN, DIALOG_STYLE_TABLIST_HEADERS, "Choose a Skin", "ID\tName\n25000\tCalabresi\n25001\tClaude\n25002\tFranklin\n25003\tGerald\n25004\tJackson\n25005\tMichael\n25006\tNiko\n25007\tPaul Walker\n25008\tRich MF\n25009\tRussian Hunter\n25010\tTommy Vercetti\n25011\tTony Montana\n25012\tTrevor", "Select", "Cancel");

	format(text, sizeof(text), "%s has registered to the server.", Player[playerid][playerName]);
	print(text);

	cache_delete(result);

	SaveAccount(playerid);
	return 1;
}

public PlayerLogin(playerid) { // Runs callback to login the player to the server
	new query[256];

	mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `players` WHERE `pname` = '%e'", GetName(playerid));
	mysql_tquery(g_SQL, query, "OnPlayerLogin", "i", playerid);

	return 1;
}

public OnPlayerLogin(playerid) { // Callback for PlayerLogin() - Initializes the player variables & Logs the player in the server
	new text[256], year, month, day, hour, minute, second, name[255], query[256];
	cache_get_value_name_int(0, "pid", Player[playerid][playerID]);
	cache_get_value(0, "pname", Player[playerid][playerName], 255);
	cache_get_value(0, "pemail", Player[playerid][playerEmail], 255);
	cache_get_value(0, "ppassword", Player[playerid][playerPassword], 129);
	cache_get_value_name_int(0, "paffiliateid", Player[playerid][playerAffiliateId]);
	cache_get_value_name_int(0, "pcash", Player[playerid][playerCash]);
	cache_get_value_name_int(0, "ppmstatus", Player[playerid][playerPmStatus]);
	cache_get_value_name_int(0, "pmusic", Player[playerid][playerMusic]);
	cache_get_value_name_int(0, "phitsound", Player[playerid][playerHitSound]);
	cache_get_value_name_int(0, "ppmcolor", Player[playerid][playerPMColor]);
	cache_get_value_name_int(0, "pnotcolor", Player[playerid][playerNotificationColor]);
	cache_get_value_name_int(0, "psquadcolor", Player[playerid][playerSquadColor]);
	cache_get_value_name_int(0, "pgroupcolor", Player[playerid][playerGroupColor]);
	cache_get_value_name_int(0, "pgangcolor", Player[playerid][playerGangColor]);
	cache_get_value_name_int(0, "plocalcolor", Player[playerid][playerLocalColor]);
	cache_get_value_name_int(0, "pcarwcolor", Player[playerid][playerCarWhisperColor]);
	cache_get_value_name_int(0, "pwcolor", Player[playerid][playerWhisperColor]);
	cache_get_value_name_int(0, "ptype", Player[playerid][playerType]);
	cache_get_value_name_int(0, "phouses", Player[playerid][playerHouses]);
	cache_get_value_name_int(0, "phouse1", Player[playerid][playerHouse1]);
	cache_get_value_name_int(0, "phouse2", Player[playerid][playerHouse2]);
	cache_get_value_name_int(0, "phouse3", Player[playerid][playerHouse3]);
	cache_get_value_name_int(0, "phouse4", Player[playerid][playerHouse4]);
	cache_get_value_name_int(0, "ploginday", Player[playerid][playerLoginDay]);
	cache_get_value_name_int(0, "ploginmonth", Player[playerid][playerLoginMonth]);
	cache_get_value_name_int(0, "ploginyear", Player[playerid][playerLoginYear]);
	cache_get_value_name_int(0, "ploginhour", Player[playerid][playerLoginHour]);
	cache_get_value_name_int(0, "ploginmin", Player[playerid][playerLoginMin]);
	cache_get_value_name_int(0, "ploginsec", Player[playerid][playerLoginSec]);
	cache_get_value_name_int(0, "plastspawn", Player[playerid][playerLastSpawn]);
	cache_get_value_name_int(0, "pskin", Player[playerid][playerSkin]);
	cache_get_value_name_int(0, "pjob", Player[playerid][playerJob]);
	cache_get_value_name_int(0, "ptruckerrank", Player[playerid][playerTruckerRank]);
	cache_get_value_name_int(0, "ptruckerrankpoints", Player[playerid][playerTruckerRankPoints]);

	getdate(year, month, day);
	gettime(hour, minute, second);

	name = GetName(playerid);

	mysql_format(g_SQL, query, sizeof(query), "UPDATE `players` SET `ploginday` = '%d', `ploginmonth` = '%d', `ploginyear` = '%d', `ploginhour` = '%d', `ploginmin` = '%d', `ploginsec` = '%d' WHERE `pname` = '%e' LIMIT 1", day, month, year, hour, minute, second, name);
	mysql_tquery(g_SQL, query);

	format(text, sizeof(text), "[Last connection at: %02d:%02d:%02d: - %02d/%02d/%d]", Player[playerid][playerLoginHour], Player[playerid][playerLoginMin], Player[playerid][playerLoginSec], Player[playerid][playerLoginDay], Player[playerid][playerLoginMonth], Player[playerid][playerLoginYear]);
	SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);

	format(text, sizeof(text), "Welcome again, {FFFFFF}%s!", GetName(playerid));
	SendClientMessage(playerid, COLOR_LIGHTCYAN, text);

	SendClientMessage(playerid, COLOR_WHITE, "Welcome to SA-MP Türkiye Topluluðu (CnR/Freeroam/Jobs)");

	format(text, sizeof(text), "%s has logged in to the server.", Player[playerid][playerName]);
	printf(text);

	regflag[playerid] = 0;

	TogglePlayerSpectating(playerid, false);
	return 1;
}

public AssignAffiliateId(playerid) { // Runs callback to assign an affiliate ID to the player
	new query[256], affiliateid;

	affiliateid = 100000 + random(899999);

	mysql_format(g_SQL, query, sizeof(query), "SELECT `paffiliateid` FROM `players` WHERE `paffiliateid` = '%d'", affiliateid);
	mysql_tquery(g_SQL, query, "OnAssignAffiliateId", "ii", playerid, affiliateid);

	return 1;
}

public OnAssignAffiliateId(playerid, affiliateid) { // Callback for AssignAffiliateId() - Assigns affiliate ID to the player
	new query[1024];

	if(cache_num_rows() > 0) {
		AssignAffiliateId(playerid);
	}
	else {
		Player[playerid][playerAffiliateId] = affiliateid;
		mysql_format(g_SQL, query, sizeof(query), "UPDATE `players` SET `paffiliateid` = '%d' WHERE `pname` = '%e'", affiliateid, Player[playerid][playerName]);
		mysql_tquery(g_SQL, query);
	}

	return 1;
}

public CheckReferralId(playerid, affiliateid) { // Checks if the referral ID is valid
	new name[255], text[256];
	if(cache_num_rows() > 0) {
		cache_get_value(0, "pname", name, 255);

		format(text, sizeof(text), ""COL_WHITE"Are you sure that %s referred you?", name);
		ShowPlayerDialog(playerid, DIALOG_REGISTER_4, DIALOG_STYLE_MSGBOX, ""COL_WHITE"Account Registration", text, "Yes", "No");
	}
	else {
		ShowPlayerDialog(playerid, DIALOG_REGISTER_3, DIALOG_STYLE_INPUT, ""COL_WHITE"Account Registration", ""COL_WHITE"You entered an incorrect referral id. Please enter a correct referral ID, if you have one. Leave empty if you don't have any.", "Next", "Back");
	}

	return 1;
}

public WaitDialog(playerid) { // Use this function when you need to add a delay to the start (Background Camera Position works only with delay)
	CheckAccountExist(playerid);
}

public OnCheckPM(message[], playerid, targetid) { // Checks whether the player is allowed to send PM and sends the PM
	new string[128];

	if(cache_num_rows() > 0) {
		SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not allowed to send PMs to this person.");
	}
	else if(Player[targetid][playerPmStatus] == 0)
		SendClientMessage(playerid, COLOR_LIGHTCYAN, "The player has turned off PMs.");
	else {
		format(string, sizeof(string), "{%06x}PM sent to %s: %s", Player[playerid][playerPMColor] >>> 8, Player[targetid][playerName], message);
		SendClientMessage(playerid, -1, string);

		format(string, sizeof(string), "{%06x}PM from %s: %s", Player[targetid][playerPMColor] >>> 8, Player[playerid][playerName], message);
		SendClientMessage(targetid, -1, string);
	}

	return 1;
}

public OnPMOffList(playerid) { // Shows the dialog with the list of people the player has turned off PMs for
	new pmofflist[1000];
	if(cache_num_rows() > 0) {
		for(new i = 0; i < cache_num_rows(); i++)
			cache_get_value(i, "blockpname", pmofflist[i], 255);

		ShowPlayerDialog(playerid, DIALOG_PM_OFF, DIALOG_STYLE_LIST, "PM Off List", pmofflist, "Okay", "");
	}
	else {
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You have not turned off PMs for anyone.");
	}
	return 1;
}

public RangeLocalSend(Float:range, playerid, text[], color) { // Sends a local message to a specific range 
	new Float:px, Float:py, Float:pz;

	GetPlayerPos(playerid, px, py, pz);

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
			{
				if(IsPlayerInRangeOfPoint(i, range, px, py, pz))
					SendClientMessage(i, Player[i][playerLocalColor], text);
			}
		}
	}
	return 1;
}

stock GetVehicleStatus(playerid) { // Returns vehicle parameters
	new vstatus[255];

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
		new vehicleid, engine, lights, alarm, doors, bonnet, boot, objective;

		vehicleid = GetPlayerVehicleID(playerid);
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

		vstatus[0] = vehicleid;
		vstatus[1] = engine;
		vstatus[2] = lights;
		vstatus[3] = alarm;
		vstatus[4] = doors;
		vstatus[5] = bonnet;
		vstatus[6] = boot;
		vstatus[7] = objective;
	}
	else {
		vstatus[0] = -1;
		vstatus[1] = 0;
		vstatus[2] = 0;
		vstatus[3] = 0;
		vstatus[4] = 0;
		vstatus[5] = 0;
		vstatus[6] = 0;
		vstatus[7] = 0;
	}

	return vstatus;
}

stock HexToInt(string[]) { // Converts a Hexadecimal number (Format - 0x33CCFFAA) into an integer
	new value = 0;

	if(sscanf(string, "x", value))
		return 0;
	return value;
}

public LoadHouses() { // Loads all the houses from the database
	new query[255];

	mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `houses`");
	mysql_tquery(g_SQL, query, "OnLoadHouses", "");
	return 1;
}

public OnLoadHouses() { // Callback for OnLoadHoueses() - Initializes all house variables
	newhouseid = 0;
	new rows = cache_num_rows();

	if(rows > 0) {
		for(new i = 0; i < rows; i++) {
			cache_get_value_name_int(i, "hid", House[i][houseID]);
			cache_get_value_name_float(i, "hposx", House[i][housePositionX]);
			cache_get_value_name_float(i, "hposy", House[i][housePositionY]);
			cache_get_value_name_float(i, "hposz", House[i][housePositionZ]);
			cache_get_value_name_float(i, "hexitx", House[i][houseExitX]);
			cache_get_value_name_float(i, "hexity", House[i][houseExitY]);
			cache_get_value_name_float(i, "hexitz", House[i][houseExitZ]);
			cache_get_value_name_int(i, "howner", House[i][houseOwner]);
			cache_get_value_name_int(i, "hprice", House[i][housePrice]);
			cache_get_value_name_int(i, "hinterior", House[i][houseInterior]);
			cache_get_value_name_int(i, "hicon", House[i][houseIcon]);
			cache_get_value_name_int(i, "hpickup", House[i][housePickup]);
			cache_get_value_name_int(i, "hactinterior", House[i][houseActualInterior]);
			cache_get_value_name_int(i, "hgangenterperm", House[i][houseGangEnterPerm]);
			cache_get_value_name_int(i, "hgangfurnitureperm", House[i][houseGangFurniturePerm]);
			cache_get_value_name_int(i, "hgangcaseperm", House[i][houseGangCasePerm]);
			cache_get_value_name_int(i, "hganginventoryperm", House[i][houseGangInventoryPerm]);
			cache_get_value_name_int(i, "hsquadenterperm", House[i][houseSquadEnterPerm]);
			cache_get_value_name_int(i, "hsquadfurnitureperm", House[i][houseSquadFurniturePerm]);
			cache_get_value_name_int(i, "hsquadcaseperm", House[i][houseSquadCasePerm]);
			cache_get_value_name_int(i, "hsquadinventoryperm", House[i][houseSquadInventoryPerm]);
			cache_get_value_name_int(i, "hgroupenterperm", House[i][houseGroupEnterPerm]);
			cache_get_value_name_int(i, "hgroupfurnitureperm", House[i][houseGroupFurniturePerm]);
			cache_get_value_name_int(i, "hgroupcaseperm", House[i][houseGroupCasePerm]);
			cache_get_value_name_int(i, "hgroupinventoryperm", House[i][houseGroupInventoryPerm]);
			cache_get_value_name_int(i, "hfriendsenterperm", House[i][houseFriendsEnterPerm]);
			cache_get_value_name_int(i, "hfriendsfurnitureperm", House[i][houseFriendsFurniturePerm]);
			cache_get_value_name_int(i, "hfriendscaseperm", House[i][houseFriendsCasePerm]);
			cache_get_value_name_int(i, "hfriendsinventoryperm", House[i][houseFriendsInventoryPerm]);
			cache_get_value_name_int(i, "horiginalprice", House[i][houseOriginalPrice]);

			UpdateHouse(i, 0);
		}

		newhouseid = rows;
	}

	printf("Number of houses loaded: %d", rows);
	return 1;
}

public UpdateHouse(houseid, removeold) { // Updates house icon according to the price
	new model;

	if(removeold == 1) {
		DestroyDynamicMapIcon(House[houseid][houseIcon]);
		DestroyPickup(House[houseid][housePickup]);
	}

	if(House[houseid][housePrice] > 0) {
		model = 1273;

		House[houseid][houseIcon] = CreateDynamicMapIcon(House[houseid][housePositionX], House[houseid][housePositionY], House[houseid][housePositionZ], 31, 0, -1, -1, -1, 100.0, MAPICON_LOCAL, -1);
	}
	else {
		House[houseid][houseIcon] = -1;
		model = 1272;
	}

	House[houseid][housePickup] = CreatePickup(model, 1, House[houseid][housePositionX], House[houseid][housePositionY], House[houseid][housePositionZ]);

	return 1;
}

public GetNearestHouse(playerid) { // Returns the in-game house ID nearest to the player (-1 if none)
	for(new i = 0; i < newhouseid; i++) {
		if(IsPlayerInRangeOfPoint(playerid, 2.0, House[i][housePositionX], House[i][housePositionY], House[i][housePositionZ])) {
			return i;
		}
	}
	return -1;
}

public SaveHouse(houseid) { // Updates the house details in the database
	new query[255], query2[255], hid, query3[255], query4[255], query5[255];

	hid = House[houseid][houseID];

	mysql_format(g_SQL, query, sizeof(query), "UPDATE `houses` SET `hposx` = '%f', `hposy` = '%f', `hposz` = '%f', `howner` = '%d', `hprice` = '%d', `hinterior` = '%d' WHERE `hid` = '%d'", House[houseid][housePositionX], House[houseid][housePositionY], House[houseid][housePositionZ], House[houseid][houseOwner], House[houseid][housePrice], House[houseid][houseInterior], hid);
	mysql_tquery(g_SQL, query);

	mysql_format(g_SQL, query2, sizeof(query2), "UPDATE `houses` SET `hicon` = '%d', `hpickup` = '%d', `hexitx` = '%f', `hexity` = '%f', `hexitz` = '%f', `hactinterior` = '%d', `hlastprice` = '%d' WHERE `hid` = '%d'", House[houseid][houseIcon], House[houseid][housePickup], House[houseid][houseExitX], House[houseid][houseExitY], House[houseid][houseExitZ],  House[houseid][houseActualInterior], House[houseid][houseLastPrice], hid);
	mysql_tquery(g_SQL, query2);

	mysql_format(g_SQL, query3, sizeof(query3), "UPDATE `houses` SET `hgangenterperm` = '%d', `hgangfurnitureperm` = '%d', `hgangcaseperm` = '%d', `hganginventoryperm` = '%d', `hsquadenterperm` = '%d', `hsquadfurnitureperm` = '%d' WHERE `hid` = '%d'", House[houseid][houseGangEnterPerm], House[houseid][houseGangFurniturePerm], House[houseid][houseGangCasePerm], House[houseid][houseGangInventoryPerm], House[houseid][houseSquadEnterPerm], House[houseid][houseSquadFurniturePerm], hid);
	mysql_tquery(g_SQL, query3);

	mysql_format(g_SQL, query4, sizeof(query4), "UPDATE `houses` SET `hsquadcaseperm` = '%d', `hsquadinventoryperm` = '%d', `hgroupenterperm` = '%d', `hgroupfurnitureperm` = '%d', `hgroupcaseperm` = '%d', `hgroupinventoryperm` = '%d' WHERE `hid` = '%d'", House[houseid][houseSquadCasePerm], House[houseid][houseSquadInventoryPerm], House[houseid][houseGroupEnterPerm], House[houseid][houseGroupFurniturePerm], House[houseid][houseGroupCasePerm], House[houseid][houseGroupInventoryPerm], hid);
	mysql_tquery(g_SQL, query4);

	mysql_format(g_SQL, query5, sizeof(query5), "UPDATE `houses` SET `hfriendsenterperm` = '%d', `hfriendsfurnitureperm` = '%d', `hfriendscaseperm` = '%d', `hfriendsinventoryperm` = '%d', `horiginalprice` = '%d' WHERE `hid` = '%d'", House[houseid][houseFriendsEnterPerm], House[houseid][houseFriendsFurniturePerm], House[houseid][houseFriendsCasePerm], House[houseid][houseFriendsInventoryPerm], House[houseid][houseOriginalPrice], hid);
	mysql_tquery(g_SQL, query5);
	return 1;
}

public SaveAccount(playerid) { // Updates the player details in the database
	new query[512], query2[512], query3[512], query4[512], query5[512], pid;

	pid = Player[playerid][playerID];

	mysql_format(g_SQL, query, sizeof(query), "UPDATE `players` SET `pname` = '%e', `pemail` = '%e', `ppassword` = '%e', `ploginday` = '%d', `ploginmonth` = '%d', `ploginyear` = '%d', `ploginhour` = '%d' WHERE `pid` = '%d'", Player[playerid][playerName], Player[playerid][playerEmail], Player[playerid][playerPassword], Player[playerid][playerLoginDay], Player[playerid][playerLoginMonth], Player[playerid][playerLoginYear], Player[playerid][playerLoginHour], pid);
	mysql_tquery(g_SQL, query);

	mysql_format(g_SQL, query2, sizeof(query2), "UPDATE `players` SET `ploginmin` = '%d', `ploginsec` = '%d', `pcash` = '%d', `ppmstatus` = '%d', `pmusic` = '%d', `phitsound` = '%d' WHERE `pid` = '%d'", Player[playerid][playerLoginMin], Player[playerid][playerLoginSec], Player[playerid][playerCash], Player[playerid][playerPmStatus], Player[playerid][playerMusic], Player[playerid][playerHitSound], pid);
	mysql_tquery(g_SQL, query2);

	mysql_format(g_SQL, query3, sizeof(query3), "UPDATE `players` SET `ppmcolor` = '%d', `pnotcolor` = '%d', `psquadcolor` = '%d', `pgroupcolor` = '%d', `pgangcolor` = '%d', `plocalcolor` = '%d', `pcarwcolor` = '%d' WHERE `pid` = '%d'", Player[playerid][playerPMColor], Player[playerid][playerNotificationColor], Player[playerid][playerSquadColor], Player[playerid][playerGroupColor], Player[playerid][playerGangColor], Player[playerid][playerLocalColor], Player[playerid][playerCarWhisperColor], pid);
	mysql_tquery(g_SQL, query3);

	mysql_format(g_SQL, query4, sizeof(query4), "UPDATE `players` SET `pwcolor` = '%d', `ptype` = '%d', `phouses` = '%d', `phouse1` = '%d', `phouse2` = '%d', `phouse3` = '%d', `phouse4` = '%d' WHERE `pid` = '%d'", Player[playerid][playerWhisperColor], Player[playerid][playerType], Player[playerid][playerHouses], Player[playerid][playerHouse1], Player[playerid][playerHouse2], Player[playerid][playerHouse3], Player[playerid][playerHouse4], pid);
	mysql_tquery(g_SQL, query4);

	mysql_format(g_SQL, query5, sizeof(query5), "UPDATE `players` SET `plastspawn` = '%d', `pskin` = '%d', `pjob` = '%d', `ptruckerrank` = '%d', `ptruckerrankpoints` = '%d' WHERE `pid` = '%d'", Player[playerid][playerLastSpawn], Player[playerid][playerSkin], Player[playerid][playerJob], Player[playerid][playerTruckerRank], Player[playerid][playerTruckerRankPoints], pid);
	mysql_tquery(g_SQL, query5);
	return 1;
}

// Anti-Money Cheat
public SafeGetPlayerMoney(playerid) { // Returns the server-side cash of the player
	return Player[playerid][playerCash];
}

public SafeGivePlayerMoney(playerid, amount) { // Gives the server-side cash to the player
	Player[playerid][playerCash] += amount;
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Player[playerid][playerCash]);
	return 1;
}

public SafeSetPlayerMoney(playerid, amount) { // Sets the server-side cash of the player
	Player[playerid][playerCash] = amount;
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Player[playerid][playerCash]);
}

public CheckMoney(playerid) { // Checks whether the in-game money of player is equal to the amount in database
	if(Player[playerid][playerCash] != GetPlayerMoney(playerid)) {
		SafeSetPlayerMoney(playerid, Player[playerid][playerCash]);
	}
	return 1;
}

public SetHouseDetails(houseid, interior) { // Sets house exit co-ordinates & actual interiors according to the in-game interiors
	switch(interior) {
		case 1: {
			House[houseid][houseActualInterior] = 5;
			House[houseid][houseExitX] = 1260.64;
			House[houseid][houseExitY] = -785.37;
			House[houseid][houseExitZ] = 1091.91;
		}
		case 2: {
			House[houseid][houseActualInterior] = 5;
			House[houseid][houseExitX] = 140.17;
			House[houseid][houseExitY] = 1366.07;
			House[houseid][houseExitZ] = 1083.65;
		}
		case 3: {
			House[houseid][houseActualInterior] = 12;
			House[houseid][houseExitX] = 2324.53;
			House[houseid][houseExitY] = -1149.54;
			House[houseid][houseExitZ] = 1050.71;
		}
		case 4: {
			House[houseid][houseActualInterior] = 7;
			House[houseid][houseExitX] = 225.68;
			House[houseid][houseExitY] = 1021.45;
			House[houseid][houseExitZ] = 1084.02;
		}
		case 5: {
			House[houseid][houseActualInterior] = 6;
			House[houseid][houseExitX] = 234.19;
			House[houseid][houseExitY] = 1063.73;
			House[houseid][houseExitZ] = 1084.21;
		}
		case 6: {
			House[houseid][houseActualInterior] = 5;
			House[houseid][houseExitX] = 226.30;
			House[houseid][houseExitY] = 1114.24;
			House[houseid][houseExitZ] = 1080.99;
		}
		// Medium Interiors
		case 7: {
			House[houseid][houseActualInterior] = 3;
			House[houseid][houseExitX] = 235.34;
			House[houseid][houseExitY] = 1186.68;
			House[houseid][houseExitZ] = 1080.26;
		}
		case 8: {
			House[houseid][houseActualInterior] = 2;
			House[houseid][houseExitX] = 491.07;
			House[houseid][houseExitY] = 1398.50;
			House[houseid][houseExitZ] = 1080.26;
		}
		case 9: {
			House[houseid][houseActualInterior] = 10;
			House[houseid][houseExitX] = 24.04;
			House[houseid][houseExitY] = 1340.17;
			House[houseid][houseExitZ] = 1084.38;
		}
		case 10: {
			House[houseid][houseActualInterior] = 15;
			House[houseid][houseExitX] = -283.44;
			House[houseid][houseExitY] = 1470.93;
			House[houseid][houseExitZ] = 1084.38;
		}
		case 11: {
			House[houseid][houseActualInterior] = 4;
			House[houseid][houseExitX] = -260.49;
			House[houseid][houseExitY] = 1456.75;
			House[houseid][houseExitZ] = 1084.37;
		}
		case 12: {
			House[houseid][houseActualInterior] = 9;
			House[houseid][houseExitX] = 83.03;
			House[houseid][houseExitY] = 1322.28;
			House[houseid][houseExitZ] = 1083.87;
		}
		case 13: {
			House[houseid][houseActualInterior] = 9;
			House[houseid][houseExitX] = 2317.89;
			House[houseid][houseExitY] = -1026.76;
			House[houseid][houseExitZ] = 1050.22;
		}
		case 14: {
			House[houseid][houseActualInterior] = 3;
			House[houseid][houseExitX] = 2495.98;
			House[houseid][houseExitY] = -1692.08;
			House[houseid][houseExitZ] = 1014.74;
		}
		case 15: {
			House[houseid][houseActualInterior] = 8;
			House[houseid][houseExitX] = 2807.48;
			House[houseid][houseExitY] = -1174.76;
			House[houseid][houseExitZ] = 1025.57;
		}
		case 16: {
			House[houseid][houseActualInterior] = 6;
			House[houseid][houseExitX] = 2196.85;
			House[houseid][houseExitY] = -1204.25;
			House[houseid][houseExitZ] = 1049.02;
		}
		case 17: {
			House[houseid][houseActualInterior] = 15;
			House[houseid][houseExitX] = 377.15;
			House[houseid][houseExitY] = 1417.41;
			House[houseid][houseExitZ] = 1081.33;
		}
		case 18: {
			House[houseid][houseActualInterior] = 10;
			House[houseid][houseExitX] = 2270.38;
			House[houseid][houseExitY] = -1210.35;
			House[houseid][houseExitZ] = 1047.56;
		}
		case 19: {
			House[houseid][houseActualInterior] = 2;
			House[houseid][houseExitX] = 446.99;
			House[houseid][houseExitY] = 1397.07;
			House[houseid][houseExitZ] = 1084.30;
		}
		case 20: {
			House[houseid][houseActualInterior] = 15;
			House[houseid][houseExitX] = 387.22;
			House[houseid][houseExitY] = 1471.70;
			House[houseid][houseExitZ] = 1080.19;
		}
		case 21: {
			House[houseid][houseActualInterior] = 5;
			House[houseid][houseExitX] = 22.88;
			House[houseid][houseExitY] = 1403.33;
			House[houseid][houseExitZ] = 1084.44;
		}
		case 22: {
			House[houseid][houseActualInterior] = 8;
			House[houseid][houseExitX] = 2365.31;
			House[houseid][houseExitY] = -1135.60;
			House[houseid][houseExitZ] = 1050.88;
		}
		case 23: {
			House[houseid][houseActualInterior] = 2;
			House[houseid][houseExitX] = 2237.59;
			House[houseid][houseExitY] = -1081.64;
			House[houseid][houseExitZ] = 1049.02;
		}
		case 24: {
			House[houseid][houseActualInterior] = 15;
			House[houseid][houseExitX] = 295.04;
			House[houseid][houseExitY] = 1472.26;
			House[houseid][houseExitZ] = 1080.26;
		}
		case 25: {
			House[houseid][houseActualInterior] = 4;
			House[houseid][houseExitX] = 261.12;
			House[houseid][houseExitY] = 1284.30;
			House[houseid][houseExitZ] = 1080.26;
		}
		case 26: {
			House[houseid][houseActualInterior] = 4;
			House[houseid][houseExitX] = 221.92;
			House[houseid][houseExitY] = 1140.20;
			House[houseid][houseExitZ] = 1082.61;
		}
		case 27: {
			House[houseid][houseActualInterior] = 6;
			House[houseid][houseExitX] = -68.81;
			House[houseid][houseExitY] = 1351.21;
			House[houseid][houseExitZ] = 1080.21;
		}
		case 28: {
			House[houseid][houseActualInterior] = 9;
			House[houseid][houseExitX] = 260.85;
			House[houseid][houseExitY] = 1237.24;
			House[houseid][houseExitZ] = 1084.26;
		}
		case 29: {
			House[houseid][houseActualInterior] = 2;
			House[houseid][houseExitX] = 2468.84;
			House[houseid][houseExitY] = -1698.24;
			House[houseid][houseExitZ] = 1013.51;
		}
		// Small Interiors
		case 30: {
			House[houseid][houseActualInterior] = 1;
			House[houseid][houseExitX] = 223.20;
			House[houseid][houseExitY] = 1287.08;
			House[houseid][houseExitZ] = 1082.14;
		}
		case 31: {
			House[houseid][houseActualInterior] = 11;
			House[houseid][houseExitX] = 2283.04;
			House[houseid][houseExitY] = -1140.28;
			House[houseid][houseExitZ] = 1050.90;
		}
		case 32: {
			House[houseid][houseActualInterior] = 15;
			House[houseid][houseExitX] = 328.05;
			House[houseid][houseExitY] = 1477.73;
			House[houseid][houseExitZ] = 1084.44;
		}
		case 33: {
			House[houseid][houseActualInterior] = 1;
			House[houseid][houseExitX] = 223.20;
			House[houseid][houseExitY] = 1287.08;
			House[houseid][houseExitZ] = 1082.14;
		}
		case 34: {
			House[houseid][houseActualInterior] = 8;
			House[houseid][houseExitX] = -42.59;
			House[houseid][houseExitY] = 1405.47;
			House[houseid][houseExitZ] = 1084.43;
		}
		case 35: { // Bugged
			House[houseid][houseActualInterior] = 12;
			House[houseid][houseExitX] = 446.90;
			House[houseid][houseExitY] = 506.35;
			House[houseid][houseExitZ] = 1001.42;
		}
		case 36: {
			House[houseid][houseActualInterior] = 4;
			House[houseid][houseExitX] = 299.78;
			House[houseid][houseExitY] = 309.89;
			House[houseid][houseExitZ] = 1003.30;
		}
		case 37: {
			House[houseid][houseActualInterior] = 6;
			House[houseid][houseExitX] = 2308.77;
			House[houseid][houseExitY] = -1212.94;
			House[houseid][houseExitZ] = 1049.02;
		}
		case 38: {
			House[houseid][houseActualInterior] = 5;
			House[houseid][houseExitX] = 2233.64;
			House[houseid][houseExitY] = -1115.26;
			House[houseid][houseExitZ] = 1050.88;
		}
		case 39: {
			House[houseid][houseActualInterior] = 1;
			House[houseid][houseExitX] = 2218.40;
			House[houseid][houseExitY] = -1076.18;
			House[houseid][houseExitZ] = 1050.48;
		}
		case 40: {
			House[houseid][houseActualInterior] = 2;
			House[houseid][houseExitX] = 266.50;
			House[houseid][houseExitY] = 304.90;
			House[houseid][houseExitZ] = 999.15;
		}
		case 41: {
			House[houseid][houseActualInterior] = 1;
			House[houseid][houseExitX] = 243.72;
			House[houseid][houseExitY] = 304.91;
			House[houseid][houseExitZ] = 999.15;
		}
		case 42: {
			House[houseid][houseActualInterior] = 6;
			House[houseid][houseExitX] = 343.81;
			House[houseid][houseExitY] = 304.86;
			House[houseid][houseExitZ] = 999.15;
		}
		case 43: {
			House[houseid][houseActualInterior] = 10;
			House[houseid][houseExitX] = 2259.38;
			House[houseid][houseExitY] = -1135.77;
			House[houseid][houseExitZ] = 1050.64;
		}
	}
	SaveHouse(houseid);
	return 1;
}

public PutPlayerInHouse(playerid, houseid) { // Teleports the player inside the house
	if(House[houseid][houseID] == -1)
		return 1;

	currenthouseid[playerid] = houseid;
	SetPlayerVirtualWorld(playerid, houseid + 1);
	SetPlayerInterior(playerid, House[houseid][houseActualInterior]);
	SetPlayerPos(playerid, House[houseid][houseExitX], House[houseid][houseExitY], House[houseid][houseExitZ]);

	GameTextForPlayer(playerid, "Welcome", 1500, 1);
	return 1;
}

public CheckPlayerSQL(playerid, playersqlid) { // Checks whether a player with the given SQL ID exists or not
	if(cache_num_rows() == 0)
		SetPVarInt(playerid, "sqlcheck", 1);
	else
		SetPVarInt(playerid, "sqlcheck", 0);
	return 1;
}

public OnHouseSQL(playerid, playersqlid) { // Shows the list of DB House IDs for the given player SQL ID
	new houses[4], text[255], rows;

	rows = cache_num_rows();

	if(rows > 0) {
		if(rows == 1) {
			cache_get_value_name_int(0, "hid", houses[0]);

			format(text, sizeof(text), "House %d", houses[0]);
		}
		else if(rows == 2) {
			cache_get_value_name_int(0, "hid", houses[0]);
			cache_get_value_name_int(1, "hid", houses[1]);

			format(text, sizeof(text), "House %d\nHouse %d", houses[0], houses[1]);
		}
		else if(rows == 3) {
			cache_get_value_name_int(0, "hid", houses[0]);
			cache_get_value_name_int(1, "hid", houses[1]);
			cache_get_value_name_int(2, "hid", houses[2]);

			format(text, sizeof(text), "House %d\nHouse %d\nHouse %d", houses[0], houses[1], houses[2]);
		}
		else if(rows == 4) {
			cache_get_value_name_int(0, "hid", houses[0]);
			cache_get_value_name_int(1, "hid", houses[1]);
			cache_get_value_name_int(2, "hid", houses[2]);
			cache_get_value_name_int(3, "hid", houses[3]);

			format(text, sizeof(text), "House %d\nHouse %d\nHouse %d\nHouse %d", houses[0], houses[1], houses[2], houses[3]);
		}
		ShowPlayerDialog(playerid, DIALOG_PLAYER_HOUSES_SQL, DIALOG_STYLE_LIST, "Player Houses with SQL IDs", text, "Okay", "");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "The player does not own any house.");

	return 1;
}

public OnPlayerPermissions(playerid, targetid, houseid) { // Shows the player permissions for another player (Inserts to the DB if doesn't exist)
	if(cache_num_rows() > 0) {
		new enter, furniture, caseh, inv, text[255];
		cache_get_value_name_int(0, "enterperm", enter);
		cache_get_value_name_int(0, "furnperm", furniture);
		cache_get_value_name_int(0, "caseperm", caseh);
		cache_get_value_name_int(0, "invperm", inv);
		SetPVarInt(playerid, "playerperm", targetid);
		SetPVarInt(playerid, "hidperm", houseid);

		SetPVarInt(playerid, "penterperm", enter);
		SetPVarInt(playerid, "pfurnperm", furniture);
		SetPVarInt(playerid, "pcaseperm", caseh);
		SetPVarInt(playerid, "pinvperm", inv);

		format(text, sizeof(text), "Name\tPermission\nEnter\t%d\nFurniture\t%d\nCase\t%d\nInventory\t%d", enter, furniture, caseh, inv);
		ShowPlayerDialog(playerid, DIALOG_SET_PERM_PLAYER, DIALOG_STYLE_TABLIST_HEADERS, "Set Permissions", text, "Change", "Cancel");
	}
	else {
		new query[255];
		mysql_format(g_SQL, query, sizeof(query), "INSERT INTO `permissions` (`hid`, `pid`, `enterperm`, `furnperm`, `caseperm`, `invperm`) VALUES ('%d', '%d', '%d', '%d', '%d', '%d')", houseid, targetid, 1, 1, 1, 1);
		mysql_tquery(g_SQL, query);

		cmd_permissions(playerid);
	}
	return 1;
}

public DelayedKick(playerid) { // Use this function when you need to add a delay to the kick - to show a message
	return Kick(playerid);
}

public LoadPrices() {
	new query[255];

	mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `truckerprices`");
	mysql_tquery(g_SQL, query, "OnLoadPrices");
	return 1;
}

public OnLoadPrices() {
	cache_get_value_name_int(0, "fruitsbp", fruitsbuyprice);
	cache_get_value_name_int(0, "mealbp", mealbuyprice);
	cache_get_value_name_int(0, "weaponpartsbp", weaponpartsbuyprice);
	cache_get_value_name_int(0, "shoesbp", shoesbuyprice);
	cache_get_value_name_int(0, "weaponsbp", weaponsbuyprice);
	cache_get_value_name_int(0, "ammobp", ammobuyprice);
	cache_get_value_name_int(0, "fruitssp", fruitssellprice);
	cache_get_value_name_int(0, "mealsp", mealsellprice);
	cache_get_value_name_int(0, "weaponpartssp", weaponpartssellprice);
	cache_get_value_name_int(0, "shoessp", shoessellprice);
	cache_get_value_name_int(0, "weaponssp", weaponssellprice);
	cache_get_value_name_int(0, "ammosp", ammosellprice);
	return 1;
}

public LoadJobs() {
	new query[255];

	mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `jobs`");
	mysql_tquery(g_SQL, query, "OnLoadJobs");
	return 1;
}

public OnLoadJobs() {
	new rows = cache_num_rows();
	newjobid = 1;

	if(rows > 0) {
		for(new i = 0; i < rows; i++) {
			cache_get_value_name_int(i, "jobid", Job[newjobid][jobID]);
			cache_get_value_name(i, "jobname", Job[newjobid][jobName], 128);
			cache_get_value_name_int(i, "jobpickup", Job[newjobid][jobPickup]);
			cache_get_value_name_float(i, "jobposx", Job[newjobid][jobPositionX]);
			cache_get_value_name_float(i, "jobposy", Job[newjobid][jobPositionY]);
			cache_get_value_name_float(i, "jobposz", Job[newjobid][jobPositionZ]);

			UpdateJob(i + 1, 0);
			newjobid++;
		}
	}

	printf("Number of jobs loaded: %d", rows);
}

public UpdateJob(jobid, removeold) { // Updates job icon
	if(removeold == 1)
		DestroyPickup(Job[jobid][jobPickup]);

	Job[jobid][jobPickup] = CreatePickup(1239, 1, Job[jobid][jobPositionX], Job[jobid][jobPositionY], Job[jobid][jobPositionZ], 0);

	return 1;
}

public ChangePrices() {
	new query[512], hour, minute, second;

	gettime(hour, minute, second);

	if(minute == 0 && second == 0) {
		fruitsbuyprice = 200 + random(100);
		mealbuyprice = 100 + random(100);
		weaponpartsbuyprice = 400 + random(100);
		shoesbuyprice = 50 + random(500);
		weaponsbuyprice = 700 + random(200);
		ammobuyprice = 300 + random(100);

		fruitssellprice = 350 + random(100);
		mealsellprice = 250 + random(50);
		weaponpartssellprice = 520 + random(130);
		shoessellprice = 120 + random(80);
		weaponssellprice = 920 + random(280);
		ammosellprice = 400 + random(100);

		mysql_format(g_SQL, query, sizeof(query), "UPDATE `truckerprices` SET `fruitsbp` = '%d', `mealbp` = '%d', `weaponpartsbp` = '%d', `shoesbp` = '%d' , `weaponsbp` = '%d' , `ammobp` = '%d', `fruitssp` = '%d', `mealsp` = '%d', `weaponpartssp` = '%d', `shoessp` = '%d', `weaponssp` = '%d', `ammosp` = '%d'", fruitsbuyprice, mealbuyprice, weaponpartsbuyprice, shoesbuyprice, weaponsbuyprice, ammobuyprice, fruitssellprice, mealsellprice, weaponpartssellprice, shoessellprice, weaponssellprice, ammosellprice);
		mysql_tquery(g_SQL, query);
	}	
	return 1;
}

public GetNearestJob(playerid) { // Returns the nearest job to the player (-1 if none)
	for(new i = 1; i < newjobid; i++)
		if(IsPlayerInRangeOfPoint(playerid, 2.0, Job[i][jobPositionX], Job[i][jobPositionY], Job[i][jobPositionZ]))
			return i;
	return -1;
}

public OnPlayerPickUpPickup(playerid, pickupid) {
	if(Player[playerid][playerJob] == 1) { // Trucker
		if(pickupid == truckerspawnpickup && truckerpickedup[playerid] == 0) {
			truckerpickedup[playerid] = 1;

			switch(Player[playerid][playerTruckerRank]) {
				case 1:
					ShowPlayerDialog(playerid, DIALOG_TRUCKER_SPAWN, DIALOG_STYLE_TABLIST, "Spawn Vehicle", "Rank 1 (Picador)", "Spawn", "Cancel");
				case 2:
					ShowPlayerDialog(playerid, DIALOG_TRUCKER_SPAWN, DIALOG_STYLE_TABLIST, "Spawn Vehicle", "Rank 1 (Picador)\nRank 2 (Bobcat)", "Spawn", "Cancel");
				case 3:
					ShowPlayerDialog(playerid, DIALOG_TRUCKER_SPAWN, DIALOG_STYLE_TABLIST, "Spawn Vehicle", "Rank 1 (Picador)\nRank 2 (Bobcat)\nRank 3 (Yosemite)", "Spawn", "Cancel");
				case 4:
					ShowPlayerDialog(playerid, DIALOG_TRUCKER_SPAWN, DIALOG_STYLE_TABLIST, "Spawn Vehicle", "Rank 1 (Picador)\nRank 2 (Bobcat)\nRank 3 (Yosemite)\nRank 4 (Burrito)", "Spawn", "Cancel");
				case 5:
					ShowPlayerDialog(playerid, DIALOG_TRUCKER_SPAWN, DIALOG_STYLE_TABLIST, "Spawn Vehicle", "Rank 1 (Picador)\nRank 2 (Bobcat)\nRank 3 (Yosemite)\nRank 4 (Burrito)\nRank 5 (Mule)", "Spawn", "Cancel");
			}
			
		}
	}
	return 1;
}

public CreateTruckerIcons() {
	truckerspawnpickup = CreatePickup(1239, 1, 2792.4734, -2418.4648, 13.6325, 0);
	CreatePickup(1239, 1, 2748.6235, -2452.5361, 13.8623, 0);
	return 1;
}

// -------------------COMMANDS-------------------
// -------------------PM-------------------
CMD:pm(playerid, params[]) {  // Sends a message to the player
	new targetid, message[128], query[256];

	if(sscanf(params, "us[128]", targetid, message))
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /pm [playerid] [message]");

	if(IsPlayerConnected(targetid)) {
		if(targetid == playerid)
			return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

		mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `pmblocks` WHERE `pname` = '%e' AND `blockpname` = '%e'", GetName(targetid), GetName(playerid));
		mysql_tquery(g_SQL, query, "OnCheckPM", "sii", message, playerid, targetid);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");

	return 1;
}

CMD:pmoff(playerid, params[]) { // Turns off pms for a particular player
	new targetid, query2[512], text[128];

	if(Player[playerid][playerPmStatus] == 0)
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Your PMs are already turned off.");

	if(isnull(params)) {
		Player[playerid][playerPmStatus] = 0;

		SaveAccount(playerid);

		return SendClientMessage(playerid, COLOR_YELLOW, "PMs turned off.");
	}
	else if(sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /pmoff [playerid]");

	if(IsPlayerConnected(targetid)) {
		if(targetid == playerid)
			return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

		mysql_format(g_SQL, query2, sizeof(query2), "INSERT INTO `pmblocks`(`pname`, `blockpname`) VALUES ('%e', '%e')", GetName(playerid), GetName(targetid));
		mysql_tquery(g_SQL, query2);

		format(text, sizeof(text), "PMs turned off for %s.", Player[targetid][playerName]);
		SendClientMessage(playerid, COLOR_NEUTRAL, text);
	}
	else {
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}

	return 1;
}

CMD:pmofflist(playerid, params[]) { // Lists the players blocked for PMs
	new query[256];

	mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `pmblocks` WHERE `pname` = '%e'", GetName(playerid));
	mysql_tquery(g_SQL, query, "OnPMOffList", "i", playerid);

	return 1;
}

CMD:pmon(playerid, params[]) { // Turns off pms for a particular player
	new targetid, query[512], query2[512], text[128];

	if(Player[playerid][playerPmStatus] == 1 && isnull(params))
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Your PMs are already turned on.");

	if(isnull(params)) {
		Player[playerid][playerPmStatus] = 1;

		SaveAccount(playerid);

		return SendClientMessage(playerid, COLOR_YELLOW, "PMs turned on.");
	}
	else if(sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /pmon [playerid]");

	if(IsPlayerConnected(targetid)) {
		if(targetid == playerid)
			return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

		mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `pmblocks` WHERE `pname` = '%e' AND `blockpname` = '%e'", GetName(playerid), GetName(targetid));
		new Cache:result = mysql_query(g_SQL, query, true);

		if(cache_num_rows() > 0) {
			mysql_format(g_SQL, query2, sizeof(query2), "DELETE FROM `pmblocks` WHERE `pname` = '%e' AND `blockpname` = '%e", GetName(playerid), GetName(targetid));
			mysql_tquery(g_SQL, query2);
		}
		else {
			mysql_format(g_SQL, query2, sizeof(query2), "INSERT INTO `pmblocks`(`pname`, `blockpname`) VALUES ('%e', '%e')", GetName(playerid), GetName(targetid));
			mysql_tquery(g_SQL, query2);
		}

		format(text, sizeof(text), "PMs turned on for %s.", GetName(targetid));
		SendClientMessage(playerid, COLOR_NEUTRAL, text);

		cache_delete(result);
	}
	else {
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}

	return 1;
}

// -------------------Chat-------------------
CMD:l(playerid, params[]) { // Local chat
	new string[512], text[512];

	if(sscanf(params, "s[128]", text))
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /l [text]");	

	format(string, sizeof(string), "%s(%d): %s", Player[playerid][playerName], playerid, text);
	RangeLocalSend(30.0, playerid, string, -1);

	return 1;
}

CMD:w(playerid, params[]) { // Whisper
	new targetid, text[512], Float:px, Float:py, Float:pz, string[512];

	GetPlayerPos(playerid, px, py, pz);

	if(sscanf(params, "us[128]", targetid, text))
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /w [playerid] [text]");

	if(IsPlayerConnected(targetid)) {
		if(targetid == playerid)
			return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

		if(IsPlayerInRangeOfPoint(targetid, 20.0, px, py, pz)){
			format(string, sizeof(string), "{%06x}%s whispers: %s", Player[targetid][playerWhisperColor] >>> 8, Player[playerid][playerName], text);
			SendClientMessage(targetid, -1, string);

			format(string, sizeof(string), "{%06x}Whisper to %s: %s", Player[playerid][playerWhisperColor] >>> 8, Player[targetid][playerName], text);
			SendClientMessage(playerid, -1, string);
		}
		else {
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "The player is not in range.");
		}
	}
	else {
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}

	return 1;
}

CMD:cw(playerid, params[]) { // Car whisper
	new text[512], vehicleid, string[256];

	if(sscanf(params, "s[128]", text))
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /cw [text]");

	if(IsPlayerInAnyVehicle(playerid)) {
		vehicleid = GetPlayerVehicleID(playerid);

		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerInVehicle(i, vehicleid)) {
				format(string, sizeof(string), "{%06x}[Car Whisper] %s: %s", Player[playerid][playerCarWhisperColor] >>> 8, Player[playerid][playerName], text);
				SendClientMessage(i, -1, string);
			}
		}
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not inside a vehicle.");

	return 1;
}

// -------------------General-------------------
CMD:cmds(playerid, params[])
	return cmd_commands(playerid, params);

CMD:commands(playerid, params[]) { // Shows a list of commands
	ShowPlayerDialog(playerid, DIALOG_COMMANDS, DIALOG_STYLE_LIST, "Commands", "/pm\n/pmoff\n/pmofflist\n/l\n/w\n/cw\n/commands\n/help\n/inv(entory)\n/settings\n/buyhouse\n/sellthesystem\n/sellhouse\n/permissions\n/furniture\n/findhouse", "Okay", "");

	return 1;
}

CMD:help(playerid, params[]) { // Shows help for the server
	new text[255];
	format(text, sizeof(text), "{FFFFFF}General Help\n{0000FF}Police Help\n{FF0000}Robbery Help\nJob Help\nGang Help\nSquad Help\nGroup Help\n{FFFF00}Minigame Help");
	ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST, "Help", text, "Okay", "Cancel");

	return 1;
}

CMD:inv(playerid, params[])
	return cmd_inventory(playerid, params);

CMD:inventory(playerid, params[]) { // Shows inventory for the player
	ShowPlayerDialog(playerid, DIALOG_INVENTORY, DIALOG_STYLE_MSGBOX, "Inventory", "Inventory", "Okay", "");

	return 1;
}

CMD:settings(playerid, params[]) { // Shows list of settings for the player
	new text[1500], text2[512], vstatus[255], text3[512], text4[512];

	vstatus = GetVehicleStatus(playerid);

	format(text, sizeof(text), "Setting\tInformation\nStatus\tCivilian\nPM\t%d\nMusic\t%d\nCar HUD\t%d\nHit Effect Sound\t%d", Player[playerid][playerPmStatus], Player[playerid][playerMusic], vstatus[2], Player[playerid][playerHitSound]);

	strreplace(text, "-1", "{AA3333}OFF");
	strreplace(text, "1", "{33AA33}ON");
	strreplace(text, "0", "{AA3333}OFF");

	format(text2, sizeof(text2), "\nPM Color\t{%06x}%06x\nNotification Color\t{%06x}%06x\nSquad Color\t{%06x}%06x", Player[playerid][playerPMColor] >>> 8, Player[playerid][playerPMColor] >>> 8, Player[playerid][playerNotificationColor] >>> 8, Player[playerid][playerNotificationColor] >>> 8, Player[playerid][playerSquadColor] >>> 8, Player[playerid][playerSquadColor] >>> 8);

	strcat(text, text2);

	format(text3, sizeof(text3), "\nGroup Color\t{%06x}%06x\nGang Color\t{%06x}%06x\nLocal Chat Color\t{%06x}%06x", Player[playerid][playerGroupColor] >>> 8, Player[playerid][playerGroupColor] >>> 8, Player[playerid][playerGangColor] >>> 8, Player[playerid][playerGangColor] >>> 8, Player[playerid][playerLocalColor] >>> 8, Player[playerid][playerLocalColor] >>> 8);

	strcat(text, text3);

	format(text4, sizeof(text4), "\nCar Whisper Color\t{%06x}%06x\nWhisper Color\t{%06x}%06x\nTalk Channel\tSquad\nAffiliate ID\t%d", Player[playerid][playerCarWhisperColor] >>> 8, Player[playerid][playerCarWhisperColor] >>> 8, Player[playerid][playerWhisperColor] >>> 8, Player[playerid][playerWhisperColor] >>> 8, Player[playerid][playerAffiliateId]);

	strcat(text, text4);

	ShowPlayerDialog(playerid, DIALOG_SETTINGS, DIALOG_STYLE_TABLIST_HEADERS, "Settings", text, "Select", "Cancel");

	return 1;
}

// ---------------Admin Commands--------------
// -------------------House-------------------
CMD:createhouse(playerid, params[]) { // Creates new house
	new interior, price, query[255], Float:x, Float:y, Float:z;

	if(Player[playerid][playerAdminLevel] > 0 || IsPlayerAdmin(playerid)) {
		if(sscanf(params, "ii", interior, price))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /createhouse [interior] [price]");

		if(newhouseid >= MAX_HOUSES)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Maximum house limit reached.");

		if(interior < 1 || interior > 43)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid interior!");

		if(price < 0)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid price!");

		GetPlayerPos(playerid, x, y, z);

		mysql_format(g_SQL, query, sizeof(query), "INSERT INTO `houses`(`hposx`, `hposy`, `hposz`, `howner`, `hprice`, `hinterior`) VALUES ('%f', '%f', '%f', 'None', '%d', '%d')", x, y, z, price, interior);
		new Cache:result = mysql_query(g_SQL, query, true);

		House[newhouseid][houseID] = cache_insert_id();
		House[newhouseid][housePositionX] = x;
		House[newhouseid][housePositionY] = y;
		House[newhouseid][housePositionZ] = z;
		House[newhouseid][houseOwner] = -1;
		House[newhouseid][housePrice] = price;
		House[newhouseid][houseInterior] = interior;
		House[newhouseid][houseLastPrice] = price;
		House[newhouseid][houseOriginalPrice] = price;
		
		SetHouseDetails(newhouseid, interior);
		UpdateHouse(newhouseid, 0);
		SaveHouse(newhouseid);
		newhouseid++;

		cache_delete(result);
	}
	else {
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not authorized to use this command.");
	}

	return 1;
}

CMD:deletehouse(playerid, params[]) { // Deletes a house
	if(Player[playerid][playerAdminLevel] > 0 || IsPlayerAdmin(playerid)) {
		new houseid, query[255], hid;

		if(sscanf(params, "i", houseid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /deletehouse [houseid]");

		if(House[houseid][housePositionX] == 0.0 || House[houseid][houseID] == -1)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid house id!");

		hid = House[houseid][houseID];

		DestroyDynamicMapIcon(House[houseid][houseIcon]);
		DestroyPickup(House[houseid][housePickup]);

		House[houseid][houseID] = -1;

		if(Player[playerid][playerHouse1] == hid) {
			Player[playerid][playerHouse1] = -1;
			Player[playerid][playerHouses]--;
		}
		else if(Player[playerid][playerHouse2] == hid) {
			Player[playerid][playerHouse2] = -1;
			Player[playerid][playerHouses]--;
		}
		else if(Player[playerid][playerHouse3] == hid) {
			Player[playerid][playerHouse3] = -1;
			Player[playerid][playerHouses]--;
		}
		else if(Player[playerid][playerHouse4] == hid) {
			Player[playerid][playerHouse4] = -1;
			Player[playerid][playerHouses]--;
		}

		SaveAccount(playerid);

		mysql_format(g_SQL, query, sizeof(query), "DELETE FROM `houses` WHERE `hid` = '%d'", hid);
		mysql_tquery(g_SQL, query);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not authorized to use this command.");
	return 1;
}

CMD:hsetinterior(playerid, params[]) { // Sets the interior for the house
	if(Player[playerid][playerAdminLevel] > 0 || IsPlayerAdmin(playerid)) {
		new houseid, interior, text[128];

		if(sscanf(params, "ii", houseid, interior))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /hsetinterior [houseid] [interiorid]");

		if(House[houseid][housePositionX] == 0.0 || House[houseid][houseID] == -1)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid house id!");

		if(interior < 1 || interior > 43)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid interior!");

		House[houseid][houseInterior] = interior;

		SaveHouse(houseid);

		format(text, sizeof(text), "Interior %d set for house %d", interior, houseid);
		SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not authorized to use this command.");

	return 1;
}

CMD:hsetprice(playerid, params[]) { // Sets the price for the house
	if(Player[playerid][playerAdminLevel] > 0 || IsPlayerAdmin(playerid)) {
		new houseid, price, text[128];

		if(sscanf(params, "ii", houseid, price))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /hsetinterior [houseid] [price]");

		if(House[houseid][housePositionX] == 0.0 || House[houseid][houseID] == -1)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid house id!");

		if(price < 0)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid price!");

		House[houseid][housePrice] = price;

		UpdateHouse(houseid, 1);
		SaveHouse(houseid);

		format(text, sizeof(text), "$%d Price set for house %d", price, houseid);
		SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not authorized to use this command.");

	return 1;
}

CMD:gotohouse(playerid, params[]) { // Teleports to the house
	if(Player[playerid][playerAdminLevel] > 0 || IsPlayerAdmin(playerid)) {
		new houseid, text[128];

		if(sscanf(params, "i", houseid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /gotohouse [houseid]");

		if(House[houseid][housePositionX] == 0.0 || House[houseid][houseID] == -1)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid house id!");

		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);

		currenthouseid[playerid] = -1;

		SetPlayerPos(playerid, House[houseid][housePositionX], House[houseid][housePositionY], House[houseid][housePositionZ]);

		format(text, sizeof(text), "Teleported to house %d.", houseid);
		SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not authorized to use this command.");

	return 1;
}

CMD:resethouse(playerid, params[]) { // Resets the house
	new text[128];

	if(Player[playerid][playerAdminLevel] > 0 || IsPlayerAdmin(playerid)) {
		new houseid;

		if(sscanf(params, "i", houseid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /resethouse [houseid]");

		if(House[houseid][housePositionX] == 0.0 || House[houseid][houseID] == -1)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid house id!");

		House[houseid][housePrice] = 0;

		if(House[houseid][houseOwner] != -1) {
			if(Player[playerid][playerHouse1] == House[houseid][houseID])
				Player[playerid][playerHouse1] = -1;
			else if(Player[playerid][playerHouse2] == House[houseid][houseID])
				Player[playerid][playerHouse2] = -1;
			else if(Player[playerid][playerHouse3] == House[houseid][houseID])
				Player[playerid][playerHouse3] = -1;
			else if(Player[playerid][playerHouse4]== House[houseid][houseID])
				Player[playerid][playerHouse4] = -1;

			Player[playerid][playerHouses]--;
		}

		House[houseid][houseOwner] = -1;
		House[houseid][housePrice] = House[houseid][houseOriginalPrice];
		House[houseid][houseGangEnterPerm] = 0;
		House[houseid][houseGangFurniturePerm] = 0;
		House[houseid][houseGangCasePerm] = 0;
		House[houseid][houseGangInventoryPerm] = 0;
		House[houseid][houseSquadEnterPerm] = 0;
		House[houseid][houseSquadFurniturePerm] = 0;
		House[houseid][houseSquadCasePerm] = 0;
		House[houseid][houseSquadInventoryPerm] = 0;
		House[houseid][houseGroupEnterPerm] = 0;
		House[houseid][houseGroupFurniturePerm] = 0;
		House[houseid][houseGroupCasePerm] = 0;
		House[houseid][houseGroupInventoryPerm] = 0;
		House[houseid][houseFriendsEnterPerm] = 0;
		House[houseid][houseFriendsFurniturePerm] = 0;
		House[houseid][houseFriendsCasePerm] = 0;
		House[houseid][houseFriendsInventoryPerm] = 0;

		UpdateHouse(houseid, 1);
		SaveHouse(houseid);

		SaveAccount(playerid);

		format(text, sizeof(text), "House %d has been reset.", houseid);
		SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, text);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not authorized to use this command.");

	return 1;
}

CMD:houseid(playerid, params[]) { // Shows the list of in-game house ids (provide in-game playerid)
	new targetid, text[256];
	if(Player[playerid][playerAdminLevel] > 0 || IsPlayerAdmin(playerid)) {
		if(sscanf(params, "u", targetid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /houseid [playerid]");

		if(IsPlayerConnected(targetid)) {

			new house1 = -1, house2 = -1, house3 = -1, house4 = -1;

			for(new i = 0; i < MAX_HOUSES; i++) {
				if(House[i][houseID] != -1 && House[i][housePositionX] != 0.0) {
					if(House[i][houseOwner] == Player[playerid][playerID]) {
						if(house1 == -1)
							house1 = i;
						else if(house2 == -1)
							house2 = i;
						else if(house3 == -1)
							house3 = i;
						else if(house4 == -1)
							house4 = i;
					}
				}
			}

			if(house1 == -1 && house2 == -1 && house3 == -1 && house4 == -1)
				return SendClientMessage(playerid, COLOR_LIGHTCYAN, "The player does not own any house.");

			format(text, sizeof(text), "House %d\nHouse %d\nHouse %d\nHouse %d", house1, house2, house3, house4);
			strreplace(text, "House -1", "");
			ShowPlayerDialog(playerid, DIALOG_PLAYER_HOUSES, DIALOG_STYLE_LIST, "Player Houses with In - Game IDs", text, "Okay", "");
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "The player is not connected.");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not authorized to use this command.");

	return 1;	
}
 
CMD:housesql(playerid, params[]) { // Shows the list of DB house ids (provide DB playerid)
	new targetsqlid, query[255], query2[255];
	if(Player[playerid][playerAdminLevel] > 0 || IsPlayerAdmin(playerid)) {
		if(sscanf(params, "i", targetsqlid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /housesql [playersqlid]");

		mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `players` WHERE `pid` = '%d'", targetsqlid);
		mysql_tquery(g_SQL, query, "CheckPlayerSQL", "ii", playerid, targetsqlid);

		new sqlchk = GetPVarInt(playerid, "sqlcheck");
		if(sqlchk == 1)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid SQL ID.");

		mysql_format(g_SQL, query2, sizeof(query2), "SELECT * FROM `houses` WHERE `hOwner` = '%d'", targetsqlid);
		mysql_tquery(g_SQL, query2, "OnHouseSQL", "ii", playerid, targetsqlid);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not authorized to use this command.");

	return 1;	
}

// ---------------Player Commands---------------
// -----------------House System----------------
// CMD:buyhouse(playerid, params[]) { // Buys the house
// 	new houseid, text[255];

// 	houseid = GetNearestHouse(playerid);

// 	if(currenthouseid[playerid] == -1 && houseid == -1)
// 		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not near or inside a house.");

// 	if(House[houseid][houseOwner] == Player[playerid][playerID])
// 		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You already bought this house.");

// 	if(House[houseid][housePrice] <= 0)
// 		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "This house is not for sale.");

// 	if(Player[playerid][playerType] == 0) {
// 		if(Player[playerid][playerHouses] == 1)
// 			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You cannot buy more houses. Please donate to the server for more slots.");
// 	}
// 	else if(Player[playerid][playerType] == 1) {
// 		if(Player[playerid][playerHouses] == 3)
// 			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You cannot buy more houses.");
// 	}

// 	if(SafeGetPlayerMoney(playerid) < House[houseid][housePrice])
// 		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You do not have sufficient cash to buy this house.");

// 	currenthousebuyid[playerid] = houseid;

// 	format(text, sizeof(text), "{FFFFFF}This house is for sale for {33AA33}$%d{FFFFFF}.\nAre you sure you want to buy this house?", House[houseid][housePrice]);
// 	ShowPlayerDialog(playerid, DIALOG_BUY_HOUSE, DIALOG_STYLE_MSGBOX, "Buy House", text, "Buy", "Cancel");

// 	return 1;
// }

CMD:sellthesystem(playerid, params[]) { // Sells the house to the system for half price
	new text[128], houseid;

	if(Player[playerid][playerHouses] == 0)
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You do not own any house.");

	houseid = GetNearestHouse(playerid);

	if(houseid == -1 && currenthouseid[playerid] == -1)
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not near or inside a house.");

	if(House[houseid][houseOwner] != Player[playerid][playerID])
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You do not own this house.");

	if(houseid == -1)
		currenthousesellid[playerid] = currenthouseid[playerid];
	else		
		currenthousesellid[playerid] = houseid;
	
	format(text, sizeof(text), "{FFFFFF}Are you sure you want to sell this house to the system for {33AA33}$%d{FFFFFF}?", House[houseid][houseLastPrice]/2);
	ShowPlayerDialog(playerid, DIALOG_SELL_SYSTEM, DIALOG_STYLE_MSGBOX, "Sell to the System", text, "Yes", "No");
	return 1;
}

CMD:sellhouse(playerid, params[]) { // Sells the house to another player
	new targetid, price, houseid, text[128];

	if(sscanf(params, "ui", targetid, price))
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /sellhouse [playerid] [price]");

	houseid = GetNearestHouse(playerid);

	if(houseid == -1 && currenthouseid[playerid] == -1)
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not near or inside a house.");

	if(House[houseid][houseOwner] != Player[playerid][playerID])
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You do not own this house.");

	if(houseid == -1)
		currenthousesellid[playerid] = currenthouseid[playerid];
	else
		currenthousesellid[playerid] = houseid;

	if(SafeGetPlayerMoney(targetid) < price)
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "The player does not have enough cash.");

	if(Player[targetid][playerType] == 0) {
		if(Player[targetid][playerHouses] == 1)
			return SendClientMessage(targetid, COLOR_LIGHTCYAN, "The player cannot buy more houses.");
	}
	else if(Player[targetid][playerType] == 1) {
		if(Player[targetid][playerHouses] == 3)
			return SendClientMessage(targetid, COLOR_LIGHTCYAN, "The player cannot buy more houses.");
	}

	currenthousesellprice[playerid] = price;

	currenthouseselltargetid[playerid] = targetid;

	format(text, sizeof(text), "{FFFFFF}Are you sure you want to sell this house to %s for {33AA33}$%d{FFFFFF}?", Player[targetid][playerName], price);
	ShowPlayerDialog(playerid, DIALOG_SELL_PLAYER, DIALOG_STYLE_MSGBOX, "Sell House", text, "Yes", "No");
	return 1;
}

CMD:permissions(playerid) { // Sets the permissions for other players (entry, money and inventory)
	new houseid, text[255], text2[255], text3[255], text4[255], text5[255], text6[255], query[255], players[512];

	if(currenthouseid[playerid] == -1)
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not inside a house.");

	houseid = currenthouseid[playerid];

	if(House[houseid][houseOwner] != Player[playerid][playerID])
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You do not own this house.");

	format(text, sizeof(text), "Name\tPermissions\nGang\tEnter, Furniture, Case, Inventory");

	if(House[houseid][houseGangEnterPerm] == 0)
		strreplace(text, "Enter,", "");
	else
		strreplace(text, "Enter,", "  Enter,");

	if(House[houseid][houseGangFurniturePerm] == 0)
		strreplace(text, "Furniture,", "");

	if(House[houseid][houseGangCasePerm] == 0)
		strreplace(text, "Case,", "");

	if(House[houseid][houseGangInventoryPerm] == 0)
		strreplace(text, "Inventory", "");

	format(text2, sizeof(text2), "\nSquad\tEnter, Furniture, Case, Inventory");

	if(House[houseid][houseSquadEnterPerm] == 0)
		strreplace(text2, "Enter,", "");
	else
		strreplace(text2, "Enter,", "  Enter,");

	if(House[houseid][houseSquadFurniturePerm] == 0)
		strreplace(text2, "Furniture,", "");

	if(House[houseid][houseSquadCasePerm] == 0)
		strreplace(text2, "Case,", "");

	if(House[houseid][houseSquadInventoryPerm] == 0)
		strreplace(text2, "Inventory", "");

	format(text3, sizeof(text3), "\nGroup\tEnter, Furniture, Case, Inventory");

	if(House[houseid][houseGroupEnterPerm] == 0)
		strreplace(text3, "Enter,", "");
	else
		strreplace(text3, "Enter,", "  Enter,");

	if(House[houseid][houseGroupFurniturePerm] == 0)
		strreplace(text3, "Furniture,", "");

	if(House[houseid][houseGroupCasePerm] == 0)
		strreplace(text3, "Case,", "");

	if(House[houseid][houseGroupInventoryPerm] == 0)
		strreplace(text3, "Inventory", "");

	format(text4, sizeof(text4), "\nFriends\tEnter, Furniture, Case, Inventory");

	if(House[houseid][houseFriendsEnterPerm] == 0)
		strreplace(text4, "Enter,", "");
	else
		strreplace(text4, "Enter,", "  Enter,");

	if(House[houseid][houseFriendsFurniturePerm] == 0)
		strreplace(text4, "Furniture,", "");

	if(House[houseid][houseFriendsCasePerm] == 0)
		strreplace(text4, "Case,", "");

	if(House[houseid][houseFriendsInventoryPerm] == 0)
		strreplace(text4, "Inventory", "");

	strcat(text, text2);
	strcat(text, text3);
	strcat(text, text4);

	format(text5, sizeof(text5), "\n{AA3333}[Add a Player]\n");

	strcat(text, text5);

	mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `permissions` WHERE `hid` = '%d' AND `pid` = '%d'", House[houseid][houseID], Player[playerid][playerID]);
	new Cache:result = mysql_query(g_SQL, query, true);

	for(new i = 0; i < cache_num_rows(); i++)
		cache_get_value_name_int(i, "pid", players[i]);

	for(new i = 0; i < sizeof(players); i++) {
		for(new j = 0; j < MAX_PLAYERS; j++) {
			if(Player[j][playerID] == players[i]) {
				if(IsPlayerConnected(j)) {
					strmid(text6[i], GetName(j), 0, 255, 255);
					strcat(text6[i], "\n");
				}
			}
		}
	}

	strcat(text, text6);

	cache_delete(result);

	ShowPlayerDialog(playerid, DIALOG_PERMISSIONS, DIALOG_STYLE_TABLIST_HEADERS, "Permissions Panel", text, "Okay", "Cancel");

	currenthousepermid[playerid] = houseid;

	return 1;
}

CMD:furniture(playerid, params[]) { // Buys furniture for the house
	new houseid;

	if(currenthouseid[playerid] == -1)
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not inside a house.");

	houseid = currenthouseid[playerid];

	if(House[houseid][houseOwner] != Player[playerid][playerID])
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You do not own this house.");

	ShowPlayerDialog(playerid, DIALOG_FURNITURE, DIALOG_STYLE_LIST, "Buy Furniture", "Chairs\nTables\nKitchen\nDoors\nWalls", "Select", "Cancel");

	return 1;
}

CMD:findhouse(playerid, params[]) { // Places a checkpoint on the house location
	new text[255];

	if(Player[playerid][playerHouses] == 0)
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You do not own any house.");

	new house1 = -1, house2 = -1, house3 = -1, house4 = -1;

	for(new i = 0; i < MAX_HOUSES; i++) {
		if(House[i][houseID] != -1 && House[i][housePositionX] != 0.0) {
			if(House[i][houseOwner] == Player[playerid][playerID]) {
				if(house1 == -1)
					house1 = i;
				else if(house2 == -1)
					house2 = i;
				else if(house3 == -1)
					house3 = i;
				else if(house4 == -1)
					house4 = i;
			}
		}
	}

	format(text, sizeof(text), "House %d\nHouse %d\nHouse %d\nHouse %d", house1, house2, house3, house4);
	strreplace(text, "House -1", "");
	ShowPlayerDialog(playerid, DIALOG_FIND_HOUSE, DIALOG_STYLE_LIST, "Houses", text, "Okay", "");

	return 1;
}

/* /up, /v, /fly, /kill, /gotojob, /goto, /gethere, /arep  - For testing, will be removed later */
CMD:up(playerid, params[]) {
	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(playerid, x, y, z + 8);
	return 1;
}

CMD:v(playerid, params[]) {
	new model, Float:x, Float:y, Float:z, Float:angle;

	sscanf(params, "i", model);

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, angle);

	new vid = CreateVehicle(model, x, y + 8, z, angle, 0, 0, -1);
	PutPlayerInVehicle(playerid, vid, 0);
	return 1;
}

CMD:fly(playerid, params[]) // Makes the player jump in both upward and forward direction
{
		new Float:px, Float:py, Float:pz, Float:pa;
		GetPlayerFacingAngle(playerid,pa);
		if(pa >= 0.0 && pa <= 22.5) //n1
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px, py+30, pz+5);
		}
		if(pa >= 332.5 && pa < 0.0) //n2
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px, py+30, pz+5);
		}
		if(pa >= 22.5 && pa <= 67.5) //nw
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px-15, py+15, pz+5);
		}
		if(pa >= 67.5 && pa <= 112.5) //w
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px-30, py, pz+5);
		}
		if(pa >= 112.5 && pa <= 157.5) //sw
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px-15, py-15, pz+5);
		}
		if(pa >= 157.5 && pa <= 202.5) //s
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px, py-30, pz+5);
		}
		if(pa >= 202.5 && pa <= 247.5)//se
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px+15, py-15, pz+5);
		}
		if(pa >= 247.5 && pa <= 292.5)//e
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px+30, py, pz+5);
		}
		if(pa >= 292.5 && pa <= 332.5)//e
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px+15, py+15, pz+5);
		}
}

CMD:kill(playerid, params[]) {
	SetPlayerHealth(playerid, 0);
	return 1;
}

CMD:gotojob(playerid, params[]) {
	new jobid;

	sscanf(params, "i", jobid);

	SetPlayerPos(playerid, Job[jobid][jobPositionX], Job[jobid][jobPositionY], Job[jobid][jobPositionZ]);
	return 1;
}

CMD:goto(playerid, params[]) {
	new targetid, Float:x, Float:y, Float:z, vehicleid;

	sscanf(params, "u", targetid);

	GetPlayerPos(targetid, x, y, z);

	if(IsPlayerInAnyVehicle(playerid)) {
		vehicleid = GetPlayerVehicleID(playerid);
		SetPlayerPos(playerid, x, y + 3, z);
		PutPlayerInVehicle(playerid, vehicleid, 0);
	}
	else
		SetPlayerPos(playerid, x, y + 3, z);

	return 1;
}

CMD:gethere(playerid, params[]) {
	new targetid, Float:x, Float:y, Float:z, vehicleid;

	sscanf(params, "u", targetid);

	GetPlayerPos(playerid, x, y, z);

	if(IsPlayerInAnyVehicle(targetid)) {
		vehicleid = GetPlayerVehicleID(targetid);
		SetPlayerPos(targetid, x, y + 3, z);
		PutPlayerInVehicle(targetid, vehicleid, 0);
	}
	else
		SetPlayerPos(targetid, x, y + 3, z);
	return 1;
}

CMD:arep(playerid, params[]) {
	new vehicleid = GetPlayerVehicleID(playerid);
	new Float:X, Float:Y, Float:Z;
	
	RepairVehicle(vehicleid);
	
	GetPlayerPos(playerid, X, Y, Z);
	PlayerPlaySound(playerid, 1133, X, Y, Z);
	return 1;
}

// --------------Admin Commands--------------
// ----------------Job System----------------
CMD:createjob(playerid, params[]) {
	new Float:x, Float:y, Float:z, query[255];

	GetPlayerPos(playerid, x, y, z);

	Job[newjobid][jobPositionX] = x;
	Job[newjobid][jobPositionY] = y;
	Job[newjobid][jobPositionZ] = z;

	Job[newjobid][jobPickup] = CreatePickup(1239, 1, x, y, z, 0);

	if(newjobid == 1) // Trucker
		strmid(Job[newjobid][jobName], "Trucker", 0, 128, 128);

	mysql_format(g_SQL, query, sizeof(query), "INSERT INTO `jobs`(`jobname`, `jobpickup`, `jobposx`, `jobposy`, `jobposz`) VALUES ('%e', '%d', '%f', '%f', '%f')", Job[newjobid][jobName], Job[newjobid][jobPickup], x, y, z);
	new Cache:result = mysql_query(g_SQL, query, true);

	Job[newjobid][jobID] = cache_insert_id();

	cache_delete(result);

	SendClientMessage(playerid, COLOR_YELLOW, "Job created.");

	newjobid++;
	return 1;
}

// --------------Player Commands--------------
CMD:market(playerid, params[]) {
	new text[255];

	if(Player[playerid][playerJob] == 1) { // Trucker
		format(text, sizeof(text), "Product\tBuying Price\tSelling Price\nFruits\t$%d\t$%d\nMeal\t$%d\t$%d\nWeapon Parts\t$%d\t$%d\nShoes\t$%d\t$%d\nWeapons\t$%d\t$%d\nAmmo\t$%d\t$%d", fruitsbuyprice, fruitssellprice, mealbuyprice, mealsellprice, weaponpartsbuyprice, weaponpartssellprice, shoesbuyprice, shoessellprice, weaponsbuyprice, weaponssellprice, ammobuyprice, ammosellprice);
		ShowPlayerDialog(playerid, DIALOG_MARKET, DIALOG_STYLE_TABLIST_HEADERS, "Products Market", text, "Okay", "");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not a trucker.");
	return 1;
}

CMD:myrank(playerid, params[]) {
	new text[255];

	if(Player[playerid][playerJob] == 0)
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You do not have a job.");
	else if(Player[playerid][playerJob] == 1) { // Trucker
		format(text, sizeof(text), "Rank\tRank Points\nRank 2\t%d Points\nRank 3\t%d Points\nRank 4\t%d Points\nRank 5\t%d Points", 40 - Player[playerid][playerTruckerRankPoints], 100 - Player[playerid][playerTruckerRankPoints], 150 - Player[playerid][playerTruckerRankPoints], 200 - Player[playerid][playerTruckerRankPoints]);
		ShowPlayerDialog(playerid, DIALOG_RANKS, DIALOG_STYLE_TABLIST_HEADERS, "Ranks", text, "Okay", "");
	}

	return 1;
}

CMD:placetocar(playerid, params[]) { // @TODO Complete this
	if(Player[playerid][playerJob] != 1)
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not a trucker.");

	if(truckercurobj[playerid] == 0)
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You are not carrying any object.");

	new obj = CreateObject(truckercurobj[playerid], 0, 0, 0, 0, 0, 0);

	RemovePlayerAttachedObject(playerid, 0);

	AttachObjectToVehicle(obj, truckervehid[playerid], -0.5, -1, 0, 0, 0, 0);

	ClearAnimations(playerid, 1);
	ClearAnimations(playerid, 1);

	truckercurobj[playerid] = 0;

	SendClientMessage(playerid, COLOR_YELLOW, "Carry the product to the checkpoint and use /takefromcar to take out the product.");
	return 1;
}

CMD:buybox(playerid, params[]) {
	new text[255];

	if(Player[playerid][playerJob] == 1) {

		if(truckerspawned[playerid] == 0) {
			SendClientMessage(playerid, COLOR_YELLOW, "You need to spawn the vehicle before buying the box.");
			SetPlayerCheckpoint(playerid, 2792.4734, -2418.4648, 13.6325, 5.0);
		}

		if(IsPlayerInRangeOfPoint(playerid, 1.5, 2748.6235, -2452.5361, 13.8623)) { // Trucker Buy Box Icon
			isbuyingprod[playerid] = 1;

			format(text, sizeof(text), "Product\tBuying Price\tSelling Price\nFruits\t$%d\t$%d\nMeal\t$%d\t$%d\nWeapon Parts\t$%d\t$%d\nShoes\t$%d\t$%d\nWeapons\t$%d\t$%d\nAmmo\t$%d\t$%d", fruitsbuyprice, fruitssellprice, mealbuyprice, mealsellprice, weaponpartsbuyprice, weaponpartssellprice, shoesbuyprice, shoessellprice, weaponsbuyprice, weaponssellprice, ammobuyprice, ammosellprice);
			ShowPlayerDialog(playerid, DIALOG_MARKET, DIALOG_STYLE_TABLIST_HEADERS, "Buy Box", text, "Okay", "");
		}
		else {
			SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You need to be near the box buying point.");
			SendClientMessage(playerid, COLOR_YELLOW, "Follow the checkpoint to reach the buying point.");
			SetPlayerCheckpoint(playerid, 2748.6235, -2452.5361, 13.8623, 5.0);
		}
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not a trucker.");
	return 1;
}
