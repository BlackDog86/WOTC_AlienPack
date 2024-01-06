//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_LWAlienAbilities
//  AUTHOR:  Amineri / John Lumpkin (Pavonis Interactive)
//  PURPOSE: Defines alienpack ability templates
//---------------------------------------------------------------------------------------

class X2Ability_LWAlienAbilities extends X2Ability config(WOTC_AlienPack);

var config float WARCRY_RADIUS_METERS;
var config int WARCRY_DURATION;
var config int WARCRY_COOLDOWN;
var config int WARCRY_ACTIONCOST;
var config int WARCRY_MUTON_OFFENSE_BONUS;
var config int WARCRY_MUTON_WILL_BONUS;
var config int WARCRY_MUTON_MOBILITY_BONUS;
var config int WARCRY_OTHER_OFFENSE_BONUS;
var config int WARCRY_OTHER_WILL_BONUS;
var config int WARCRY_OTHER_MOBILITY_BONUS;
var config int BAYONET_COOLDOWN;
var config int BAYONETCHARGE_PENALTY_DURATION;
var config int BAYONETCHARGE_DEFENSE_PENALTY;
var config array <string> WARCRY_MUTON_BONUS;
var config array <string> WARCRY_OTHER_BONUS;
var config float MASS_MINDSPIN_TILES_RADIUS;

var config int PERSONAL_SHIELD_COOLDOWN;
var config int PERSONAL_SHIELD_DURATION;
var config int PERSONAL_SHIELD_HP;
var config int PERSONAL_SHIELD_ACTION_COST;

var config float MASS_MINDSPIN_LW_CONE_END_DIAMETER;
var config float MASS_MINDSPIN_LW_CONE_LENGTH;

var config int MASS_REANIMATION_LW_MIN_ACTION_COST;
var config int MASS_REANIMATION_LW_LOCAL_COOLDOWN;
var config int MASS_REANIMATION_LW_GLOBAL_COOLDOWN;
var config int MASS_REANIMATION_LW_RADIUS_METERS;
var config int MASS_REANIMATION_LW_RANGE_METERS;

var config int DRONE_REPAIR_ACTION_COST;
var config int DRONE_STUN_HIT_MODIFIER;
var config int DRONE_STUN_ACTION_POINT_DAMAGE;
var config int STUNNER_COOLDOWN;

var config int CHRYSSALID_SOLDIER_SLASH_BONUS_DAMAGE;
var config int HIVE_QUEEN_SLASH_BONUS_DAMAGE;

var config int STANDALONE_PINIONS_LOCAL_COOLDOWN;
var config int STANDALONE_PINIONS_GLOBAL_COOLDOWN;
var config int STANDALONE_PINIONS_TARGETING_AREA_RADIUS;
var config int STANDALONE_PINIONS_NUM_TARGETS;
var config int STANDALONE_PINIONS_SELECTION_RANGE;
var config int STANDALONE_PINIONS_IMPACT_RADIUS_METERS;

var config int VIPERM2M3_ADDITIONAL_POISON_DAMAGE;
var config int SIDEWINDER_ADDITIONAL_POISON_DAMAGE;
var config int NAJA_ADDITIONAL_POISON_DAMAGE;

var localized string strBayonetChargePenalty;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.AddItem(CreateMutonM2_LWAbility_Beastmaster());
	Templates.AddItem(CreateMutonM2_LWAbility_BayonetCharge());
	Templates.AddItem(CreateMutonM2_LWAbility_WarCry());	
	Templates.AddItem(CreateDroneShockAbility());
	Templates.AddItem(CreateDroneRepairAbility());
	Templates.AddItem(AddDroneMeleeStun());
	Templates.AddItem(CreateAdventGrenadeLauncherAbility());
	Templates.AddItem(CreateMassMindSpinAbility());
	Templates.AddItem(CreatePersonalShieldAbility());
	Templates.AddItem(CreateMassReanimateAbility());
	Templates.AddItem(CreateReadyForAnythingAbility());
	Templates.AddItem(ReadyForAnythingFlyover());
	Templates.AddItem(CreateChryssalidSoldierSlashAbility());
	Templates.AddItem(AddHitandSlitherAbility());	
	Templates.AddItem(AddFireOnDeathAbility());
	Templates.AddItem(StandalonePinionsAbility());
	Templates.AddItem(StandalonePinionsStage1Ability());
	Templates.AddItem(StandalonePinionsStage2Ability());
	Templates.AddItem(CreateLostBladestormAttack());
	Templates.AddItem(CreateLostBladestorm());
	Templates.AddItem(BD_RocketLauncherAbility());
	Templates.AddItem(CreateLWViperPoisonSpitAbilities());
	return Templates;
}

static function X2AbilityTemplate CreateMutonM2_LWAbility_BeastMaster()
{
	local X2AbilityTemplate					Template;
	local X2AbilityTargetStyle				TargetStyle;
	local X2AbilityTrigger					Trigger;
	local X2Effect_BeastMaster				BeastMasterEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_Beastmaster_LW');
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///Texture2D'UILibrary_BD_LWAlienPack.LWCenturion_AbilityBeastmaster64'";
	Template.AbilityToHitCalc = default.DeadEye;
	TargetStyle = new class 'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;
	Trigger = new class 'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	BeastMasterEffect = new class'X2Effect_BeastMaster';
	BeastMasterEffect.BuildPersistentEffect (1, true, false);
		//BuildPersistentEffect(int _iNumTurns, optional bool _bInfiniteDuration, optional bool _bRemoveWhenSourceDies, optional bool _bIgnorePlayerCheckOnTick, optional XComGameStateContext_TacticalGameRule.GameRuleStateChange _WatchRule)
	BeastMasterEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
		//SetDisplayInfo(X2TacticalGameRulesetDataStructures.EPerkBuffCategory BuffCat, string strName, string strDesc, string strIconLabel, optional bool DisplayInUI, optional string strStatusIcon, optional name opAbilitySource)

	Template.AddTargetEffect(BeastMasterEffect);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}

