//---------------------------------------------------------------------------------------
//  FILE:    X2DownloadableContentInfo_LWAlienPack.uc
//  AUTHOR:  Amineri / Long War Studios
//  PURPOSE: Initializes AlienPack mod settings on campaign start or when loading campaign without mod previously active
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_WOTCAlienPack extends X2DownloadableContentInfo config(WOTC_AlienPack);

`include(WOTC_AlienPack\Src\WOTC_AlienPack.uci)

var config array<name> droneNames;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed. When a new campaign is started the initial state of the world
/// is contained in a strategy start state. Never add additional history frames inside of InstallNewCampaign, add new state objects to the start state
/// or directly modify start state objects
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
}

/// <summary>
/// This method is run when the player loads a saved game directly into Strategy while this DLC is installed
/// </summary>
static event OnLoadedSavedGameToStrategy()
{

}

/// <summary>
/// Called after the player exits the post-mission sequence while this DLC / Mod is installed.
/// </summary>
static event OnExitPostMissionSequence()
{
}


/// <summary>
/// Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
/// </summary>
static event OnPostTemplatesCreated()
{
	UpdateForAreaSuppression();
	`APDEBUG("ALIEN PACK VERSION 1.0");
}

static function UpdateForAreaSuppression()
{
	local X2AbilityTemplateManager			AbilityTemplateManager;
	local X2AbilityTemplate					AbilityTemplate;
	local X2Condition						Condition;
	local X2Condition_UnitEffects           SuppressedCondition;
	local X2Condition_UnitProperty			UnitProperty;
	local name								AbilityName;
	local X2Effect							AbilityTargetEffect;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	foreach class'LWAlienPack_Utilities'.default.AREA_SUPPRESSION_EXCLUDE_ABILITIES(AbilityName)
	{
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityName);
		if(AbilityTemplate != none)
		{
			foreach AbilityTemplate.AbilityShooterConditions(Condition)
			{
				SuppressedCondition = X2Condition_UnitEffects(Condition);
				if(SuppressedCondition != none)
				{
					if(SuppressedCondition.ExcludeEffects.Find('EffectName', class'X2Effect_Suppression'.default.EffectName) != -1)
					{
						//found the correct condition, so add the new exclude condition
						`APDEBUG("Updating " $ AbilityName $ " for AreaSuppression Exclusion");
						SuppressedCondition.AddExcludeEffect(class'X2Effect_AreaSuppression'.default.EffectName, 'AA_UnitIsSuppressed');
					}
				}
			}
		}
	}

	// fix for ChryssalidSlash attempt to apply poison to non-units, which results in a CTD
	AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('ChryssalidSlash');
	if (AbilityTemplate != none)
	{
		foreach AbilityTemplate.AbilityTargetEffects(AbilityTargetEffect)
		{
			if (AbilityTargetEffect.IsA('X2Effect_ParthenogenicPoison'))
			{
				foreach AbilityTargetEffect.TargetConditions(Condition)
				{
					UnitProperty = X2Condition_UnitProperty(Condition);
					if (UnitProperty != none)
					{
						UnitProperty.FailOnNonUnits = true;
						break;
					}
				}
			}
		}
	}
}

static function bool AbilityTagExpandHandler_CH(string InString, out string OutString, Object ParseObj, Object StrategyParseObj, XComGameState GameState)
{
	local XComGameState_Ability AbilityState;
	local XComGameState_Effect EffectState;
	local X2AbilityTemplate AbilityTemplate;
	local X2ItemTemplate ItemTemplate;
	local name Type;
	
    Type = name(InString);
    switch(Type)
    {
		case 'BOUND_WEAPON_NAME':
			AbilityTemplate = X2AbilityTemplate(ParseObj);
			if (StrategyParseObj != none && AbilityTemplate != none)
			{
				ItemTemplate = GetItemBoundToAbilityFromUnit(XComGameState_Unit(StrategyParseObj), AbilityTemplate.DataName, GameState);
			}
			else
			{
				AbilityState = XComGameState_Ability(ParseObj);
				EffectState = XComGameState_Effect(ParseObj);
				if (EffectState != none)
				{
					AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(
							EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
				}

				if (AbilityState != none)
					ItemTemplate = AbilityState.GetSourceWeapon().GetMyTemplate();
			}

			if (ItemTemplate != none)
			{
				OutString = ItemTemplate.GetItemAbilityDescName();
				return true;
			}
			OutString = AbilityTemplate.LocDefaultPrimaryWeapon;
			return true;        
		case 'DEFILADE_DEFENSE_BONUS':
			OutString = string(class'X2Effect_Defilade'.default.DEFILADE_DEFENSE_BONUS);
			return true;	
		case 'FIREDISCIPLINE_REACTIONFIRE_BONUS':
			OutString = string(class'X2Effect_FireDiscipline'.default.FIREDISCIPLINE_REACTIONFIRE_BONUS);
			return true;	
		case 'LONEWOLF_MIN_BONUS_TILES':
			OutString = string(class'X2Effect_LoneWolf'.default.LONEWOLF_MIN_DIST_TILES - 
					(class'X2Effect_LoneWolf'.default.LONEWOLF_AIM_BONUS / class'X2Effect_LoneWolf'.default.LONEWOLF_AIM_PER_TILE) + 1);
			return true;
		case 'LONEWOLF_AIM_BONUS':
			OutString = string(class'X2Effect_LoneWolf'.default.LONEWOLF_AIM_BONUS);
			return true;
		case 'LONEWOLF_DEF_BONUS':
			OutString = string(class'X2Effect_LoneWolf'.default.LONEWOLF_DEF_BONUS);
			return true;
		case 'LONEWOLF_MIN_DIST_TILES':
			OutString = string(class'X2Effect_LoneWolf'.default.LONEWOLF_MIN_DIST_TILES);				
			return true;
		default:
            return false;
    }
    return false;    
}

static function X2ItemTemplate GetItemBoundToAbilityFromUnit(XComGameState_Unit UnitState, name AbilityName, XComGameState GameState)
{
	local SCATProgression Progression;

	Progression = UnitState.GetSCATProgressionForAbility(AbilityName);
	if (Progression.iRank == INDEX_NONE || Progression.iBranch == INDEX_NONE)
		return none;

	return UnitState.GetItemInSlot(
		UnitState.AbilityTree[Progression.iRank].Abilities[Progression.iBranch].ApplyToWeaponSlot,
		GameState).GetMyTemplate();
}

