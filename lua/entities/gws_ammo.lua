AddCSLuaFile()

ENT.Base 			= nil
ENT.Type 			= "anim"
ENT.PrintName = "Ammo"
ENT.Model = "models/Items/BoxSRounds.mdl"

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		self:SetUseType(SIMPLE_USE)

		self.Ammo = {}
		
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
	end

	function ENT:Use(activator)
		if activator:IsPlayer() then
			if self.Ammo[2] == nil or self.Ammo[1] == nil then return end
			activator:GiveAmmo(self.Ammo[2], self.Ammo[1])
			self:Remove()
		end
	end
end