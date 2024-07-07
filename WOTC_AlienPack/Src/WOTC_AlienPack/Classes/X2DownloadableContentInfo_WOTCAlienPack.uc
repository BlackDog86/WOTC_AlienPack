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
			   
	// ABILITY EXPAND HERE:

	case 'WARCRY_RADIUS_METERS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.WARCRY_RADIUS_METERS);
		return true;
	case 'WARCRY_DURATION':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.WARCRY_DURATION);
		return true;
	case 'WARCRY_COOLDOWN':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.WARCRY_COOLDOWN);
		return true;
	case 'WARCRY_ACTIONCOST':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.WARCRY_ACTIONCOST);
		return true;
	case 'WARCRY_MUTON_OFFENSE_BONUS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.WARCRY_MUTON_OFFENSE_BONUS);
		return true;
	case 'WARCRY_MUTON_WILL_BONUS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.WARCRY_MUTON_WILL_BONUS);
		return true;
	case 'WARCRY_MUTON_MOBILITY_BONUS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.WARCRY_MUTON_MOBILITY_BONUS);
		return true;
	case 'WARCRY_OTHER_OFFENSE_BONUS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.WARCRY_OTHER_OFFENSE_BONUS);
		return true;
	case 'WARCRY_OTHER_WILL_BONUS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.WARCRY_OTHER_WILL_BONUS);
		return true;
	case 'WARCRY_OTHER_MOBILITY_BONUS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.WARCRY_OTHER_MOBILITY_BONUS);
		return true;
	case 'BAYONETCHARGE_COOLDOWN':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.BAYONETCHARGE_COOLDOWN);
		return true;
	case 'BAYONETCHARGE_PENALTY_DURATION':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.BAYONETCHARGE_PENALTY_DURATION);
		return true;
	case 'BAYONETCHARGE_DEFENSE_PENALTY':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.BAYONETCHARGE_DEFENSE_PENALTY);
		return true;
	case 'PERSONAL_SHIELD_ACTION_COST':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.PERSONAL_SHIELD_ACTION_COST);
		return true;
	case 'PERSONAL_SHIELD_COOLDOWN':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.PERSONAL_SHIELD_COOLDOWN);
		return true;
	case 'PERSONAL_SHIELD_DURATION':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.PERSONAL_SHIELD_DURATION);
		return true;
	case 'PERSONAL_SHIELD_HP':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.PERSONAL_SHIELD_HP);
		return true;
	case 'MASS_MINDSPIN_LW_CONE_END_DIAMETER':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.MASS_MINDSPIN_LW_CONE_END_DIAMETER);
		return true;
	case 'MASS_MINDSPIN_LW_CONE_LENGTH':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.MASS_MINDSPIN_LW_CONE_LENGTH);
		return true;
	case 'MASS_MINDSPIN_TILES_RADIUS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.MASS_MINDSPIN_TILES_RADIUS);
		return true;
	case 'MASS_REANIMATION_LW_MIN_ACTION_COST':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.MASS_REANIMATION_LW_MIN_ACTION_COST);
		return true;
	case 'MASS_REANIMATION_LW_LOCAL_COOLDOWN':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.MASS_REANIMATION_LW_LOCAL_COOLDOWN);
		return true;
	case 'MASS_REANIMATION_LW_GLOBAL_COOLDOWN':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.MASS_REANIMATION_LW_GLOBAL_COOLDOWN);
		return true;
	case 'MASS_REANIMATION_LW_RADIUS_METERS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.MASS_REANIMATION_LW_RADIUS_METERS);
		return true;
	case 'MASS_REANIMATION_LW_RANGE_METERS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.MASS_REANIMATION_LW_RANGE_METERS);
		return true;
	case 'DRONE_REPAIR_ACTION_COST':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.DRONE_REPAIR_ACTION_COST);
		return true;
	case 'DRONE_STUN_HIT_MODIFIER':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.DRONE_STUN_HIT_MODIFIER);
		return true;
	case 'DRONE_STUN_ACTION_POINT_DAMAGE':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.DRONE_STUN_ACTION_POINT_DAMAGE);
		return true;
	case 'STUNNER_COOLDOWN':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.STUNNER_COOLDOWN);
		return true;
	case 'STANDALONE_PINIONS_LOCAL_COOLDOWN':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.STANDALONE_PINIONS_LOCAL_COOLDOWN);
		return true;
	case 'STANDALONE_PINIONS_GLOBAL_COOLDOWN':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.STANDALONE_PINIONS_GLOBAL_COOLDOWN);
		return true;
	case 'STANDALONE_PINIONS_TARGETING_AREA_RADIUS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.STANDALONE_PINIONS_TARGETING_AREA_RADIUS);
		return true;
	case 'STANDALONE_PINIONS_NUM_TARGETS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.STANDALONE_PINIONS_NUM_TARGETS);
		return true;
	case 'STANDALONE_PINIONS_SELECTION_RANGE':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.STANDALONE_PINIONS_SELECTION_RANGE);
		return true;
	case 'STANDALONE_PINIONS_IMPACT_RADIUS_METERS':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.STANDALONE_PINIONS_IMPACT_RADIUS_METERS);
		return true;
	case 'CHRYSSALID_SOLDIER_SLASH_BONUS_DAMAGE':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.CHRYSSALID_SOLDIER_SLASH_BONUS_DAMAGE);
		return true;
	case 'VIPERM2M3_ADDITIONAL_POISON_DAMAGE':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.VIPERM2M3_ADDITIONAL_POISON_DAMAGE);
		return true;
	case 'SIDEWINDER_ADDITIONAL_POISON_DAMAGE':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.SIDEWINDER_ADDITIONAL_POISON_DAMAGE);
		return true;
	case 'NAJA_ADDITIONAL_POISON_DAMAGE':
		OutString = string(class'X2Ability_LWAlienAbilities'.default.NAJA_ADDITIONAL_POISON_DAMAGE);
		return true;
	case 'AREA_SUPPRESSION_AMMO_COS':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.AREA_SUPPRESSION_AMMO_COST);
		return true;
	case 'AREA_SUPPRESSION_MAX_SHOTS':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.AREA_SUPPRESSION_MAX_SHOTS);
		return true;
	case 'AREA_SUPPRESSION_SHOT_AMMO_COST':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.AREA_SUPPRESSION_SHOT_AMMO_COST);
		return true;
	case 'AREA_SUPPRESSION_RADIUS':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.AREA_SUPPRESSION_RADIUS);
		return true;
	case 'WILLTOSURVIVE_WILLBONUS':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.WILLTOSURVIVE_WILLBONUS);
		return true;
	case 'DAMAGE_CONTROL_BONUS_ARMOR':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.DAMAGE_CONTROL_BONUS_ARMOR);
		return true;
	case 'AREA_SUPPRESSION_LW_SHOT_AIM_BONUS':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.AREA_SUPPRESSION_LW_SHOT_AIM_BONUS);
		return true;
	case 'DANGER_ZONE_BONUS_RADIUS':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.DANGER_ZONE_BONUS_RADIUS);
		return true;
	case 'PERSONAL_SHIELD_XCOM_DURATION':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.PERSONAL_SHIELD_XCOM_DURATION);
		return true;
	case 'PERSONAL_SHIELD_XCOM_HP':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.PERSONAL_SHIELD_XCOM_HP);
		return true;
	case 'GUARDIAN_PROC_CHANCE':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.GUARDIAN_PROC_CHANCE);
		return true;
	case 'SENTINEL_PROC_CHANCE':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.SENTINEL_PROC_CHANCE);
		return true;
	case 'CCS_AMMO_PER_SHOT':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.CCS_AMMO_PER_SHOT);
		return true;
	case 'CCS_RANGE':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.CCS_RANGE);
		return true;
	case 'CCS_PROC_ON_OWN_TURN':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.CCS_PROC_ON_OWN_TURN);
		return true;
	case 'AGGRESSION_CRIT_BONUS_PER_ENEMY':
		OutString = string(class'X2Effect_Aggression'.default.AGGRESSION_CRIT_BONUS_PER_ENEMY);
		return true;
	case 'AGGRESSION_MAX_CRIT_BONUS':
		OutString = string(class'X2Effect_Aggression'.default.AGGRESSION_MAX_CRIT_BONUS);
		return true;
	case 'AGG_SQUADSIGHT_ENEMIES_APPLY':
		OutString = string(class'X2Effect_Aggression'.default.AGG_SQUADSIGHT_ENEMIES_APPLY);
		return true;
	case 'BEO_BONUS_CRIT_DAMAGE_PER_ENEMY':
		OutString = string(class'X2Effect_BringEmOn'.default.BEO_BONUS_CRIT_DAMAGE_PER_ENEMY);
		return true;
	case 'BEO_MAX_BONUS_CRIT_DAMAGE':
		OutString = string(class'X2Effect_BringEmOn'.default.BEO_MAX_BONUS_CRIT_DAMAGE);
		return true;
	case 'BEO_SQUADSIGHT_ENEMIES_APPLY':
		OutString = string(class'X2Effect_BringEmOn'.default.BEO_SQUADSIGHT_ENEMIES_APPLY);
		return true;
	case 'APPLIES_TO_EXPLOSIVES':
		OutString = string(class'X2Effect_BringEmOn'.default.APPLIES_TO_EXPLOSIVES);
		return true;
	case 'CRITBOOST':
		OutString = string(class'X2Effect_CloseandPersonal'.default.CRITBOOST[0]);
		return true;
	case 'DEFILADE_DEFENSE_BONUS':
		OutString = string(class'X2Effect_Defilade'.default.DEFILADE_DEFENSE_BONUS);
		return true;
	case 'HT_DODGE_BONUS_PER_ENEMY':
		OutString = string(class'X2Effect_HardTarget'.default.HT_DODGE_BONUS_PER_ENEMY);
		return true;
	case 'HT_MAX_DODGE_BONUS':
		OutString = string(class'X2Effect_HardTarget'.default.HT_MAX_DODGE_BONUS);
		return true;
	case 'HT_SQUADSIGHT_ENEMIES_APPLY':
		OutString = string(class'X2Effect_HardTarget'.default.HT_SQUADSIGHT_ENEMIES_APPLY);
		return true;
	case 'AREA_SUPPRESSION_SHOT_AMMO_COST':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.AREA_SUPPRESSION_SHOT_AMMO_COST);
		return true;
	case 'DGG_AIM_BONUS':
		OutString = string(class'X2Effect_DamnGoodGround'.default.DGG_AIM_BONUS);
		return true;
	case 'DGG_DEF_BONUS':
		OutString = string(class'X2Effect_DamnGoodGround'.default.DGG_DEF_BONUS);
		return true;
	case 'DP_AIM_BONUS':
		OutString = string(class'X2Effect_DepthPerception'.default.DP_AIM_BONUS);
		return true;
	case 'DP_ANTIDODGE_BONUS':
		OutString = string(class'X2Effect_DepthPerception'.default.DP_ANTIDODGE_BONUS);
		return true;
	case 'EXECUTIONER_AIM_BONUS':
		OutString = string(class'X2Effect_Executioner_AP'.default.EXECUTIONER_AIM_BONUS);
		return true;
	case 'EXECUTIONER_CRIT_BONUS':
		OutString = string(class'X2Effect_Executioner_AP'.default.EXECUTIONER_CRIT_BONUS);
		return true;
	case 'INFIGHTER_DODGE_BONUS':
		OutString = string(class'X2Effect_Infighter'.default.INFIGHTER_DODGE_BONUS);
		return true;
	case 'INFIGHTER_MAX_TILES':
		OutString = string(class'X2Effect_Infighter'.default.INFIGHTER_MAX_TILES);
		return true;
	case 'LR_LW_FIRST_SHOT_PENALTY':
		OutString = string(class'X2Effect_LightningReflexes_LW'.default.LR_LW_FIRST_SHOT_PENALTY);
		return true;
	case 'LR_LW_PENALTY_REDUCTION_PER_SHOT':
		OutString = string(class'X2Effect_LightningReflexes_LW'.default.LR_LW_PENALTY_REDUCTION_PER_SHOT);
		return true;
	case 'LOCKEDON_AIM_BONUS':
		OutString = string(class'X2Effect_LockedOn'.default.LOCKEDON_AIM_BONUS);
		return true;
	case 'LOCKEDON_CRIT_BONUS':
		OutString = string(class'X2Effect_LockedOn'.default.LOCKEDON_CRIT_BONUS);
		return true;
	case 'TACTICAL_SENSE_DEF_BONUS_PER_ENEMY':
		OutString = string(class'X2Effect_TacticalSense'.default.TACTICAL_SENSE_DEF_BONUS_PER_ENEMY);
		return true;
	case 'TACTICAL_SENSE_MAX_DEF_BONUS':
		OutString = string(class'X2Effect_TacticalSense'.default.TACTICAL_SENSE_MAX_DEF_BONUS);
		return true;
	case 'TF_USES_PER_TURN':
		OutString = string(class'X2Effect_TraverseFire'.default.TF_USES_PER_TURN);
		return true;
	case 'LONEWOLF_AIM_PER_TILE':
		OutString = string(class'X2Effect_LoneWolf'.default.LONEWOLF_AIM_PER_TILE);
		return true;
	case 'LONEWOLF_DEF_PER_TILE':
		OutString = string(class'X2Effect_LoneWolf'.default.LONEWOLF_DEF_PER_TILE);
		return true;
	case 'LONEWOLF_AIM_BONUS':
		OutString = string(class'X2Effect_LoneWolf'.default.LONEWOLF_AIM_BONUS);
		return true;
	case 'LONEWOLF_DEF_BONUS':
		OutString = string(class'X2Effect_LoneWolf'.default.LONEWOLF_DEF_BONUS);
		return true;
	case 'LONEWOLF_CRIT_BONUS':
		OutString = string(class'X2Effect_LoneWolf'.default.LONEWOLF_CRIT_BONUS);
		return true;
	case 'LONEWOLF_MIN_DIST_TILES':
		OutString = string(class'X2Effect_LoneWolf'.default.LONEWOLF_MIN_DIST_TILES);
		return true;
	case 'W2S_HIGH_COVER_ARMOR_BONUS':
		OutString = string(class'X2Effect_WilltoSurvive'.default.W2S_HIGH_COVER_ARMOR_BONUS);
		return true;
	case 'W2S_LOW_COVER_ARMOR_BONUS':
		OutString = string(class'X2Effect_WilltoSurvive'.default.W2S_LOW_COVER_ARMOR_BONUS);
		return true;
	case 'FIREDISCIPLINE_REACTIONFIRE_BONUS':
		OutString = string(class'X2Effect_FireDiscipline'.default.FIREDISCIPLINE_REACTIONFIRE_BONUS);
		return true;
	case 'EVASIVE_DODGE_BONUS':
		OutString = string(class'X2Ability_PPAlienAbilities'.default.EVASIVE_DODGE_BONUS);
		return true;
		default:
            return false;
    }
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

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local X2AbilityTemplateManager	AbilityTemplateManager;
	local AbilitySetupData			NewSetupData;
	local XComGameState_Item		WeaponState;
	local X2WeaponTemplate			WeaponTemplate;
	local X2AbilityTemplate			PinionsAbilityTemplate;
		
	if (UnitState.HasAbilityFromAnySource('StandalonePinionsAbility'))
	{
		AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
		PinionsAbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('StandalonePinionsStage2');
		WeaponState = UnitState.GetItemInSlot(eInvSlot_TertiaryWeapon);
		if (WeaponState != none)
		{
			WeaponTemplate = X2WeaponTemplate(WeaponState.GetMyTemplate());
			if (WeaponTemplate != none)
			{
				NewSetupData.TemplateName = 'StandalonePinionsStage2';
				NewSetupData.Template = PinionsAbilityTemplate;
				NewSetupData.SourceWeaponRef = WeaponState.GetReference();

				`APTRACE("Updating pinions ability to unit: " @ UnitState.GetFullName() @ "weapon: " @ WeaponTemplate.DataName @ "in slot: " @ WeaponState.InventorySlot,, 'BD');
				
				SetupData.AddItem(NewSetupData);
			}
		}
		`APTRACE("No weapon in tertiary slot or weaponstate doesn't exist!");
	}
	`APTRACE("Ability template doesn't exist on unit!");
}