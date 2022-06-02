function createNewKeyMapping(mappingData)
    RegisterKeyMapping(
        mappingData.command,
        "<FONT FACE='AMSANSL'>" .. mappingData.text .. "</FONT>",
        mappingData.mapper == nil and "keyboard" or mappingData.mapper,
        mappingData.key
    )
end
