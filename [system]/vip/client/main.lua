Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        exports.chat:addSuggestion(
            "/claimBankAccount",
            "Přidá Vámi zadaný počet bankovních účtů postavě",
            {
                {name = "číslo", help = "Počet bankovních účtů k vyzvednutí"}
            }
        )
        exports.chat:addSuggestion(
            "/claimVehiclePlate",
            "Přidá Vámi zadanou SPZ vašemu vozidlu",
            {
                {name = "SPZ", help = "Stará SPZ vozidla"},
                {name = "SPZ", help = "Nová SPZ vozidla"}
            }
        )
        
        TriggerEvent("chat:removeSuggestion", "/addQueuePoints")
        TriggerEvent("chat:removeSuggestion", "/addBankAccount")
        TriggerEvent("chat:removeSuggestion", "/addVehiclePlate")
    end
)