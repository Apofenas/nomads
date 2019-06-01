-- The surface support vehicle that's in orbit

local NCivilianStructureUnit = import('/lua/nomadsunits.lua').NCivilianStructureUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local CreateNomadsBuildSliceBeams = import('/lua/nomadseffectutilities.lua').CreateNomadsBuildSliceBeams

xnc0002 = Class(NCivilianStructureUnit) {

    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
        self.ThrusterEffectsBag = TrashBag()

        NCivilianStructureUnit.OnCreate(self)

        if self:GetBlueprint().Rotators.Stationary then
            self:StationaryAngle()
        else
            self:RotatingAngle()
        end
        --ForkThread(function()
        --  WaitSeconds(2)
        --  self:Landing()
        --  WaitSeconds(10)
        --  self:TakeOff()
        --end
        --)
        
        --self:TakeOff()
        --self:BurnEngines()

        --[[for _, army in ListArmies() do
            if not IsEnemy(army, self:GetArmy()) then
                self:AddToConstructionQueue('xnl0105', army)
            end
        end]]
        --[[ForkThread(function()
            WaitSeconds(2)
            WARN("stop now")
            self:StopRotators()
            WaitSeconds(4)
            WARN("start now")
            self:StartRotators()
            end
        )]]
    end,

    StopRotators = function(self)
        if self.RotatorManipulator1 then
            self.RotatorManipulator1:SetTargetSpeed( 0 )
        end
        if self.RotatorManipulator2 then
            self.RotatorManipulator2:SetTargetSpeed( 0 )
        end
        if self.RotatorManipulator3 then
            self.RotatorManipulator3:SetTargetSpeed( 0 )
        end        
    end,
    
    StartRotators = function(self)
        if self.RotatorManipulator1 then
            self.RotatorManipulator1:SetTargetSpeed( self:GetBlueprint().Rotators.PrimarySpeed )
        end
        if self.RotatorManipulator2 then
            self.RotatorManipulator2:SetTargetSpeed( self:GetBlueprint().Rotators.SecondarySpeed )
        end
        if self.RotatorManipulator3 then
            self.RotatorManipulator3:SetTargetSpeed( self:GetBlueprint().Rotators.PrimarySpeed )
        end
    end,
    
    RotatingAngle = function(self)
        -- spinner 1 and 3
        if not self.RotatorManipulator1 then
            self.RotatorManipulator1 = CreateRotator( self, 'Spinner1', 'z' )
            self.RotatorManipulator1:SetAccel( self:GetBlueprint().Rotators.PrimaryAccel )
            self.RotatorManipulator1:SetTargetSpeed( self:GetBlueprint().Rotators.PrimarySpeed )
            self.Trash:Add( self.RotatorManipulator1 )
        end
        if not self.RotatorManipulator3 then
            self.RotatorManipulator3 = CreateRotator( self, 'Spinner3', 'z' )
            self.RotatorManipulator3:SetAccel( self:GetBlueprint().Rotators.PrimaryAccel )
            self.RotatorManipulator3:SetTargetSpeed( self:GetBlueprint().Rotators.PrimarySpeed )
            self.Trash:Add( self.RotatorManipulator3 )
        end

        -- spinner 2
        if not self.RotatorManipulator2 then
            self.RotatorManipulator2 = CreateRotator( self, 'Spinner2', 'z' )
            self.RotatorManipulator2:SetAccel( self:GetBlueprint().Rotators.SecondaryAccel )
            self.RotatorManipulator2:SetTargetSpeed( self:GetBlueprint().Rotators.SecondarySpeed )
            self.Trash:Add( self.RotatorManipulator2 )
        end

    end,

    StationaryAngle = function(self)
        -- spinner 1 and 3
        if not self.RotatorManipulator1 then
            self.RotatorManipulator1 = CreateRotator( self, 'Spinner1', 'z' )
            self.RotatorManipulator1:SetCurrentAngle( self:GetBlueprint().Rotators.PrimaryAngle )
            self.Trash:Add( self.RotatorManipulator1 )
        end
        if not self.RotatorManipulator3 then
            self.RotatorManipulator3 = CreateRotator( self, 'Spinner3', 'z' )
            self.RotatorManipulator3:SetCurrentAngle( self:GetBlueprint().Rotators.PrimaryAngle )
            self.Trash:Add( self.RotatorManipulator3 )
        end

        -- spinner 2
        if not self.RotatorManipulator2 then
            self.RotatorManipulator2 = CreateRotator( self, 'Spinner2', 'z' )
            self.RotatorManipulator2:SetCurrentAngle( self:GetBlueprint().Rotators.SecondaryAngle )
            self.Trash:Add( self.RotatorManipulator2 )
        end
    end,



    EngineBurnBones = {'ExhaustBig', 'ExhaustSmallRight', 'ExhaustSmallLeft', 'ExhaustSmallTop'},

    BurnEngines = function(self)
        local army, emit = self:GetArmy()
        local ThrusterEffects = {
            '/effects/emitters/nomads_orbital_frigate_thruster04_emit.bp',
            '/effects/emitters/nomads_orbital_frigate_thruster05_emit.bp',
            '/effects/emitters/nomads_orbital_frigate_thruster01_emit.bp',
            '/effects/emitters/nomads_orbital_frigate_thruster02_emit.bp',
        }
        ForkThread( function()
            for i = 1, 4 do
                for _, bone in self.EngineBurnBones do
                    emit = CreateAttachedEmitter( self, bone, army, ThrusterEffects[i] )
                    self.ThrusterEffectsBag:Add( emit )
                    self.Trash:Add( emit )
                    WaitSeconds(0.3)
                end
                WaitSeconds(2)
            end
        end)
    end,

    StopEngines = function(self)
        self.ThrusterEffectsBag:Destroy()
        local army, emit = self:GetArmy()
        local ThrusterEffects = {
            '/effects/emitters/nomads_orbital_frigate_thruster03_emit.bp',
            '/effects/emitters/nomads_orbital_frigate_thruster04_emit.bp',
        }
        ForkThread( function()
            for i = 1, 2 do
                for _, bone in self.EngineBurnBones do
                    emit = CreateAttachedEmitter( self, bone, army, ThrusterEffects[i] )
                    self.ThrusterEffectsBag:Add( emit )
                    self.Trash:Add( emit )
                end
            end
            WaitSeconds(1)
            self.ThrusterEffectsBag:Destroy()
            for _, bone in self.EngineBurnBones do
                emit = CreateAttachedEmitter( self, bone, army, ThrusterEffects[2] )
                self.ThrusterEffectsBag:Add( emit )
                self.Trash:Add( emit )
            end
            WaitSeconds(5)
            self.ThrusterEffectsBag:Destroy()
        end)
    end,



    ThrusterBurnBones = {'ThrusterFrontLeft', 'ThrusterFrontRight', 'ThrusterBackLeft', 'ThrusterBackRight'},

    TakeOff = function (self)
        self.LaunchAnim = CreateAnimator(self):PlayAnim('/units/xno0001/xno0001_launch.sca')
        self.LaunchAnim:SetAnimationFraction(0)
        self.LaunchAnim:SetRate(0.1)
        self.Trash:Add(self.LaunchAnim)
        ForkThread(
            function()
                WaitSeconds(0.3)
                self:BurnEngines()
            end
        )
    end,

    Landing = function (self)
        local army, emit = self:GetArmy()
        local ThrusterEffects = {
            '/effects/emitters/nomads_orbital_frigate_thruster04_emit.bp',
            '/effects/emitters/nomads_orbital_frigate_thruster05_emit.bp',
            '/effects/emitters/nomads_orbital_frigate_thruster01_emit.bp',
            '/effects/emitters/nomads_orbital_frigate_thruster02_emit.bp',
        }
        for i = 1, 4 do
            for _, bone in self.EngineBurnBones do
                emit = CreateAttachedEmitter( self, bone, army, ThrusterEffects[i] )
                self.ThrusterEffectsBag:Add( emit )
                self.Trash:Add( emit )
            end
        end
        self.LaunchAnim = CreateAnimator(self):PlayAnim('/units/xno0001/xno0001_land.sca')
        self.LaunchAnim:SetAnimationFraction(0.3)
        self.LaunchAnim:SetRate(0.1)
        self.Trash:Add(self.LaunchAnim)
        ForkThread(function()
            WaitSeconds(5.3)
            self:StopEngines()
        end
        )
    end,



    BuildQueue = {
    --   { unitType = 'xxx', },
    },
    ConstructingThreadHandle = nil,
    BuildBones ={0},
    AddToConstructionQueue = function(self, unitType , army)
        if unitType and type(unitType) == 'string' then
            table.insert( self.BuildQueue, { unitType = unitType, army = army} )
            self:MaybeStartConstruction()
            return true
        else
            WARN('xno0001: AddToConstructionQueue(): Passed unit type is not a string.')
        end
        return false
    end,

    OnConstructionFinished = function(self, unit)
    end,

    MaybeStartConstruction = function(self)
        if table.getn( self.BuildQueue ) > 0 then
            local keys = table.keys( self.BuildQueue )
            local queueKey = keys[1]
            self.ConstructingThreadHandle = self:ForkThread( self.StartConstruction, queueKey)
            self.Trash:Add( self.ConstructingThreadHandle )
        end
    end,


    StartConstruction = function( self, queueKey)
        local attachBone = 0
        local unitBp = self.BuildQueue[ queueKey ].unitType
        local army = self.BuildQueue[ queueKey ].army
        table.remove( self.BuildQueue, queueKey )

        if self.ConstructionArmAnimManip then
            self.ConstructionArmAnimManip:SetRate(1)
            WaitFor( self.ConstructionArmAnimManip )
        end

        local x, y, z =  unpack(self:GetPosition( attachBone ))
        local unit = CreateUnitHPR( unitBp, army, x + 5+ Random(3), y, z+ Random(3), 0, 0, 0 )

        self.UnitBeingBuilt = unit
        unit:SetIsValidTarget(false)
        unit:SetImmobile(true)

        -- build effects
        if unit:GetBlueprint().Display.BuildMeshBlueprint then
            unit:SetMesh(unit:GetBlueprint().Display.BuildMeshBlueprint, true)
        end
        local layer = self:GetCurrentLayer()
        unit:StartBeingBuiltEffects( self, layer)
        local effectThread = ForkThread( CreateNomadsBuildSliceBeams, self, unit, self.BuildBones, self.BuildEffectsBag )

        WaitTicks(math.ceil( unit:GetBlueprint().Economy.BuildTime or 10000 ) / 10)

        -- construction done!
        unit:DetachFrom()
        unit:SetIsValidTarget(true)
        unit:SetImmobile(false)

        -- remove building effects
        if unit:GetBlueprint().Display.BuildMeshBlueprint then
            unit:SetMesh(unit:GetBlueprint().Display.MeshBlueprint, true)
        end
        KillThread(effectThread)
        self:StopBuildingEffects()
    end,
}

TypeClass = xnc0002