static function X2AbilityTemplate CreateMutonM2_LWAbility_BayonetCharge()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityToHitCalc_StandardMelee	StandardMelee;
	local X2Effect_ApplyWeaponDamage		WeaponDamageEffect;
	
	local X2Effect_ImmediateAbilityActivation ImpairingAbilityEffect;
	local X2Effect_PersistentStatChange		StatEffect;
	local XGParamTag						kTag;
	local string							strPenalty;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_Bayonetcharge_LW');
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///Texture2D'UILibrary_BD_LWAlienPack.LWCenturion_AbilityBayonetCharge64'";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bfreeCost = false;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	StatEffect = new class'X2Effect_PersistentStatChange';

	kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	if (kTag != none)
	{
		kTag.IntValue0 = default.BAYONETCHARGE_PENALTY_DURATION;
		kTag.IntValue1 = default.BAYONETCHARGE_DEFENSE_PENALTY;
		strPenalty = `XEXPAND.ExpandString(default.strBayonetChargePenalty);
	} else {
		strPenalty = "Placeholder Centurion penalty (no XGParamTag)";
	}
	StatEffect.BuildPersistentEffect(default.BAYONETCHARGE_PENALTY_DURATION, false, true, false, eGameRule_PlayerTurnEnd);
	//StatEffect.SetDisplayInfo (ePerkBuff_Penalty, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName); // adjust
	StatEffect.SetDisplayInfo (ePerkBuff_Penalty, Template.LocFriendlyName, strPenalty, Template.IconImage,,, Template.AbilitySourceName); // adjust
	StatEffect.DuplicateResponse = eDupe_Refresh;
	StatEffect.AddPersistentStatChange (eStat_Defense, float (default.BAYONETCHARGE_DEFENSE_PENALTY));
	Template.AddShooterEffect(StatEffect);

	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = StandardMelee;
	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	//Effect on a successful melee attack is triggering the Apply Impairing Effect Ability
	ImpairingAbilityEffect = new class 'X2Effect_ImmediateAbilityActivation';
	ImpairingAbilityEffect.BuildPersistentEffect(1, false, true, , eGameRule_PlayerTurnBegin);
	ImpairingAbilityEffect.EffectName = 'ImmediateStunImpair';
	ImpairingAbilityEffect.AbilityName = class'X2Ability_Impairing'.default.ImpairingAbilityName;
	ImpairingAbilityEffect.bRemoveWhenTargetDies = true;
	ImpairingAbilityEffect.VisualizationFn = class'X2Ability_Impairing'.static.ImpairingAbilityEffectTriggeredVisualization;
	Template.AddTargetEffect(ImpairingAbilityEffect);

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(WeaponDamageEffect);
	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;

	Template.BuildNewGameStateFn = BayonetCharge_BuildGameState;
	Template.BuildInterruptGameStateFn = class'X2Ability_DefaultAbilitySet'.static.MoveAbility_BuildInterruptGameState;

	Template.CinescriptCameraType = "Muton_Punch";
	
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.MeleeLostSpawnIncreasePerUse;

	return Template;

}

simulated function XComGameState BayonetCharge_BuildGameState(XComGameStateContext context)
{
	local XComGameState NewGameState;

	NewGameState = class'X2Ability_DefaultAbilitySet'.static.MoveAbility_BuildGameState(context);
	TypicalAbility_FillOutGameState(NewGameState);
	return NewGameState;
}


static function X2AbilityTemplate CreateMutonM2_LWAbility_WarCry()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCooldown					Cooldown;
	local X2Condition_UnitProperty			MultiTargetProperty;
	local X2Effect_WarCry					StatEffect;
	local X2AbilityTargetStyle				TargetStyle;
	local X2AbilityMultiTarget_Radius		RadiusMultiTarget;
	local int								i;
	local string							AlienName;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_WarCry_LW');
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.IconImage = "img:///Texture2D'UILibrary_BD_LWAlienPack.LWCenturion_AbilityWarCry64'";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.WARCRY_ACTIONCOST;
	ActionPointCost.bfreeCost = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.WARCRY_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.Deadeye;

	TargetStyle = new class 'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.WARCRY_RADIUS_METERS;
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AddShooterEffectExclusions();

	MultiTargetProperty = new class'X2Condition_UnitProperty';
	MultiTargetProperty.ExcludeAlive = false;
	MultiTargetProperty.ExcludeDead = true;
	MultiTargetProperty.ExcludeHostileToSource = true;
	MultiTargetProperty.ExcludeFriendlyToSource = false;
	MultiTargetProperty.RequireSquadmates = true;
	MultiTargetProperty.ExcludePanicked = true;
	MultiTargetProperty.ExcludeRobotic = true;
	MultiTargetProperty.ExcludeStunned = true;

	Template.AbilityMultiTargetConditions.AddItem(MultiTargetProperty);

	StatEffect = new class'X2Effect_WarCry';

	StatEffect.BuildPersistentEffect(default.WARCRY_DURATION, false, true, false, eGameRule_PlayerTurnEnd);
	//StatEffect.SetDisplayInfo (ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName); // adjust
	StatEffect.SetDisplayInfo (ePerkBuff_Bonus, Template.LocFriendlyName, class'X2Effect_WarCry'.default.strWarCryFriendlyDesc, Template.IconImage,,, Template.AbilitySourceName);

	StatEffect.DuplicateResponse = eDupe_Refresh;

	ForEach default.WARCRY_MUTON_BONUS (AlienName, i)
	{
		StatEffect.AddCharacterNameHigh (name(AlienName));
	}
	ForEach default.WARCRY_OTHER_BONUS (AlienName, i)
	{
		StatEffect.AddCharacterNameLow (name(AlienName));
	}

	StatEffect.AddPersistentStatChange (eStat_Offense, float (default.WARCRY_MUTON_OFFENSE_BONUS), true);
	StatEffect.AddPersistentStatChange (eStat_Mobility, float (default.WARCRY_MUTON_MOBILITY_BONUS), true);
	StatEffect.AddPersistentStatChange (eStat_Will, float (default.WARCRY_MUTON_WILL_BONUS), true);

	StatEffect.AddPersistentStatChange (eStat_Offense, float (default.WARCRY_OTHER_OFFENSE_BONUS), false);
	StatEffect.AddPersistentStatChange (eStat_Mobility, float (default.WARCRY_OTHER_MOBILITY_BONUS), false);
	StatEffect.AddPersistentStatChange (eStat_Will, float (default.WARCRY_OTHER_WILL_BONUS), false);

	//Template.AddShooterEffect(StatEffect); This would make Centurion gain bonuses from own War Cry
	Template.AddMultiTargetEffect(StatEffect);

	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = WarCry_BuildVisualization;
	return Template;
}

function WarCry_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory				History;
	local XComGameStateContext_Ability		context;
	local StateObjectReference				InteractingUnitRef;
	local VisualizationActionMetadata		EmptyTrack, BuildTrack, TargetTrack;
	local X2Action_PlayAnimation			PlayAnimationAction;
	local X2Action_PlaySoundAndFlyOver		SoundAndFlyover, SoundAndFlyoverTarget;
	local XComGameState_Ability				Ability;
	local XComGameState_Effect				EffectState;
	local XComGameState_Unit				UnitState;

	History = `XCOMHISTORY;
	context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	Ability = XComGameState_Ability(History.GetGameStateForObjectID(context.InputContext.AbilityRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1));
	InteractingUnitRef = context.InputContext.SourceObject;
	BuildTrack = EmptyTrack;
	BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	BuildTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	SoundAndFlyover = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(BuildTrack, context, false, BuildTrack.LastActionAdded));
	SoundAndFlyover.SetSoundAndFlyOverParameters(none, Ability.GetMyTemplate().LocFlyOverText, 'None', eColor_Alien);

	PlayAnimationAction = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(BuildTrack, context, false, BuildTrack.LastActionAdded));
	PlayAnimationAction.Params.AnimName = 'HL_WarCry';
	PlayAnimationAction.bFinishAnimationWait = true;

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Effect', EffectState)
	{
		if (EffectState.GetX2Effect().EffectName == class'X2Effect_WarCry'.default.EffectName)
		{
				TargetTrack = EmptyTrack;
				UnitState = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
				if ((UnitState != none) && (EffectState.StatChanges.Length > 0))
				{
					TargetTrack.StateObject_NewState = UnitState;
					TargetTrack.StateObject_OldState = History.GetGameStateForObjectID(UnitState.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
					TargetTrack.VisualizeActor = UnitState.GetVisualizer();
					SoundandFlyoverTarget = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(TargetTrack, context, false, TargetTrack.LastActionAdded));
					SoundandFlyoverTarget.SetSoundAndFlyOverParameters(none, Ability.GetMyTemplate().LocFlyOverText, 'None', eColor_Alien);
				}
		}
	}

}


