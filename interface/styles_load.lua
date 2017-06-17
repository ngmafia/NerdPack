local n_name, NeP          = ...

function NeP.Interface:UpdateStyles()
	--outline_color
	local outline_default = NeP.UI.WindowStyleSheet['frame-outline'].color
	local outline = NeP.Config:Read(n_name..'_Settings', 'outline_color', outline_default)
	if outline == 'CLASS' then outline = NeP.Core:ClassColor('player', 'hex') end
	NeP.UI.WindowStyleSheet['frame-outline'].color = outline
	--tittle_color
	local tittle_default = NeP.UI.WindowStyleSheet['titleBar-color'].color
	local tittle = NeP.Config:Read(n_name..'_Settings', 'tittle_color', tittle_default)
	if tittle == 'CLASS' then tittle = NeP.Core:ClassColor('player', 'hex') end
	NeP.UI.WindowStyleSheet['titleBar-color'].color = tittle
	--tittle_alpha
	local tittle_alpha_default = NeP.UI.WindowStyleSheet['titleBar-color'].alpha
	local tittle_alpha = NeP.Config:Read(n_name..'_Settings', 'tittle_alpha', tittle_alpha_default)
	NeP.UI.WindowStyleSheet['titleBar-color'].alpha = tittle_alpha
	--Loop
	for k,v in pairs(NeP.usedGUIs) do
		v.parent:SetStylesheet(NeP.UI.WindowStyleSheet)
	end
end
