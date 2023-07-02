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