static function X2AbilityTemplate CreateDroneShockAbility()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2Effect_ApplyWeaponDamage		PhysicalDamageEffect;
	local X2Effect_Persistent               DisorientedEffect;
	local X2Condition_Visibility            VisibilityCondition;
	local X2AbilityTarget_Single            SingleTarget;
	local array<name>                       SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_DroneShock_LW');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_lightningfield";
	Template.Hostility = eHostility_Offensive;
	Template.AbilitySourceName = 'eAbilitySource_Standard';

	// Activated by a button press; additionally, tells the AI this is an activatable
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Targeting Details
	// Can only shoot visible enemies
	VisibilityCondition = new class'X2Condition_Visibility';
	VisibilityCondition.bRequireGameplayVisible = true;
	Template.AbilityTargetConditions.AddItem(VisibilityCondition);
	// Can't target dead; Can't target friendlies
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	// Only at single targets that are in range.
	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;

	// Action Point
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());

	// Impairing effects need to come before the damage. This is needed for proper visualization ordering.
	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();
	DisorientedEffect.bRemoveWhenSourceDies = false;
	Template.AddTargetEffect(DisorientedEffect);

	//ALTERNATIVE : add the impairing as a bonus weapon effect so it can be different on different tier weapons -- see sword disorient/burning effects for examples
	Template.bAllowBonusWeaponEffects = true;

	// Damage Effect
	PhysicalDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(PhysicalDamageEffect);

	// Hit Calculation (Different weapons now have different calculations for range)
	Template.AbilityToHitCalc = default.SimpleStandardAim;
	Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;

	// Targeting Method
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	Template.AssociatedPassives.AddItem('HoloTargeting');

	Template.CustomFireAnim = 'NO_ArcStun';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	return Template;
}

static function X2DataTemplate CreateDroneRepairAbility()
{
	local X2AbilityTemplate							Template;
	local X2AbilityCost_ActionPoints				ActionPointCost;
	local X2Effect_RemoveEffectsByDamageType		RemoveEffects;
	local X2Condition_UnitProperty					UnitPropertyCondition;
	local X2Effect_SimpleHeal						RepairEffect;
	local X2Condition_Visibility					TargetVisibilityCondition;
	local X2AbilityTarget_Single					SingleTarget;
	local X2AbilityCooldown							Cooldown;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'BD_DroneRepair_LW');
	Template.IconImage = "img:///UILibrary_BD_LWAlienPack.LW_AbilityDroneRepair"; //from old EW Repair Servos icon
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Only at single targets that are in range.
	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.DRONE_REPAIR_ACTION_COST;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 1; // just to prevent from triggering twice in a turn
	Template.AbilityCooldown = Cooldown;

	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	Template.bCrossClassEligible = false;
	Template.bDisplayInUITooltip = true;
	Template.bDisplayInUITacticalText = true;
	Template.bShowActivation = true;
	Template.DisplayTargetHitChance = false;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeHostileToSource = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeFullHealth = true;
	UnitPropertyCondition.ExcludeOrganic = true;
	UnitPropertyCondition.ExcludeRobotic = false;
	UnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	RepairEffect = new class'X2Effect_SimpleHeal';
	Template.AddTargetEffect(RepairEffect);

	RemoveEffects = new class'X2Effect_RemoveEffectsByDamageType';
	RemoveEffects.DamageTypesToRemove.AddItem('Fire');
	RemoveEffects.DamageTypesToRemove.AddItem('Acid');
	Template.AddTargetEffect(RemoveEffects);

	Template.CustomFireAnim = 'NO_Repair';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate AddDroneMeleeStun()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityToHitCalc_StandardAim HitCalc;
	//local X2Effect_ApplyWeaponDamage PhysicalDamageEffect;
	local X2Effect_Stunned				    StunnedEffect;
	local X2Condition_UnitProperty			AdjacencyCondition;
	local X2AbilityCooldown Cooldown;
	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_DroneMeleeStun_LW');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_stun";

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.Hostility = eHostility_Offensive;

	Template.bShowActivation = true;
	//Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	//Template.bDontDisplayInAbilitySummary = true;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.STUNNER_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	HitCalc = new class'X2AbilityToHitCalc_StandardAim';
	HitCalc.BuiltInHitMod = default.DRONE_STUN_HIT_MODIFIER;
	Template.AbilityToHitCalc = HitCalc;

	StunnedEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(default.DRONE_STUN_ACTION_POINT_DAMAGE, 100);
	StunnedEffect.bRemoveWhenSourceDies = false;
	Template.AddTargetEffect(StunnedEffect);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	// Target Conditions
	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitOnlyProperty); // changed to disallow environmental objects, since nothing will happen
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);
	AdjacencyCondition = new class'X2Condition_UnitProperty';
	AdjacencyCondition.RequireWithinRange = true;
	AdjacencyCondition.ExcludeStunned = true;
	AdjacencyCondition.WithinRange = 144; //1.5 tiles in Unreal units, allows attacks on the diag
	Template.AbilityTargetConditions.AddItem(AdjacencyCondition);

	// Damage Effect
	//PhysicalDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	//Template.AddTargetEffect(PhysicalDamageEffect);

	Template.AbilityTargetStyle = default.SimpleSingleMeleeTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.CustomFireAnim = 'NO_Flash';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

