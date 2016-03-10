# guardian-bot

To install (in any directory)
```
git clone https://github.com/h3adache/guardian-bot.git
cd guardian-bot
npm install
npm link
```

Now in your hubot root directory
```
npm link hubot-guardian
```

Open (or create) external-scripts.json and add hubot-guardian
For example if you are adding this to the base hubot it would look like:
```
[
  "hubot-diagnostics",
  "hubot-help",
  "hubot-heroku-keepalive",
  "hubot-google-images",
  "hubot-google-translate",
  "hubot-pugme",
  "hubot-maps",
  "hubot-redis-brain",
  "hubot-rules",
  "hubot-shipit",
  "hubot-guardian"
]
```

restart hubot
