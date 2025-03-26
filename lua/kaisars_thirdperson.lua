while (true) do
    local offset = Player:GetViewOffset().z
    LocalPlayer():SetViewOffset(Vector3(0, 0, offset))
end