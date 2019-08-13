local DMW = DMW
if not DMW.Rotations.HUNTER then
    DMW.Rotations.HUNTER = {}
end
local Hunter = DMW.Rotations.HUNTER
local Player, Buff, Debuff, Spell, Target, Pet, Trait, GCD, Pet5Y, Pet5YC

local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
    Debuff = Player.Debuffs
    Spell = Player.Spells
    Trait = Player.Traits
    Target = Player.Target or false
    Pet = Player.Pet or false
    GCD = Player:GCD()
end

local function Cleave()
    local BSTarget = Debuff.BarbedShot:Lowest(Pet5Y) or Target
    -- actions.cleave=barbed_shot,target_if=min:dot.barbed_shot.remains,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max
    if Buff.Frenzy:Exist(Pet) and Buff.Frenzy:Remain(Pet) < (GCD + 0.1) then
        if Spell.BarbedShot:Cast(BSTarget) then
            return true
        end
    end
    -- actions.cleave+=/multishot,if=gcd.max-pet.cat.buff.beast_cleave.remains>0.25
    if (1.5 - Buff.BeastCleave:Remain(Pet)) > 0.25 then
        if Spell.Multishot:Cast(Target) then
            return true
        end
    end
    -- actions.cleave+=/barbed_shot,target_if=min:dot.barbed_shot.remains,if=full_recharge_time<gcd.max&cooldown.bestial_wrath.remains
    if Spell.BestialWrath:CurrentCD() > 0 and Spell.BarbedShot:FullRechargeTime() < GCD then
        if Spell.BarbedShot:Cast(BSTarget) then
            return true
        end
    end
    -- actions.cleave+=/aspect_of_the_wild
    -- actions.cleave+=/stampede,if=buff.aspect_of_the_wild.up&buff.bestial_wrath.up|target.time_to_die<15
    -- actions.cleave+=/bestial_wrath,if=cooldown.aspect_of_the_wild.remains_guess>20|talent.one_with_the_pack.enabled|target.time_to_die<15
    if Pet and not Pet.Dead then
        if Spell.BestialWrath:Cast(Player) then
            return true
        end
    end
    -- actions.cleave+=/chimaera_shot
    if Spell.ChimaeraShot:Cast(Target) then
        return true
    end
    -- actions.cleave+=/a_murder_of_crows
    if Spell.BestialWrath:CurrentCD() > 0 then
        if Spell.AMurderOfCrows:Cast(Target) then
            return true
        end
    end
    -- actions.cleave+=/barrage
    -- actions.cleave+=/kill_command,if=active_enemies<4|!azerite.rapid_reload.enabled
    if Pet and not Pet.Dead and (Pet5YC < 4 or Trait.RapidReload.Active) then
        if Spell.KillCommand:Cast(Target) then
            return true
        end
    end
    -- actions.cleave+=/dire_beast
    if Spell.DireBeast:Cast(Target) then
        return true
    end
    -- actions.cleave+=/barbed_shot,target_if=min:dot.barbed_shot.remains,if=pet.cat.buff.frenzy.down&(charges_fractional>1.8|buff.bestial_wrath.up)|cooldown.aspect_of_the_wild.remains<pet.cat.buff.frenzy.duration-gcd&azerite.primal_instincts.enabled|charges_fractional>1.4|target.time_to_die<9
    if (not Buff.Frenzy:Exist(Pet) and (Spell.BarbedShot:ChargesFrac() > 1.8 or Buff.BestialWrath:Exist())) or (Spell.AspectOfTheWild:CurrentCD() < (Buff.Frenzy:Duration() - GCD) and Trait.PrimalInstincts.Active) or (Trait.DanceOfDeath.Rank > 1 and not Buff.DanceOfDeath:Exist() and Player:CritPct() > 40) or Target.TTD < 9 then
        if Spell.BarbedShot:Cast(BSTarget) then
            return true
        end
    end
    -- actions.cleave+=/focused_azerite_beam
    -- actions.cleave+=/purifying_blast
    -- actions.cleave+=/concentrated_flame
    -- actions.cleave+=/blood_of_the_enemy
    -- actions.cleave+=/the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<10
    -- actions.cleave+=/multishot,if=azerite.rapid_reload.enabled&active_enemies>2
    if Pet5YC > 2 and Trait.RapidReload.Active then
        if Spell.Multishot:Cast(Target) then
            return true
        end
    end
    -- actions.cleave+=/cobra_shot,if=cooldown.kill_command.remains>focus.time_to_max&(active_enemies<3|!azerite.rapid_reload.enabled)
    if Spell.BestialWrath:CurrentCD() > Player:TTM() and (Pet5YC < 3 or not Trait.RapidReload.Active) then
        if Spell.CobraShot:Cast(Target) then
            return true
        end
    end
    -- actions.cleave+=/spitting_cobra
    if Spell.SpittingCobra:Cast(Target) then
        return true
    end
end

