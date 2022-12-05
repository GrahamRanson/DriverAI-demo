local imageSuffix =
{
    ["@2x"] = 1.5,
    ["@3x"] = 3.0,
    ["@4x"] = 4.0,
}

local aspectRatio = 1024 / 768

if display then
    aspectRatio = display.pixelHeight / display.pixelWidth or 1.5
end

application =
{
    content =
    {
        width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
        height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),
        scale = "letterBox",
        fps = 60,
        imageSuffix = imageSuffix
    }
}
