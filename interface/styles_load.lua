local n_name, NeP          = ...

function NeP.Interface:UpdateStyles()
	local ClassColor = NeP.Core:ClassColor('player', 'hex')
	local tmp1;
	--outline_color
	tmp1 = self.WindowStyleSheet['frame-outline'].color
	tmp1 = NeP.Config:Read(n_name..'_Settings', 'outline_color', tmp1)
	if tmp1 == 'CLASS' then tmp1 = ClassColor end
	self.WindowStyleSheet['frame-outline'].color = tmp1
	NeP.Interface:SetElementColor(tmp1)
	--tittle_color
	tmp1 = self.WindowStyleSheet['titleBar-color'].color
	tmp1 = NeP.Config:Read(n_name..'_Settings', 'tittle_color', tmp1)
	if tmp1 == 'CLASS' then tmp1 = ClassColor end
	self.WindowStyleSheet['titleBar-color'].color = tmp1
	--tittle_alpha
	tmp1 = self.WindowStyleSheet['titleBar-color'].alpha
	tmp1 = NeP.Config:Read(n_name..'_Settings', 'tittle_alpha', tmp1)
	self.WindowStyleSheet['titleBar-color'].alpha = tmp1
	--content_color
	tmp1 = self.WindowStyleSheet['content-background'].color
	tmp1 = NeP.Config:Read(n_name..'_Settings', 'content_color', tmp1)
	if tmp1 == 'CLASS' then tmp1 = ClassColor end
	self.WindowStyleSheet['content-background'].color = tmp1
	--content_alpha
	tmp1 = self.WindowStyleSheet['content-background'].alpha
	tmp1 = NeP.Config:Read(n_name..'_Settings', 'content_alpha', tmp1)
	self.WindowStyleSheet['content-background'].alpha = tmp1
	--Loop to update existing guis
	for _,gui in pairs(self.usedGUIs) do
		gui.parent:SetStylesheet(self.WindowStyleSheet)
		for _, element in pairs(gui.elements) do
			if element.style then
				element.parent:SetStylesheet(element.style)
				element.parent:ApplySettings()
			end
		end
	end
end
