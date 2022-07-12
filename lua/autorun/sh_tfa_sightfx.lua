if CLIENT then
	local tfa_sightfx_enabled = CreateClientConVar("cl_tfa_sightfx_enabled", 1)
	local tfa_sightfx_vignette_enabled = CreateClientConVar("cl_tfa_sightfx_vignette_enabled", 1)
	local tfa_sightfx_vignette_intensity_initially_multiplier = CreateClientConVar("cl_tfa_sightfx_vignette_intensity_initially_multiplier", 0.5)
	local tfa_sightfx_vignette_intensity_sighted_multiplier = CreateClientConVar("cl_tfa_sightfx_vignette_intensity_sighted_multiplier", 0.25)
	local tfa_sightfx_ca_enabled = CreateClientConVar("cl_tfa_sightfx_ca_enabled", 1)
	local tfa_sightfx_ca_intensity_initially_multiplier = CreateClientConVar("cl_tfa_sightfx_ca_intensity_initially_multiplier", 0)
	local tfa_sightfx_ca_intensity_sighted_multiplier = CreateClientConVar("cl_tfa_sightfx_ca_intensity_sighted_multiplier", 4)

	--Some convars may sounds weird due to my horrible language barrier but I don't give a single fuck about that, It works at least

	RunConsoleCommand("mat_motion_blur_enabled", 1)

	local addmat_r = Material("tfa_sightfx/ca/add_r")
	local addmat_g = Material("tfa_sightfx/ca/add_g")
	local addmat_b = Material("tfa_sightfx/ca/add_b")
	local vgbm = Material("vgui/black")

	local function TFA_SightFX_DrawChroma(rx, gx, bx, ry, gy, by)
		render.UpdateScreenEffectTexture()

		addmat_r:SetTexture("$basetexture", render.GetScreenEffectTexture())
		addmat_g:SetTexture("$basetexture", render.GetScreenEffectTexture())
		addmat_b:SetTexture("$basetexture", render.GetScreenEffectTexture())

		render.SetMaterial(vgbm)
		render.DrawScreenQuad()

		render.SetMaterial(addmat_r)
		render.DrawScreenQuadEx(-rx / 2, -ry / 2, ScrW() + rx, ScrH() + ry)

		render.SetMaterial(addmat_g)
		render.DrawScreenQuadEx(-gx / 2, -gy / 2, ScrW() + gx, ScrH() + gy)

		render.SetMaterial(addmat_b)
		render.DrawScreenQuadEx(-bx / 2, -by / 2, ScrW() + bx, ScrH() + by)
	end
	
	--https://sun9-87.userapi.com/impg/eCD-9b7mayfh2MTgPQae32CPIwETyRscE0bpug/WISKuiyr1lM.jpg?size=604x601&quality=96&sign=317145f427668884d7f728a4ba59c70d&type=album

	hook.Add("RenderScreenspaceEffects", "TFA_SightFX", function()
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
		local ADSProgress = wep.IronSightsProgress

		if not wep.IsTFAWeapon then return end
		if not ply:Alive() then return end
		if not tfa_sightfx_enabled:GetBool() then return end
		if ply:IsNPC() then return end

		local VignetteTexture = surface.GetTextureID("tfa_sightfx/vignette/vignette")

		local SightFXVignetteMultiplier = tfa_sightfx_vignette_intensity_initially_multiplier:GetFloat() + (ADSProgress * -tfa_sightfx_vignette_intensity_sighted_multiplier:GetFloat()) -- 0.5 + (ADSProgress * -0.25)
		local SightFXCAMultiplier = tfa_sightfx_ca_intensity_initially_multiplier:GetFloat() + (ADSProgress * tfa_sightfx_ca_intensity_sighted_multiplier:GetFloat())

		surface.SetTexture(VignetteTexture)
		surface.SetDrawColor(255, 255, 255, 255)

		if tfa_sightfx_vignette_enabled:GetBool() then
			surface.DrawTexturedRect(0 - (ScrW() * SightFXVignetteMultiplier), 0 - (ScrH() * SightFXVignetteMultiplier), ScrW() * (1 + 2 * SightFXVignetteMultiplier), ScrH() * (1 + 2 * SightFXVignetteMultiplier))
		end

		if tfa_sightfx_ca_enabled:GetBool() then
			TFA_SightFX_DrawChroma(8 * SightFXCAMultiplier, 4 * SightFXCAMultiplier, 0 * SightFXCAMultiplier, 4 * SightFXCAMultiplier, 2 * SightFXCAMultiplier, 0 * SightFXCAMultiplier)
		end
	end)
end