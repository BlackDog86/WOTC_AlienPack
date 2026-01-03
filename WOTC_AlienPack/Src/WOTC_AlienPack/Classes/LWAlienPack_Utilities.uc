//--------------------------------------------------------------------------------------- 
//  FILE:    LWAlienPack_Utilities.uc
//  AUTHOR:  Amineri (Pavonis Interactive)
//  PURPOSE: Utility Data for LW AlienPack
//--------------------------------------------------------------------------------------- 
class LWAlienPack_Utilities extends Object config(WOTC_AlienPack);

`include(WOTC_AlienPack\Src\WOTC_AlienPack.uci)

var config bool SUPPRESSDEBUG;
var config bool SUPPRESSTRACE;
var config array<name> AREA_SUPPRESSION_EXCLUDE_ABILITIES;

static final function bool IsUnitInterruptingEnemyTurn(XComGameState_Unit UnitState)
{
	local XComGameState_BattleData BattleState;

	BattleState = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	return BattleState.InterruptingGroupRef == UnitState.GetGroupMembership().GetReference();
}