//this ability links up grenades to an equipped grenade launcher
static function X2AbilityTemplate CreateAdventGrenadeLauncherAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_AdventGrenadeLauncher	AdvGLEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_AdventGrenadeLauncher_LW');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_grenade_flash";  // shouldn't ever display
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;

	AdvGLEffect = new class'X2Effect_AdventGrenadeLauncher';
	Template.AddTargetEffect(AdvGLEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate AddHitandSlitherAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_HitandRun				HitandRunEffect;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'BD_HitandSlither_LW');
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_BD_LWAlienPack.LW_AbilityHitandRun";
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	HitandRunEffect = new class'X2Effect_HitandRun';
	HitandRunEffect.BuildPersistentEffect(1, true, false, false);
	HitandRunEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	HitandRunEffect.DuplicateResponse = eDupe_Ignore;
	Template.AddTargetEffect(HitandRunEffect);
	Template.bCrossClassEligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: Visualization handled in X2Effect_HitandRun
	return Template;
}

static function X2DataTemplate CreateMassMindspinAbility()
{
	local X2AbilityTemplate							Template;
	local X2AbilityCost_ActionPoints				ActionPointCost;
	local X2AbilityCooldown_LocalAndGlobal			Cooldown;
	local X2Condition_UnitProperty					UnitPropertyCondition;
	//local X2Condition_Visibility        TargetVisibilityCondition;
	local X2Condition_UnitImmunities				UnitImmunityCondition;
	local X2Effect_PersistentStatChange				DisorientedEffect;
	local X2Effect_Panicked							PanickedEffect;
	local X2Effect_MindControl						MindControlEffect;
	local X2Effect_RemoveEffects					MindControlRemoveEffects;
	local X2Condition_UnitEffects					ExcludeEffects;
	local X2AbilityMultiTarget_Cone					ConeMultiTarget;
	local X2AbilityTarget_Cursor					CursorTarget;
	local X2AbilityToHitCalc_StatCheck_UnitVsUnit	ToHitCalc;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_MassMindSpin_LW');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_sectoid_mindspin";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	ToHitCalc = new class'X2AbilityToHitCalc_StatCheck_UnitVsUnit';
	Template.AbilityToHitCalc = ToHitCalc;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown_LocalAndGlobal';
	Cooldown.iNumTurns = 3;
	Cooldown.NumGlobalTurns = 1;
	Template.AbilityCooldown = Cooldown;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	ConeMultiTarget.ConeEndDiameter = 12 * default.MASS_MINDSPIN_LW_CONE_END_DIAMETER;
	ConeMultiTarget.fTargetRadius = 99.0;
	ConeMultiTarget.ConeLength=default.MASS_MINDSPIN_LW_CONE_LENGTH;
	ConeMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange=false;
	Template.AbilityTargetStyle = CursorTarget;
	Template.TargetingMethod = class'X2TargetingMethod_MassMindspin';

	//Template.AbilityMultiTargetConditions.AddItem(default.LivingHostileTargetProperty);
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeRobotic = true;
	UnitPropertyCondition.ExcludeAlive=false;
	UnitPropertyCondition.ExcludeDead=true;
	UnitPropertyCondition.ExcludeFriendlyToSource=true;
	UnitPropertyCondition.ExcludeHostileToSource=false;
	UnitPropertyCondition.TreatMindControlledSquadmateAsHostile=false;
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	//TargetVisibilityCondition = new class'X2Condition_Visibility';
	//TargetVisibilityCondition.bRequireGameplayVisible = true;
	//Template.AbilityMultiTargetConditions.AddItem(TargetVisibilityCondition);

	ExcludeEffects = new class'X2Condition_UnitEffects';
	ExcludeEffects.AddExcludeEffect(class'X2Ability_CarryUnit'.default.CarryUnitEffectName, 'AA_UnitIsImmune');
	ExcludeEffects.AddExcludeEffect(class'X2AbilityTemplateManager'.default.StunnedName, 'AA_UnitIsStunned');
	ExcludeEffects.AddExcludeEffect(class'X2Effect_MindControl'.default.EffectName, 'AA_UnitIsMindControlled');
	Template.AbilityMultiTargetConditions.AddItem(ExcludeEffects);

	UnitImmunityCondition = new class'X2Condition_UnitImmunities';
	UnitImmunityCondition.AddExcludeDamageType('Mental');
	UnitImmunityCondition.bOnlyOnCharacterTemplate = true;
	Template.AbilityMultiTargetConditions.AddItem(UnitImmunityCondition);

	//  Disorient effect for 1 unblocked psi hit
	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();
	DisorientedEffect.iNumTurns = class'X2Ability_Sectoid'.default.SECTOID_MINDSPIN_DISORIENTED_DURATION;
	DisorientedEffect.MinStatContestResult = 1;
	DisorientedEffect.MaxStatContestResult = 1;
	Template.AddMultiTargetEffect(DisorientedEffect);
	//  Disorient effect for 2 unblocked psi hits
	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();
	DisorientedEffect.iNumTurns = class'X2Ability_Sectoid'.default.SECTOID_MINDSPIN_DISORIENTED_DURATION + 1;
	DisorientedEffect.MinStatContestResult = 2;
	DisorientedEffect.MaxStatContestResult = 2;
	Template.AddMultiTargetEffect(DisorientedEffect);

	PanickedEffect = class'X2StatusEffects'.static.CreatePanickedStatusEffect();
	PanickedEffect.MinStatContestResult = 3;
	PanickedEffect.MaxStatContestResult = 4;
	Template.AddMultiTargetEffect(PanickedEffect);

	MindControlEffect = class'X2StatusEffects'.static.CreateMindControlStatusEffect(class'X2Ability_Sectoid'.default.SECTOID_MINDSPIN_CONTROL_DURATION);
	MindControlEffect.MinStatContestResult = 5;
	MindControlEffect.MaxStatContestResult = 0;
	Template.AddMultiTargetEffect(MindControlEffect);

	MindControlRemoveEffects = class'X2StatusEffects'.static.CreateMindControlRemoveEffects();
	MindControlRemoveEffects.MinStatContestResult = 5;
	MindControlRemoveEffects.MaxStatContestResult = 0;
	MindControlRemoveEffects.DamageTypes.AddItem('Mental');
	Template.AddMultiTargetEffect(MindControlRemoveEffects);

	// Unlike in other cases, in TypicalAbility_BuildVisualization, the MissSpeech is used on the Target!
	Template.TargetMissSpeech = 'SoldierResistsMindControl';

	Template.CustomFireAnim = 'HL_Psi_ProjectileMedium';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Sectoid_Mindspin";

	// This action is considered 'hostile' and can be interrupted!
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	//Need FX on targets

	return Template;
}

