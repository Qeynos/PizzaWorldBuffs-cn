# 🍕 PizzaWorldBuffs

Addon for [TurtleWoW](https://turtle-wow.org) that shows Onyxia/Nefarian head cooldown timers.

<img src="https://raw.githubusercontent.com/Pizzahawaiii/PizzaWorldBuffs/main/img/frame.png">

## ⚠️ Disclaimer

**The addon does not track the time until the next buff will be triggered!** It only tracks the time
until the **window** for the buff to be triggered will open up again, i.e. when the Ony/Nef heads
will disappear from the Stormwind/Orgrimmar city gates again. The actual buff is only triggered when 
a player turns in the head of Onyxia/Nefarian and the addon can't possibly know when that's going to 
happen.

## Install

1. Download and extract [latest version](https://github.com/Pizzahawaiii/PizzaWorldBuffs/archive/main.zip)
2. Copy the "PizzaWorldBuffs-main" folder to `<WoW>/Interface/AddOns` and rename it to "PizzaWorldBuffs"
3. (Re)start WoW

## Commands

```
/wb                 - Show all commands
/wb clear           - Delete all timers
/wb all <0 or 1>    - 0 to only show timers for your faction, 1 to show timers for both factions
/wb fontSize <size> - Change the font size of the PizzaWorldBuff frame (Default: 14)
```

## How it Works

PizzaWorldBuffs constantly communicates with every other player who's also using the addon. If you're
in Stormwind or Orgrimmar while the dragonslayer buff is triggered, the addon starts tracking its
cooldown and constantly shares that information with all other players in the background so everyone
can see the timer, even if they didn't witness the buff being triggered themselves. This implicates that
if nobody using the addon witnesses the buff being triggered, nobody will get a timer for that specific
buff. Therefore, the more players are using the addon the better, as it increases the likelihood of
someone with the addon witnessing the buff.

### Color-Coding

A boss name's color designates the faction/city where the buff was triggered:

- **Blue:** Alliance (Stormwind)
- **Red:** Horde (Orgrimmar)

The color of the timer itself denotes how confident the addon is in the correctness of that specific
timer:

- **Green:** High confidence *(You have witnessed that buff yourself)*
- **Orange:** Medium confidence *(The person you received the timer from has witnessed that buff themselves)*
- **Red:** Low confidence *(Neither you nor the person you received the timer from have actually witnessed that buff)*

### Timer Prioritization

The addon only accepts timers it receives from other players if it has the same or higher confidence
in them than in your current timer for the respective boss/faction. If you currently don't have any
timer for that boss/faction, the addon accepts any timer it receives. Timers you witnessed yourself
are always accepted.

### Timer Storing & Sharing

Timers are stored persistently, so you will keep your timers even after relogging. Also, timers are
(eventually) propagated to and reshared by everyone who's using the addon. So timers that haven't
expired yet will continue to be shared automatically, even if the player who originally witnessed
the buff has logged off already.

## FAQ

### Q: Why don't I have a timer even though someone told me that buff just triggered?

Most likely because the person who told you doesn't use this addon, see [How it Works](#how-it-works).

### Q: But I know they're using this addon. Why do they have a timer and I don't?

It can take some time for a new timer to be shared with other players, so you might have to wait a
few minutes.

### Q: I don't see the new timer even after waiting for a few minutes, but other/older timers work fine. WTF?

Please [create an issue](https://github.com/Pizzahawaiii/PizzaWorldBuffs/issues/new). 

The timer sharing logic is not very sophisticated. We don't want everyone to always share their 
timers to avoid spam and the person who gets to share their timers next is essentially picked at 
random. The more players are using the addon the less likely each individual player will be allowed 
to share their timers. We might have hit the critical mass where some players never get to share
their timers if they're unlucky.

### Q: Wait a second, I actually never see a single timer. Why?

Try relogging or running `/join PizzaWorldBuffs`. If that doesn't help, please 
[create an issue](https://github.com/Pizzahawaiii/PizzaWorldBuffs/issues/new).

The addon uses a hidden chat channel named `PizzaWorldBuffs` to receive data from and share data with
other players. It should automatically join that channel whenever the addon is loaded. But if it doesn't,
maybe one of your other addons is interfering. You can check if you're in that channel by right-clicking
your chat tab and selecting "Channels". You can also try disabling all other addons.

### Q: What's the best pizza topping?

🍍