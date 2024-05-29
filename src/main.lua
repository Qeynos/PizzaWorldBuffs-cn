PizzaWorldBuffs = CreateFrame('Frame', 'PizzaWorldBuffs', UIParent)
local PWB = PizzaWorldBuffs
PWB.abbrev = 'PWB'

-- If many players are using the addon and we're unlucky, we mayb never be able to publish our timers, because
-- someone else will publish theirs before us every time. To combat this and allow everyone to publish their
-- timers eventually, we use a publish interval upper limit. If this runs out, we just blindly publish our 
-- timers regardless, even if someone else publishes theirs before us again.
PWB.maxPublishIntervalMinutes = 3

PWB.Colors = {
  primary = '|cffa050ff',
  secondary = '|cffffffff',

  alliance = '|cff0070dd',
  horde = '|cffc41e3a',
  white = '|cffffffff',
  grey = '|cffaaaaaa',
  green = '|cff00ff98',
  orange = '|cffff7c0a',
  red = '|cffc41e3a',
}

PWB.Bosses = {
  O = 'Onyxia',
  N = 'Nefarian',
}

function PWB:Print(msg, withPrefix)
  local prefix = withPrefix == false and '' or PWB.Colors.primary .. 'Pizza' .. PWB.Colors.secondary .. 'WorldBuffs:|r '
  DEFAULT_CHAT_FRAME:AddMessage(prefix .. msg)
end

function PWB:PrintClean(msg)
  PWB:Print(msg, false)
end

local timerStrs = {}
PWB:RegisterEvent('ADDON_LOADED')
PWB:RegisterEvent('PLAYER_ENTERING_WORLD')
PWB:RegisterEvent('CHAT_MSG_ADDON')
PWB:RegisterEvent('CHAT_MSG_CHANNEL')
PWB:RegisterEvent('CHAT_MSG_MONSTER_YELL')
PWB:SetScript('OnEvent', function ()
  if event == 'ADDON_LOADED' and arg1 == 'PizzaWorldBuffs' then
    if PWB_config.autoLogout then
      PWB_config.autoLogout = false
      PWB:Print('自动登出功能已自动禁用。要再次启用，请使用 /wb logout 1')
    end
  end

  if event == 'PLAYER_ENTERING_WORLD' then
    -- Store player's name & faction ('A' or 'H') for future use
    PWB.me = UnitName('player')
    PWB.myFaction = string.sub(UnitFactionGroup('player'), 1, 1)

    -- Initialize config with default values if necessary
    PWB.config.init()

    -- If we don't have any timers or we still have timers in a deprecated format, clear/initialize them first.
    if not PWB.utils.hasTimers() or PWB.utils.hasDeprecatedTimerFormat() then
      PWB.core.clearAllTimers()
    end

    -- Publish our timers once whenever we log in
    PWB.core.publishTimers()

    -- Trigger delayed joining of the PWB chat channel if sharing is enabled
    if PWB_config.sharingEnabled then
      PWB.channelJoinDelay:Show()
    end
  end

  if event == 'CHAT_MSG_MONSTER_YELL' then
    local boss, faction = PWB.core.parseMonsterYell(arg1)
    if boss and faction then
      local h, m = PWB.utils.hoursFromNow(2)
      PWB.core.setTimer(faction, boss, h, m, PWB.me, PWB.me)

      if PWB_config.autoLogout then
        PWB:Print('即将收到增益效果，自动登出已启用。将在1分钟后登出。')
        PWB.logoutAt = time() + 60
      end
    end
  end

  if event == 'CHAT_MSG_CHANNEL' and arg2 ~= UnitName('player') then
    if not PWB_config.sharingEnabled then return end

    local _, _, source = string.find(arg4, '(%d+)%.')
    local channelName

    if source then
      _, channelName = GetChannelName(source)
    end

    if channelName == PWB.channelName then
      local addonName, remoteVersion, msg = PWB.utils.strSplit(arg1, ':')
      if addonName == PWB.abbrev then
        -- Ignore timers from players with pre-1.1.4 versions that contain a bug where it sometimes
        -- shares invalid/expired timers with everyone.
        if tonumber(remoteVersion) < 10104 then
          return
        end

        PWB.core.resetPublishDelay()

        timerStrs[1], timerStrs[2], timerStrs[3], timerStrs[4] = PWB.utils.strSplit(msg, ';')
        for _, timerStr in next, timerStrs do
          local faction, boss, h, m, witness = PWB.core.decode(timerStr)
          if not faction or not boss or not h or not m or not witness then return end

          local receivedFrom = arg2
          if PWB.core.shouldAcceptNewTimer(faction, boss, h, m, witness, receivedFrom) then
            PWB.core.setTimer(faction, boss, h, m, witness, receivedFrom)
          end
        end

        if tonumber(remoteVersion) > PWB.utils.getVersionNumber() and not PWB.updateNotified then
          PWB:Print('新版本可用，请更新以获得更准确的计时器！https://github.com/Pizzahawaiii/PizzaWorldBuffs')
          PWB.updateNotified = true
        end
      end
    end
  end
end)

PWB:SetScript('OnUpdate', function ()
  -- Throttle this function so it doesn't run on every frame render
  if (this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

  PWB.core.clearExpiredTimers()

  if PWB_config.autoLogout and PWB.logoutAt and time() >= PWB.logoutAt then
    PWB.logoutAt = nil
    PWB.core.publishTimers()
    if PWB_config.setQuit then
      PWB:Print('正在退出...')
      Quit()
    else
      PWB:Print('正在登出...')
      Logout()
    end
  elseif PWB.core.shouldPublishTimers() then
    PWB.core.publishTimers()
  end
end)