static function X2DataTemplate CreateMassReanimateAbility()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCooldown_LocalAndGlobal	Cooldown;
	local X2AbilityMultiTarget_Radius		RadiusMultiTarget;
	local X2AbilityTarget_Cursor			CursorTarget;
	local X2Condition_UnitProperty			UnitPropertyCondition;
	local X2Condition_UnitValue				UnitValue;
	local X2Effect_SpawnPsiZombie			SpawnZombieEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_MassReanimation_LW');
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_BD_LWAlienPack.LW_AbilityMassreanimate";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.Hostility = eHostility_Neutral;

	//should no longer be needed with custom anim
	//Template.bShowActivation = true;
	//Template.bSkipFireAction = true;

	//attempted new targeting method
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToSquadsightRange = true;
	CursorTarget.FixedAbilityRange = default.MASS_REANIMATION_LW_RANGE_METERS;
	Template.AbilityTargetStyle = CursorTarget;

	//Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityToHitCalc = default.Deadeye;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.MASS_REANIMATION_LW_MIN_ACTION_COST;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown_LocalAndGlobal';
	Cooldown.iNumTurns = default.MASS_REANIMATION_LW_LOCAL_COOLDOWN;
	Cooldown.NumGlobalTurns = default.MASS_REANIMATION_LW_GLOBAL_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.MASS_REANIMATION_LW_RADIUS_METERS;
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	RadiusMultiTarget.bAllowDeadMultiTargetUnits = true;
	RadiusMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_MassPsiReanimation';

	SpawnZombieEffect = new class'X2Effect_SpawnPsiZombie';
	SpawnZombieEffect.AnimationName = 'HL_GetUp_Multi';
	SpawnZombieEffect.BuildPersistentEffect(1);
	SpawnZombieEffect.StartAnimationMinDelaySec = class'X2Ability_GateKeeper'.default.MASS_REANIMATION_ANIMATION_MIN_DELAY_SEC;
	SpawnZombieEffect.StartAnimationMaxDelaySec = class'X2Ability_GateKeeper'.default.MASS_REANIMATION_ANIMATION_MAX_DELAY_SEC;

	// The unit must be organic, dead, and not an alien
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeAlive = true;
	UnitPropertyCondition.ExcludeRobotic = true;
	UnitPropertyCondition.ExcludeOrganic = false;
	UnitPropertyCondition.ExcludeAlien = true;
	UnitPropertyCondition.ExcludeCivilian = false;
	UnitPropertyCondition.ExcludeCosmetic = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	UnitPropertyCondition.FailOnNonUnits = true;
	SpawnZombieEffect.TargetConditions.AddItem(UnitPropertyCondition);

	// This effect is only valid if the target has not yet been turned into a zombie
	UnitValue = new class'X2Condition_UnitValue';
	UnitValue.AddCheckValue(class'X2Effect_SpawnPsiZombie'.default.TurnedZombieName, 1, eCheck_LessThan);
	SpawnZombieEffect.TargetConditions.AddItem(UnitValue);

	Template.AddMultiTargetEffect(SpawnZombieEffect);

	//Template.bSkipPerkActivationActions = true;
	Template.CustomFireAnim = 'HL_Psi_MassReanimate';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = AnimaInversion_BuildVisualization_SC;
	Template.CinescriptCameraType = "Sectoid_PsiReanimation";

	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	return Template;
}

simulated function AnimaInversion_BuildVisualization_SC(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata GatekeeperTrack, BuildTrack, ZombieTrack;
	local XComGameState_Unit SpawnedUnit, DeadUnit;
	local UnitValue SpawnedUnitValue;
	local X2Effect_SpawnPsiZombie SpawnPsiZombieEffect;
	local int i, j;
	local name SpawnPsiZombieEffectResult;
	local X2VisualizerInterface TargetVisualizerInterface;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	GatekeeperTrack = EmptyTrack;
	GatekeeperTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	GatekeeperTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	GatekeeperTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(GatekeeperTrack, Context, false, GatekeeperTrack.LastActionAdded);
	class'X2Action_ExitCover'.static.AddToVisualizationTree(GatekeeperTrack, Context, false, GatekeeperTrack.LastActionAdded);
	class'X2Action_Fire'.static.AddToVisualizationTree(GatekeeperTrack, Context, false, GatekeeperTrack.LastActionAdded);
	class'X2Action_EnterCover'.static.AddToVisualizationTree(GatekeeperTrack, Context, false, GatekeeperTrack.LastActionAdded);
	class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree(GatekeeperTrack, Context, false, GatekeeperTrack.LastActionAdded);

	// Configure the visualization track for the multi targets
	//******************************************************************************************
	for( i = 0; i < Context.InputContext.MultiTargets.Length; ++i )
	{
		InteractingUnitRef = Context.InputContext.MultiTargets[i];
		BuildTrack = EmptyTrack;
		BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
		BuildTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

		//class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(BuildTrack, Context, false, BuildTrack.LastActionAdded);

		for( j = 0; j < Context.ResultContext.MultiTargetEffectResults[i].Effects.Length; ++j )
		{
			SpawnPsiZombieEffect = X2Effect_SpawnPsiZombie(Context.ResultContext.MultiTargetEffectResults[i].Effects[j]);
			SpawnPsiZombieEffectResult = 'AA_UnknownError';

			if( SpawnPsiZombieEffect != none )
			{
				SpawnPsiZombieEffectResult = Context.ResultContext.MultiTargetEffectResults[i].ApplyResults[j];
			}
			else
			{
				Context.ResultContext.MultiTargetEffectResults[i].Effects[j].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, Context.ResultContext.MultiTargetEffectResults[i].ApplyResults[j]);
			}
		}

		TargetVisualizerInterface = X2VisualizerInterface(BuildTrack.VisualizeActor);
		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, BuildTrack);
		}

		if( SpawnPsiZombieEffectResult == 'AA_Success' )
		{
			DeadUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID));
			`assert(DeadUnit != none);
			DeadUnit.GetUnitValue(class'X2Effect_SpawnUnit'.default.SpawnedUnitValueName, SpawnedUnitValue);

			ZombieTrack = EmptyTrack;
			ZombieTrack.StateObject_OldState = History.GetGameStateForObjectID(SpawnedUnitValue.fValue, eReturnType_Reference, VisualizeGameState.HistoryIndex);
			ZombieTrack.StateObject_NewState = ZombieTrack.StateObject_OldState;
			SpawnedUnit = XComGameState_Unit(ZombieTrack.StateObject_NewState);
			`assert(SpawnedUnit != none);
			ZombieTrack.VisualizeActor = History.GetVisualizer(SpawnedUnit.ObjectID);

			SpawnPsiZombieEffect.AddSpawnVisualizationsToTracks(Context, SpawnedUnit, ZombieTrack, DeadUnit, BuildTrack);
		}
	}
}

