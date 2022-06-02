local font = RegisterFontId("AMSANSL")

function DrawText3D(x, y, z, text, withrect, textscale)
	local usez = z + 0.3
	local onScreen, _x, _y = World3dToScreen2d(x, y, usez)
	local px, py, pz = table.unpack(GetGameplayCamCoords())

	textscale = (textscale == nil and 0.25 or textscale)
	SetTextScale(textscale, textscale)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextFont(font)
	SetTextOutline(1)
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x, _y)
	if withrect == nil or withrect == true then 
		local factor = (utf8.len(text)) / 400
		DrawRect(_x, _y + 0.01, 0.015 + factor, 0.03, 17, 5, 17, 150)
	end	
end