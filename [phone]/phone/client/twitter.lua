local patt = "[?!@#]"
RegisterNetEvent('qb-phone:client:GetMentioned')
AddEventHandler('qb-phone:client:GetMentioned', function(TweetMessage, AppAlerts)
    if PhoneData.MetaData.internet and PhoneData.MetaData.settings.twitter.account.logged then
        Config.PhoneApplications["twitter"].Alerts = AppAlerts
        if PhoneData.MetaData.settings.twitter.notifications["mention-notification"] then
            SendNUIMessage({
                action = "PhoneNotification",
                PhoneNotify = {
                    title = "You have been mentioned in a Tweet!",
                    text = TweetMessage.message, icon = "fab fa-twitter",
                    color = "#1DA1F2",
                },
            })
        end
        table.insert(PhoneData.MentionedTweets, TweetMessage)
        SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
        SendNUIMessage({ action = "UpdateMentionedTweets", Tweets = PhoneData.MentionedTweets })
    end
end)

RegisterNetEvent('qb-phone:client:UpdateTweets')
AddEventHandler('qb-phone:client:UpdateTweets', function(NewTweetData)
    if PhoneData.MetaData.settings ~= nil then
        local twitterID = PhoneData.MetaData.settings.twitter.account.twitterID
        if NewTweetData ~= nil then
            table.insert(PhoneData.Tweets, NewTweetData)
            if PhoneData.MetaData.internet and PhoneData.MetaData.settings.twitter.account.logged then
                if NewTweetData.twitterID ~= twitterID then
                        SendNUIMessage({
                            action = "PhoneNotification",
                            PhoneNotify = {
                                title = "New Tweet (@"..NewTweetData.name..")",
                                text = NewTweetData.message,
                                icon = "fab fa-twitter",
                                color = "#1DA1F2",
                                timeout = 2500,
                            },
                        })
                else
                    SendNUIMessage({
                        action = "PhoneNotification",
                        PhoneNotify = {
                            title = "Twitter",
                            text = "The Tweet has been posted!",
                            icon = "fab fa-twitter",
                            color = "#1DA1F2",
                            timeout = 1000,
                        },
                    })
                end
            end
        end
        SendNUIMessage({
            action = "UpdateTwitter"
        })
        --Utils.DumpTable(PhoneData.Tweets)
    end
end)

RegisterNetEvent('qb-phone:client:updateImagesAll')
AddEventHandler('qb-phone:client:updateImagesAll', function(twitterID, profilepicture)
    for k, v in each(PhoneData.Tweets) do
        if v.twitterID == twitterID then
            PhoneData.Tweets[k].picture = profilepicture
        end
    end

    SendNUIMessage({
        action = "UpdateTwitter"
    })
end)

RegisterNetEvent('qb-phone:client:updateAllTweets')
AddEventHandler('qb-phone:client:updateAllTweets', function(tweets)
    if PhoneData.MetaData.settings ~= nil then
        PhoneData.Tweets = tweets
        SendNUIMessage({
            action = "UpdateTwitter"
        })
    end
end)

RegisterNetEvent('qb-phone:client:UpdateHashtags')
AddEventHandler('qb-phone:client:UpdateHashtags', function(messageData)
    if PhoneData.MetaData.internet and PhoneData.MetaData.settings.twitter.account.logged then
        local Handle = messageData.hashtag_handle
        local HashTags = messageData.hashtag
        if PhoneData.Hashtags[Handle] ~= nil and next(PhoneData.Hashtags[Handle]) ~= nil then
            table.insert(PhoneData.Hashtags[Handle].messages, messageData)
        else
            PhoneData.Hashtags[Handle] = {
                hashtag_handle = Handle,
                hashtag = HashTags,
                messages = {}
            }
            table.insert(PhoneData.Hashtags[Handle].messages, messageData)
        end
        SendNUIMessage({
            action = "UpdateHashtags",
            Hashtags = PhoneData.Hashtags,
        })
    end
end)

RegisterNetEvent('qb-phone:client:EditTweets')
AddEventHandler('qb-phone:client:EditTweets', function(Update)
    if PhoneData.MetaData.internet and PhoneData.MetaData.settings.twitter.account.logged then

        if Update.Tweet then
            for k, v in each(PhoneData.Tweets) do
                if v.tweetID == Update.Tweet.tweetID then
                    PhoneData.Tweets[k] = Update.Tweet
                    break
                end
            end
        end
        --Utils.DumpTable(Update)
        --Utils.DumpTable(PhoneData.MentionedTweets)
        if type(Update.Mention) ~= "number" then
            if next(Update.Mention) and next(PhoneData.MentionedTweets) then
                for k, v in each(PhoneData.MentionedTweets) do
                    if v.tweetID == Update.Tweet.tweetID then
                        PhoneData.MentionedTweets[k] = Update.Tweet
                        break
                    end
                end
            end
        end

        if Update.hashtags ~= "null" then
            for k, v in each(PhoneData.Hashtags[Update.hashtags].messages) do
                if v.tweetID == Update.Tweet.tweetID then
                    PhoneData.Hashtags[Update.hashtags].messages[k] = Update.Tweet
                    break
                end
            end
        end

        SendNUIMessage({
            action = "UpdateTwitter"
        })
    end
end)