local function SingleTarget()
    -- actions.st=barbed_shot,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<gcd|cooldown.bestial_wrath.remains&(full_recharge_time<gcd|azerite.primal_instincts.enabled&cooldown.aspect_of_the_wild.remains<gcd)
    if (Buff.Frenzy:Exist(Pet) and Buff.Frenzy:Remain(Pet) < (GCD + 0.1)) or (Spell.BestialWrath:CurrentCD() > 0 and Spell.BarbedShot:FullRechargeTime() < GCD) then
        if Spell.BarbedShot:Cast(Target) then
            return true
        end
    end
    -- actions.st+=/concentrated_flame,if=focus+focus.regen*gcd<focus.max&buff.bestial_wrath.down&(!dot.concentrated_flame_burn.remains&!action.concentrated_flame.in_flight)|full_recharge_time<gcd|target.time_to_die<5
    -- actions.st+=/aspect_of_the_wild,if=cooldown.barbed_shot.charges<2|pet.cat.buff.frenzy.stack>2|!azerite.primal_instincts.enabled
    -- actions.st+=/stampede,if=buff.aspect_of_the_wild.up&buff.bestial_wrath.up|target.time_to_die<15
    -- actions.st+=/a_murder_of_crows,if=cooldown.bestial_wrath.remains
    if Spell.BestialWrath:CurrentCD() > 0 then
        if Spell.AMurderOfCrows:Cast(Target) then
            return true
        end
    end
    -- actions.st+=/focused_azerite_beam,if=buff.bestial_wrath.down|target.time_to_die<5
    -- actions.st+=/the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<10|target.time_to_die<5
    -- actions.st+=/bestial_wrath
    if Pet and not Pet.Dead then
        if Spell.BestialWrath:Cast(Player) then
            return true
        end
    end
    -- actions.st+=/kill_command
    if Pet and not Pet.Dead then
        if Spell.KillCommand:Cast(Target) then
            return true
        end
    end
    -- actions.st+=/chimaera_shot
    if Spell.ChimaeraShot:Cast(Target) then
        return true
    end
    -- actions.st+=/dire_beast
    if Spell.DireBeast:Cast(Target) then
        return true
    end
    -- actions.st+=/barbed_shot,if=pet.cat.buff.frenzy.down&(charges_fractional>1.8|buff.bestial_wrath.up)|cooldown.aspect_of_the_wild.remains<pet.cat.buff.frenzy.duration-gcd&azerite.primal_instincts.enabled|azerite.dance_of_death.rank>1&buff.dance_of_death.down&crit_pct_current>40|target.time_to_die<9
    if (not Buff.Frenzy:Exist(Pet) and (Spell.BarbedShot:ChargesFrac() > 1.8 or Buff.BestialWrath:Exist())) or (Spell.AspectOfTheWild:CurrentCD() < (Buff.Frenzy:Duration() - GCD) and Trait.PrimalInstincts.Active) or (Trait.DanceOfDeath.Rank > 1 and not Buff.DanceOfDeath:Exist() and Player:CritPct() > 40) or Target.TTD < 9 then
        if Spell.BarbedShot:Cast(Target) then
            return true
        end
    end
    -- actions.st+=/purifying_blast,if=buff.bestial_wrath.down|target.time_to_die<8
    -- actions.st+=/blood_of_the_enemy
    -- actions.st+=/barrage
    -- actions.st+=/cobra_shot,if=(focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost|cooldown.kill_command.remains>1+gcd|buff.memory_of_lucid_dreams.up)&cooldown.kill_command.remains>1
    if (Player.Power - Spell.CobraShot.Cost + Player.PowerRegen * (Spell.KillCommand:CurrentCD() - 1) > Spell.KillCommand.Cost or Spell.KillCommand:CurrentCD() > (1 + GCD) or Buff.MemoryOfLucidDreams:Exist()) and Spell.KillCommand:CurrentCD() > 1 then
        if Spell.CobraShot:Cast(Target) then
            return true
        end
    end
    -- actions.st+=/spitting_cobra
    if Spell.SpittingCobra:Cast(Target) then
        return true
    end
    -- actions.st+=/barbed_shot,if=charges_fractional>1.4
    if Spell.BarbedShot:ChargesFrac() > 1.4 then
        if Spell.BarbedShot:Cast(Target) then
            return true
        end
    end
end

local function PetStuff()
    if not Pet then
        if Spell.CallPet1:Cast(Player) then
            return true
        end
    end
    if Pet and Pet.Dead then
        if Spell.RevivePet:Cast(Player) then
            return true
        end
    end
    if Pet and Pet.HP < 70 then
        if Spell.MendPet:Cast(Player) then
            return true
        end
    end
end

function Hunter.BeastMastery()
    Locals()
    PetStuff()
    if Target and Target.ValidEnemy then
        Pet5YC = 0
        if Pet then
            Pet5Y, Pet5YC = Pet:GetEnemies(5)
        end
        if Pet5YC < 2 then
            if SingleTarget() then
                return true
            end
        else
            if Cleave() then
                return true
            end
        end
    end
end