static function X2DataTemplate CreatePersonalShieldAbility()
{
	local X2AbilityTemplate							Template;
	local X2AbilityCooldown							Cooldown;
	local X2AbilityCost_ActionPoints				ActionPointCost;
	local array<name>								SkipExclusions;
	local X2Effect_EnergyShield						PersonalShieldEffect;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'BD_Personalshield_LW');

	Template.IconImage = "img:///UILibrary_BD_LWAlienPack.LW_AbilityPersonalShields"; // from old EW icon for Bioelectric skin
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.bCrossClassEligible = false;
	Template.bDisplayInUITooltip = true;
	Template.bDisplayInUITacticalText = true;
	Template.bShowActivation = true;
	//Template.bSkipFireAction = true;
	Template.DisplayTargetHitChance = false;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName); //okay when disoriented
	Template.AddShooterEffectExclusions(SkipExclusions);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.PERSONAL_SHIELD_ACTION_COST;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.PERSONAL_SHIELD_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	PersonalShieldEffect = new class'X2Effect_EnergyShield';
	PersonalShieldEffect.BuildPersistentEffect(default.PERSONAL_SHIELD_DURATION, false, true, false, eGameRule_PlayerTurnEnd);
	PersonalShieldEffect.SetDisplayInfo (ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
	PersonalShieldEffect.AddPersistentStatChange(eStat_ShieldHP, default.PERSONAL_SHIELD_HP);
	PersonalShieldEffect.EffectName='PersonalShield';
	Template.AddTargetEffect(PersonalShieldEffect);

	Template.CustomFireAnim = 'HL_SignalPositive';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "AdvShieldBearer_EnergyShieldArmor"; //??

	return Template;
}


static function X2DataTemplate CreateReadyForAnythingAbility()
{
	local X2AbilityTemplate							Template;
	local X2Effect_ReadyForAnything					ActionPointEffect;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'BD_ReadyForAnything_LW');

	Template.IconImage = "img:///UILibrary_BD_LWAlienPack.LW_AbilityReadyForAnything";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.bShowActivation = false;
	Template.bIsPassive = true;
	Template.bDisplayInUITooltip = true;
	Template.bDisplayInUITacticalText = true;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ActionPointEffect = new class'X2Effect_ReadyForAnything';
	ActionPointEffect.BuildPersistentEffect (1, true, false);
	ActionPointEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
	Template.AddTargetEffect(ActionPointEffect);

	Template.AdditionalAbilities.AddItem('BD_ReadyForAnything_LWFlyover');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;


	return Template;
}

static function X2DataTemplate ReadyForAnythingFlyover()
{
	local X2AbilityTemplate					Template;
	local X2AbilityTrigger_EventListener	EventListener;
	local X2Effect_CoveringFire             CoveringFireEffect;
	local X2Condition_AbilityProperty       CoveringFireCondition;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'BD_ReadyForAnything_LWFlyover');

	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;
	Template.bDontDisplayInAbilitySummary = true;

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.EventID = 'ReadyForAnythingTriggered';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(EventListener);

	// Tedster - apply Covering Fire effect here since this is fired by RFA.
	CoveringFireEffect = new class'X2Effect_CoveringFire';
	CoveringFireEffect.AbilityToActivate = 'OverwatchShot';
	CoveringFireEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	CoveringFireCondition = new class'X2Condition_AbilityProperty';
	CoveringFireCondition.OwnerHasSoldierAbilities.AddItem('CoveringFire');
	CoveringFireEffect.TargetConditions.AddItem(CoveringFireCondition);
	Template.AddTargetEffect(CoveringFireEffect);

	Template.CinescriptCameraType = "Overwatch";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = ReadyforAnything_BuildVisualization;

	return Template;
}