RegisterNUICallback('EditTweet', function(data, cb)
    local tweetID = data.tweetID
    local twitterID = PhoneData.MetaData.settings.twitter.account.twitterID
    local action = data.action
    local found = false
    local tweet = false
    for k, v in each(PhoneData.Tweets) do
        if v.tweetID == tweetID then
            tweet = PhoneData.Tweets[k]
            for _, like in each(PhoneData.Tweets[k].likes) do
                if like == twitterID then
                    found = true
                    break
                end
            end
            break
        end
    end
    if tweet then
        if action == "like" then
            if not found then
                table.insert(tweet.likes, twitterID)
            else
                newLikes = {}
                for _, like in each(tweet.likes) do
                    if like ~= twitterID then
                        table.insert(newLikes, like)
                    end
                end
                tweet.likes = newLikes
            end
        elseif action == "delete" then
            tweet.deleted = true
        end
        TriggerServerEvent("qb-phone:server:EditTweets", tweet)
    end
end)

RegisterNUICallback('SetTwitterSettings', function(data, cb)
    PhoneData.MetaData.settings.twitter = data.TwitterSettings
    cb(data.TwitterSettings)
    TriggerServerEvent("qb-phone:server:SaveMetaData", PhoneData.MetaData.id, PhoneData.MetaData.settings)
end)

RegisterNUICallback('EditTwitterAcc', function(data, cb)
    local userData = {
        ip = PhoneData.MetaData.ip,
        location = getLocation(),
        player = exports.data:getCharVar('id'),
        phone = PhoneData.MetaData.id
    }
    TriggerServerEvent("qb-phone:server:EditTwitter", data.data, userData)
    RegisterNetEvent('qb-phone:client:EditTwitter')
    AddEventHandler('qb-phone:client:EditTwitter', function(status)
        cb(status)
    end)
end)

RegisterNUICallback('CreateTwitterAcc', function(data, cb)
    local userData = {
        ip = PhoneData.MetaData.ip,
        location = getLocation(),
        player = exports.data:getCharVar('id'),
        phone = PhoneData.MetaData.id
    }
    TriggerServerEvent("qb-phone:server:CreateTwitterAcc", data.data, userData)
    RegisterNetEvent('qb-phone:client:CreateTwitterAcc')
    AddEventHandler('qb-phone:client:CreateTwitterAcc', function(status)
        cb(status)
    end)
end)

RegisterNUICallback('LogInTwitter', function(data, cb)
    local userData = {
        ip = PhoneData.MetaData.ip,
        location = getLocation(),
        player = exports.data:getCharVar('id'),
        phone = PhoneData.MetaData.id
    }
    TriggerServerEvent("qb-phone:server:LogInTwitter", data.data, userData)
    RegisterNetEvent('qb-phone:client:LogInTwitter')
    AddEventHandler('qb-phone:client:LogInTwitter', function(status, error)
        cb({ status, error })
    end)
end)

RegisterNUICallback('SignOutTwitter', function(data, cb)
    local userData = {
        ip = PhoneData.MetaData.ip,
        location = getLocation(),
        player = exports.data:getCharVar('id'),
        phone = PhoneData.MetaData.id
    }
    TriggerServerEvent("qb-phone:server:SignOutTwitter", data.data, userData)
    RegisterNetEvent('qb-phone:client:SignOutTwitter')
    AddEventHandler('qb-phone:client:SignOutTwitter', function(status)
        cb(status)
    end)
end)

RegisterNUICallback('PostNewTweet', function(data)
    data.Message = escape_str(data.Message)
    data['data'] = {
        ip = PhoneData.MetaData.ip,
        location = getLocation(),
        player = exports.data:getCharVar('id'),
        phone = PhoneData.MetaData.id
    }
    TriggerServerEvent('qb-phone:server:UpdateTweets', data)
    --AddEventHandler('qb-phone:client:TweetSend', function()
    --    dataDone = true
    --end)
    --while true do if dataDone then dataDone = false break else Citizen.Wait(0) end end
end)

RegisterNUICallback('GetHashtags', function(data, cb)
    if PhoneData.Hashtags ~= nil and next(PhoneData.Hashtags) ~= nil then
        cb(PhoneData.Hashtags)
    else
        cb(nil)
    end
end)

RegisterNUICallback('ClearMentions', function()
    Config.PhoneApplications["twitter"].Alerts = 0
    SendNUIMessage({
        action = "RefreshAppAlerts",
        AppData = Config.PhoneApplications
    })
    TriggerServerEvent('qb-phone:server:SetPhoneAlerts', "twitter", 0)
    SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
end)

RegisterNUICallback('GetTweets', function(data, cb)
    cb(PhoneData.Tweets)
end)

RegisterNUICallback('GetHashtagMessages', function(data, cb)
    if PhoneData.Hashtags[data.hashtag] ~= nil and next(PhoneData.Hashtags[data.hashtag]) ~= nil then
        cb(PhoneData.Hashtags[data.hashtag])
    else
        cb(nil)
    end
end)

RegisterNUICallback('GetMentionedTweets', function(data, cb)
    cb(PhoneData.MentionedTweets)
end)

function escape_str(s)
    -- local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
    -- local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
    -- for i, c in each(in_char) do
    --   s = s:gsub(c, '\\' .. out_char[i])
    -- end
    return s
end