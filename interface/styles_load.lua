local n_name, NeP          = ...

function NeP.Interface:UpdateStyles()
	local ClassColor = NeP.Core:ClassColor('player', 'hex')
	--outline_color
	local outline_default = self.WindowStyleSheet['frame-outline'].color
	local outline = NeP.Config:Read(n_name..'_Settings', 'outline_color', outline_default)
	if outline == 'CLASS' then outline = ClassColor end
	self.WindowStyleSheet['frame-outline'].color = outline
	--tittle_color
	local tittle_default = self.WindowStyleSheet['titleBar-color'].color
	local tittle = NeP.Config:Read(n_name..'_Settings', 'tittle_color', tittle_default)
	if tittle == 'CLASS' then tittle = ClassColor end
	self.WindowStyleSheet['titleBar-color'].color = tittle
	--tittle_alpha
	local tittle_alpha_default = self.WindowStyleSheet['titleBar-color'].alpha
	local tittle_alpha = NeP.Config:Read(n_name..'_Settings', 'tittle_alpha', tittle_alpha_default)
	self.WindowStyleSheet['titleBar-color'].alpha = tittle_alpha
	--content_color
	local content_default = self.WindowStyleSheet['content-background'].color
	local content = NeP.Config:Read(n_name..'_Settings', 'content_color', content_default)
	if content == 'CLASS' then content = ClassColor end
	self.WindowStyleSheet['content-background'].color = content
	--content_alpha
	local content_alpha_default = self.WindowStyleSheet['content-background'].alpha
	local content_alpha = NeP.Config:Read(n_name..'_Settings', 'content_alpha', content_alpha_default)
	self.WindowStyleSheet['content-background'].alpha = content_alpha
	--Loop
	for _,v in pairs(self.usedGUIs) do
		v.parent:SetStylesheet(self.WindowStyleSheet)
	end
end