simulated function ReadyForAnything_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory			History;
	local XComGameStateContext_Ability	Context;
	local VisualizationActionMetadata	EmptyTrack;
	local VisualizationActionMetadata	BuildTrack;
	local X2Action_PlaySoundAndFlyOver	SoundAndFlyOver;
	local StateObjectReference			InteractingUnitRef;
	local XComGameState_Ability			Ability;

	History = `XCOMHISTORY;
	context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;
	Ability = XComGameState_Ability(History.GetGameStateForObjectID(context.InputContext.AbilityRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1));
	BuildTrack = EmptyTrack;
	BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	BuildTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(BuildTrack, Context, false, BuildTrack.LastActionAdded));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(SoundCue'SoundUI.OverWatchCue', Ability.GetMyTemplate().LocFlyOverText, '', eColor_Alien, "img:///UILibrary_PerkIcons.UIPerk_overwatch");
}

static function X2AbilityTemplate CreateChryssalidSoldierSlashAbility()
{
	local X2AbilityTemplate Template;
	local X2Effect_HiveQueenSlash	DamageEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_ChryssalidSoldierSlash_LW');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_chryssalid_slash";

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	DamageEffect = new class'X2Effect_HiveQueenSlash';
	DamageEffect.BonusDamage = default.CHRYSSALID_SOLDIER_SLASH_BONUS_DAMAGE;
	DamageEffect.BuildPersistentEffect(1, true, false, false);
	DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,, 'eAbilitySource_Perk');
	Template.AddTargetEffect(DamageEffect);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.MeleeLostSpawnIncreasePerUse;

	return Template;
}

static function X2AbilityTemplate AddFireOnDeathAbility()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_Radius			RadiusMultiTarget;
	local X2Effect_Burning						BurningEffect;
	local X2AbilityTrigger_EventListener		Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_FireOnDeath_LW');
	Template.IconImage = "img:///UILibrary_BD_LW_Overhaul.LW_AbilityIgnition";
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	Template.bDontDisplayInAbilitySummary = true;
	Template.bSkipFireAction = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = 1.5f;
	RadiusMultiTarget.bUseWeaponRadius = false;
	RadiusMultiTarget.bUseSourceWeaponLocation = false;
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	RadiusMultiTarget.bAddPrimaryTargetAsMultiTarget = true;
	RadiusMultiTarget.bExcludeSelfAsTargetIfWithinRadius = false;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	Trigger = New class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitDied';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self_VisualizeInGameState;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.AddMultiTargetEffect(new class'X2Effect_ApplyFireToWorld');

	BurningEffect = class'X2StatusEffects'.static.CreateBurningStatusEffect(1, 0);
	BurningEffect.ApplyChance = 25;
	Template.AddMultiTargetEffect(BurningEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate StandalonePinionsAbility()
{
	local X2AbilityTemplate         Template;
	Template = PurePassive('StandalonePinionsAbility', "img:///UILibrary_PerkIcons.UIPerk_archon_blazingpinions");

	Template.AdditionalAbilities.AddItem('StandalonePinionsStage1');	
	
	return Template;
}


static function X2AbilityTemplate BD_RocketLauncherAbility()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Radius       RadiusMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2AbilityToHitCalc_StandardAim    StandardAim;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_RocketLauncher');
	
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	ActionPointCost = new class'X2AbilityCost_HeavyWeaponActionPoints';
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bGuaranteedHit = true;
	Template.AbilityToHitCalc = StandardAim;
	
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bExplosiveDamage = true;
	Template.AddMultiTargetEffect(WeaponDamageEffect);
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.bUseWeaponRadius = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

	Template.AddShooterEffectExclusions();

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_WrongSoldierClass');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_firerocket";
	Template.bUseAmmoAsChargesForHUD = true;
	Template.TargetingMethod = class'X2TargetingMethod_RocketLauncher';

	Template.ActivationSpeech = 'RocketLauncher';
	Template.CinescriptCameraType = "Grenadier_GrenadeLauncher";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.HeavyWeaponLostSpawnIncreasePerUse;

	return Template;	
}

static function X2AbilityTemplate StandalonePinionsStage1Ability()
{

local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown_LocalAndGlobal Cooldown;
	local X2AbilityMultiTarget_BlazingPinions BlazingPinionsMultiTarget;
	local X2AbilityTarget_Cursor CursorTarget;
	local X2Condition_UnitProperty UnitProperty;
	local X2Effect_DelayedAbilityActivation BlazingPinionsStage1DelayEffect;
	local X2Effect_Persistent BlazingPinionsStage1Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'StandalonePinionsStage1');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_archon_blazingpinions"; // TODO: Change this icon
	Template.Hostility = eHostility_Offensive;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.bShowActivation = true;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.TwoTurnAttackAbility = 'StandalonePinionsStage2';

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown_LocalAndGlobal';
	Cooldown.iNumTurns = default.STANDALONE_PINIONS_LOCAL_COOLDOWN;
	Cooldown.NumGlobalTurns = default.STANDALONE_PINIONS_GLOBAL_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	UnitProperty = new class'X2Condition_UnitProperty';
	UnitProperty.ExcludeDead = true;
	UnitProperty.HasClearanceToMaxZ = true;
	Template.AbilityShooterConditions.AddItem(UnitProperty);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AddShooterEffectExclusions();
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
 
	Template.TargetingMethod = class'X2TargetingMethod_BlazingPinions';

	// The target locations are enemies
	UnitProperty = new class'X2Condition_UnitProperty';
	UnitProperty.ExcludeFriendlyToSource = true;
	UnitProperty.ExcludeCivilian = true;
	UnitProperty.ExcludeDead = true;
	UnitProperty.HasClearanceToMaxZ = true;
	UnitProperty.FailOnNonUnits = true;
	Template.AbilityMultiTargetConditions.AddItem(UnitProperty);

	BlazingPinionsMultiTarget = new class'X2AbilityMultiTarget_BlazingPinions';
	BlazingPinionsMultiTarget.fTargetRadius = default.STANDALONE_PINIONS_TARGETING_AREA_RADIUS;
	BlazingPinionsMultiTarget.NumTargetsRequired = default.STANDALONE_PINIONS_NUM_TARGETS;
	Template.AbilityMultiTargetStyle = BlazingPinionsMultiTarget;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = default.STANDALONE_PINIONS_SELECTION_RANGE;
	Template.AbilityTargetStyle = CursorTarget;

	//Delayed Effect to cause the second Blazing Pinions stage to occur
	BlazingPinionsStage1DelayEffect = new class 'X2Effect_DelayedAbilityActivation';
	BlazingPinionsStage1DelayEffect.BuildPersistentEffect(1, false, false, , eGameRule_PlayerTurnBegin);
	BlazingPinionsStage1DelayEffect.EffectName = 'BlazingPinionsStage1Delay';
	BlazingPinionsStage1DelayEffect.TriggerEventName = class'X2Ability_Archon'.default.BlazingPinionsStage2TriggerName;
	BlazingPinionsStage1DelayEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true, , Template.AbilitySourceName);
	Template.AddShooterEffect(BlazingPinionsStage1DelayEffect);

	// An effect to attach Perk FX to
	BlazingPinionsStage1Effect = new class'X2Effect_Persistent';
	BlazingPinionsStage1Effect.BuildPersistentEffect(1, true, false, true);
	BlazingPinionsStage1Effect.EffectName = class'X2Ability_Archon'.default.BlazingPinionsStage1EffectName;
	Template.AddShooterEffect(BlazingPinionsStage1Effect);

	//  The target FX goes in target array as there will be no single target hit and no side effects of this touching a unit
	Template.AddShooterEffect(new class'X2Effect_ApplyBlazingPinionsTargetToWorld');

	Template.ModifyNewContextFn = class'X2Ability_Archon'.static.BlazingPinionsStage1_ModifyActivatedAbilityContext;
	Template.BuildNewGameStateFn = class'X2Ability_Archon'.static.BlazingPinionsStage1_BuildGameState;
	Template.BuildInterruptGameStateFn = class'X2Ability_Archon'.static.TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = class'X2Ability_Archon'.static.BlazingPinionsStage1_BuildVisualization;
	Template.BuildAppliedVisualizationSyncFn = class'X2Ability_Archon'.static.BlazingPinionsStage1_BuildVisualizationSync;
	Template.CinescriptCameraType = "Archon_BlazingPinions_Stage1";
//BEGIN AUTOGENERATED CODE: Template Overrides 'BlazingPinionsStage1'
	Template.bFrameEvenWhenUnitIsHidden = true;
//END AUTOGENERATED CODE: Template Overrides 'BlazingPinionsStage1'
	
	return Template;

}

static function X2AbilityTemplate StandalonePinionsStage2Ability()

{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener DelayedEventListener;
	local X2Effect_RemoveEffects RemoveEffects;
	local X2Effect_ApplyWeaponDamage DamageEffect;
	local X2AbilityMultiTarget_Radius RadMultiTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'StandalonePinionsStage2');
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;

	Template.bDontDisplayInAbilitySummary = true;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	// This ability fires when the event DelayedExecuteRemoved fires on this unit
	DelayedEventListener = new class'X2AbilityTrigger_EventListener';
	DelayedEventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	DelayedEventListener.ListenerData.EventID = class'X2Ability_Archon'.default.BlazingPinionsStage2TriggerName;
	DelayedEventListener.ListenerData.Filter = eFilter_Unit;
	DelayedEventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_BlazingPinions;
	Template.AbilityTriggers.AddItem(DelayedEventListener);

	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Ability_Archon'.default.BlazingPinionsStage1EffectName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_ApplyBlazingPinionsTargetToWorld'.default.EffectName);
	Template.AddShooterEffect(RemoveEffects);

	RadMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadMultiTarget.fTargetRadius = default.STANDALONE_PINIONS_IMPACT_RADIUS_METERS;

	Template.AbilityMultiTargetStyle = RadMultiTarget;

	// The MultiTarget Units are dealt this damage
	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.bApplyWorldEffectsForEachTargetLocation = true;
	Template.AddMultiTargetEffect(DamageEffect);

	Template.ModifyNewContextFn = class'X2Ability_Archon'.static.BlazingPinionsStage2_ModifyActivatedAbilityContext;
	Template.BuildNewGameStateFn = class'X2Ability_Archon'.static.BlazingPinionsStage2_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_Archon'.static.BlazingPinionsStage2_BuildVisualization;
	Template.CinescriptCameraType = "Archon_BlazingPinions_Stage2";

	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.HeavyWeaponLostSpawnIncreasePerUse;
	//BEGIN AUTOGENERATED CODE: Template Overrides 'BlazingPinionsStage2'
	Template.bFrameEvenWhenUnitIsHidden = true;
	//END AUTOGENERATED CODE: Template Overrides 'BlazingPinionsStage2'

	return Template;
}

static function X2AbilityTemplate CreateLWViperPoisonSpitAbilities()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Cylinder     CylinderMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2AbilityTrigger_PlayerInput      InputTrigger;
	local X2AbilityCooldown_LocalAndGlobal  Cooldown;
	local X2Effect_ApplyWeaponDamage		DamageEffect;
	local X2Condition_UnitImmunities		UnitImmunityCondition;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_PoisonSpit');
	Template.bDontDisplayInAbilitySummary = false;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_poisonspit";

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityToHitCalc = default.DeadEye;	

	UnitImmunityCondition = new class'X2Condition_UnitImmunities';
	UnitImmunityCondition.AddExcludeDamageType('Poison');
	Template.AbilityMultiTargetConditions.AddItem(UnitImmunityCondition);

	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.EffectDamageValue.DamageType = 'Poison';
	DamageEffect.DamageTypes.AddItem('Poison');
	DamageEffect.bAllowFreeKill = false;
	DamageEffect.bIgnoreArmor = true;	
	Template.AddMultiTargetEffect(DamageEffect);

	Template.AddMultiTargetEffect(class'X2StatusEffects'.static.CreatePoisonedStatusEffect());
	Template.AddMultiTargetEffect(new class'X2Effect_ApplyPoisonToWorld');

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	CylinderMultiTarget = new class'X2AbilityMultiTarget_Cylinder';
	CylinderMultiTarget.bUseWeaponRadius = true;
	CylinderMultiTarget.fTargetHeight = class'X2Ability_Viper'.default.POISON_SPIT_CYLINDER_HEIGHT_METERS;
	CylinderMultiTarget.bUseOnlyGroundTiles = true;
	Template.AbilityMultiTargetStyle = CylinderMultiTarget;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition); 
	Template.AddShooterEffectExclusions();

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);
	
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_viper_poisonspit";
	Template.bUseAmmoAsChargesForHUD = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Viper_PoisonSpit";

	Template.TargetingMethod = class'X2TargetingMethod_ViperSpit';

	// Cooldown on the ability
	Cooldown = new class'X2AbilityCooldown_LocalAndGlobal';
	Cooldown.iNumTurns = 4;
	//Cooldown.NumGlobalTurns = 1;
	Template.AbilityCooldown = Cooldown;

	// This action is considered 'hostile' and can be interrupted!
	Template.Hostility = eHostility_Offensive;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
//BEGIN AUTOGENERATED CODE: Template Overrides 'PoisonSpit'
	Template.bFrameEvenWhenUnitIsHidden = true;
//END AUTOGENERATED CODE: Template Overrides 'PoisonSpit'

	return Template;
}

static function X2AbilityTemplate CreateLostBladestorm()
{
	local X2AbilityTemplate Template;
	Template = PurePassive('BD_LostBladestorm_LW', "img:///UILibrary_PerkIcons.UIPerk_bladestorm", false, 'eAbilitySource_Perk');
	Template.AdditionalAbilities.AddItem('BD_LostBladestormAttack_LW');
	return Template;
}

static function X2DataTemplate CreateLostBladestormAttack()
{
	local X2AbilityTemplate Template;
	local X2Condition_NotItsOwnTurn NotItsOwnTurnCondition;
	local X2Condition_Unitproperty RangeCondition;
	Template = class'X2Ability_RangerAbilitySet'.static.BladestormAttack('BD_LostBladestormAttack_LW');

	// necessary to limit range to 1 tile because of weapon range configuration
	RangeCondition = new class'X2Condition_Unitproperty';
	RangeCondition.RequireWithinRange = true;
	RangeCondition.WithinRange = 144; //1.5 tiles in Unreal units, allows attacks on the diag
	
	Template.AbilityTargetConditions.AddItem(RangeCondition);

	/* values from Lost melee attack */
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_muton_punch";
	Template.Hostility = eHostility_Offensive;
//	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
//	Template.MergeVisualizationFn = LostAttack_MergeVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.CustomFireAnim = 'FF_Melee';
	Template.CinescriptCameraType = "Lost_Attack";

	NotItsOwnTurnCondition = new class'X2Condition_NotItsOwnTurn';
	Template.AbilityShooterConditions.AddItem(NotItsOwnTurnCondition);

	return Template;
}