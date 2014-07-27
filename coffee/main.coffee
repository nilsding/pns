###
# P.N.S
# A small, but fun game with toasters and clocks.
# (c) 2011-2014 nilsding
#
# Special thanks to:
#  @pixeldesu / @s4tori for some graphics
#  @Jim_Clonk for the game idea
###

canvas = null
ctx = null
gameControlButton = null

newObject = (x, y, width, height) ->
  posX: x
  posY: y
  velX: 0
  velY: 0
  width: width
  height: height
  image: new Image()
  # if the object needs clipping (such as sprites), these variables can be used:
  sX: 0
  sY: 0
  sWidth: width
  sHeight: height
  # additional keys for sprites:
  sprite:
    row: 0
    column: 0

newSprite = (rows, cols, width, height) ->
  width: width
  height: height
  rows: rows
  columns: cols
  image: new Image()

gameVars =
  version: "0.4"
  isRunning: false
  ticks: 60
  points: 0
  lives: 5
  maxLives: 5

gameCanvas =
  width: 800
  height: 600

gameField =
  posX: 0
  posY: 64
  width: gameCanvas.width
  height: gameCanvas.height - 64
  background: new Image()

statusbar =
  posX: 0
  posY: 0
  width: gameCanvas.width
  height: gameField.posY
  gradient: null
  colourTop: "#555555"
  colourBottom: "#323232"
  
sprites =
  sprite: newSprite 8, 8, 32, 32

text =
  sprite: newSprite 2, 10, 27, 23

title =
  opened: false
  top: newObject 0, 0, 800, 300
  bottom: newObject 0, 300, 800, 300

toaster = newObject 25, title.top.height - (188 / 2), 188, 148

clock = newObject 600, 100, 128, 128

laser = 
  image: new Image()
  objects: []
  isActive: false

explosion =
  sprite: newSprite 1, 27, 78, 81
  objects: []

sounds =
  music: new SeamlessLoop()
  explosion: new Audio()
  shoot: new Audio()

init = ->
  unless window.localStorage['highscore']?
    window.localStorage['highscore'] = 0
  unless window.localStorage['musicEnabled']?
    window.localStorage['musicEnabled'] = true
  
  canvas = document.getElementById 'gameField'
  ctx = canvas.getContext '2d'

  gameField.background.src = './img/background.png'
  toaster.image.src = './img/toaster.png'
  clock.image.src = './img/clock.png'
  title.top.image.src = './img/title_top.png'
  title.bottom.image.src = './img/title_bottom.png'
  laser.image.src = './img/laser.png'
  text.sprite.image.src = './img/nums.png'
  explosion.sprite.image.src = './img/explosion.png'
  sprites.sprite.image.src = './img/sprites.png'
  
  sounds.music.addUri './snd/music.ogg', 21607, "music"
  sounds.music.callback ->
    if window.localStorage['musicEnabled'] == "true"
      sounds.music.start("music")
  
  statusbar.gradient = ctx.createLinearGradient 0, 0, 0, statusbar.height
  statusbar.gradient.addColorStop 0, statusbar.colourTop
  statusbar.gradient.addColorStop 1, statusbar.colourBottom
  
  #gameControlButton = document.getElementById 'gameControlButton'
  #gameControlButton.innerHTML = "Start Game"
  #gameControlButton.onclick = startGame
  
  document.onkeydown = keydownhandler
  document.onkeyup = keyuphandler
  
  resetGame()
  render()

drawNumbers = (num, pad, posX, posY) ->
  numberStr = (Array(pad + 1).join("0") + num).substr(-pad, pad)
  spriteX = 0
  spriteY = 0
  for c in numberStr
    spriteX = Number(c) * text.sprite.width
    ctx.drawImage text.sprite.image, spriteX, spriteY, text.sprite.width, text.sprite.height, posX, posY, text.sprite.width, text.sprite.height
    posX += text.sprite.width - 5

drawSprite = (spr, x, y, posX, posY) ->
  spriteX = x * spr.sprite.width
  spriteY = y * spr.sprite.height
  ctx.drawImage spr.sprite.image, spriteX, spriteY, spr.sprite.width, spr.sprite.height, posX, posY, spr.sprite.width, spr.sprite.height

render = ->
  ctx.clearRect 0, 0, gameCanvas.width, gameCanvas.height
  ctx.drawImage gameField.background, gameField.posX, gameField.posY, gameField.width, gameField.height
  
  ctx.fillStyle = statusbar.gradient
  ctx.fillRect statusbar.posX, statusbar.posY, statusbar.width, statusbar.height
  
  for i in [0..1]
    for j in [1..2]
      drawSprite sprites, i, j, i * sprites.sprite.width, (j - 1) * sprites.sprite.height
  
  # score
  for i in [0..2]
    drawSprite text, i, 1, statusbar.width - 12 - (3 * text.sprite.width) + (i * text.sprite.width), 0
  drawNumbers gameVars.points, 8, statusbar.width - 10 - (7 * text.sprite.width), text.sprite.height + 5
  
  # hiscore
  for i in [3..6]
    drawSprite text, i, 1, statusbar.width - 12 - (14 * text.sprite.width) + (i * text.sprite.width), 0
  drawNumbers window.localStorage['highscore'], 8, statusbar.width - 10 - (14 * text.sprite.width), text.sprite.height + 5
  
  # lives
  for i in [7..9]
    drawSprite text, i, 1, statusbar.width - 12 - (25 * text.sprite.width) + (i * text.sprite.width), 0
  
  for i in [0...gameVars.maxLives]
    drawSprite sprites, 1, 0, statusbar.width - 12 - (18 * sprites.sprite.width) + (i * (sprites.sprite.width + 3)), text.sprite.height + 5
  
  for i in [0...gameVars.lives]
    drawSprite sprites, 0, 0, statusbar.width - 12 - (18 * sprites.sprite.width) + (i * (sprites.sprite.width + 3)), text.sprite.height + 5
  
  for obj in explosion.objects
    ctx.drawImage obj.image, obj.sX, obj.sY, obj.sWidth, obj.sHeight, obj.posX, obj.posY, obj.width, obj.height
  
  for obj in laser.objects
    ctx.drawImage obj.image, obj.posX, obj.posY, obj.width, obj.height
  
  for obj in [clock, toaster, title.top, title.bottom]
    ctx.drawImage obj.image, obj.posX, obj.posY, obj.width, obj.height
  
  window.requestAnimationFrame render

keydownhandler = (event) ->
  switch event.keyCode
    when 77 # M (music on/off)
      if window.localStorage['musicEnabled'] == "true"
        sounds.music.stop("music")
        window.localStorage['musicEnabled'] = false
      else
        sounds.music.start("music")
        window.localStorage['musicEnabled'] = true
  
  unless gameVars.isRunning
    switch event.keyCode
      when 32 # space bar  (title screen)
        document.getElementById('info').style.display = "none"
        startGame()
  else
    switch event.keyCode
      when 32 # space bar  (DER TOTALE LASER)
        event.preventDefault()
        if not laser.isActive and laser.objects.length < 5
          shootLaser()
          laser.isActive = true
      when 37 # left
        event.preventDefault()
        toaster.velX = -5
      when 38 # up
        event.preventDefault()
        toaster.velY = -5
      when 39 # right
        event.preventDefault()
        toaster.velX = +5
      when 40 # down
        event.preventDefault()
        toaster.velY = +5
      when 19, 80 # <Pause> and <P> for stopping the game
        document.getElementById('info').style.display = ""
        stopGame()

keyuphandler = (event) ->
  return unless gameVars.isRunning
  switch event.keyCode
    when 37, 39 # left, right
      event.preventDefault()
      toaster.velX = 0
    when 38, 40 # up, down
      event.preventDefault()
      toaster.velY = 0
    when 32 # space bar
      laser.isActive = false

collide = (a, b) -> not ((b.posX > a.posX + a.width) or
                         (b.posX + b.width < a.posX) or
                         (b.posY > a.posY + a.height) or
                         (b.posY + b.height < a.posY))

shootLaser = ->
  # create a new laser object
  _laser = newObject 0, 0, 71, 71
  _laser.image = laser.image
  
  _laser.posX = Math.floor(toaster.posX + toaster.width - _laser.width)
  _laser.posY = Math.floor(toaster.posY + toaster.height / 2 - _laser.height / 2)
  _laser.velX = 5
  _laser.velY = 0
  laser.objects.push _laser

newExplosion = (x, y) ->
  _explosion = newObject x, y, explosion.sprite.width, explosion.sprite.height
  _explosion.image = explosion.sprite.image
  _explosion.sprite.row = 0
  _explosion.sprite.column = 0
  
  explosion.objects.push _explosion

openTitle = ->
  if title.top.posY < (-title.top.height)
    title.opened = true
    return
  
  title.top.posY -= 15
  title.bottom.posY += 15

  window.setTimeout openTitle, 1000 / gameVars.ticks

closeTitle = ->
  if title.top.posY is 0
    title.opened = false
    return
  
  title.top.posY += 15
  title.bottom.posY -= 15

  window.setTimeout closeTitle, 1000 / gameVars.ticks

gameLoop = ->
  return unless gameVars.isRunning
  newX = toaster.posX + toaster.velX
  newY = toaster.posY + toaster.velY
  if newX < gameField.width + gameField.posX - toaster.width and newX > 0 + gameField.posX
    toaster.posX = newX
  if newY < gameField.height + gameField.posY - toaster.height and newY > 0 + gameField.posY
    toaster.posY = newY
  
  newX = (clock.posX -= 5)
  
  if newX < -200 or collide toaster, clock
    # maybe remove some points
    newExplosion clock.posX, clock.posY
    clock.posX = 800
    clock.posY = Math.floor (Math.random() * 1000) % (gameField.height - clock.height) + gameField.posY
    gameVars.lives--
  
  for l, i in laser.objects
    continue unless l?
    newX = l.posX + l.velX
    if newX < gameField.width + gameField.posX
      l.posX = newX
      # collision detection!!!!
      if collide(l, clock)
        gameVars.points += Math.round(100 / laser.objects.length)
        updateTitlebar()
        if Number(window.localStorage['highscore']) < gameVars.points
          window.localStorage['highscore'] = gameVars.points
        laser.objects.splice i, 1
        newExplosion clock.posX, clock.posY
        clock.posX = 800
        clock.posY = Math.floor (Math.random() * 1000) % (gameField.height - clock.height) + gameField.posY
    else
      laser.objects.splice i, 1
  
  for e, i in explosion.objects
    continue unless e?
    unless e.sprite.column is explosion.sprite.columns
      e.sprite.column++
      e.sX = e.sprite.column * explosion.sprite.width
    else
      explosion.objects.splice i, 1
      
  # check whether the game is over
  if gameVars.lives is 0
    stopGame()
    resetGame()
  
  window.setTimeout gameLoop, 1000 / gameVars.ticks

startGame = ->
  # nilsding's Professional Pause-Key Service™
#   resetGame()
  openTitle()
  gameVars.isRunning = true
  gameLoop()

stopGame = ->
  #gameControlButton.innerHTML = "Start Game"
  #gameControlButton.onclick = startGame
  closeTitle()
  gameVars.isRunning = false

resetGame = ->
  gameVars.points = 0
  gameVars.lives = gameVars.maxLives
  toaster.velX = 0
  toaster.velY = 0
  toaster.posX = 25
  toaster.posY = title.top.height - (188 / 2)
  clock.posX = 600
  clock.posY = 100
  laser.objects = []
  explosion.objects = []
  updateTitlebar()

updateTitlebar = (spacer="&nbsp;&nbsp;&nbsp;||&nbsp;&nbsp;&nbsp;") ->
  titlebar = document.getElementById "title"
  titlebar.innerHTML = "P.N.S #{gameVars.version}#{spacer}Score: #{gameVars.points}#{spacer}Highscore: #{window.localStorage['highscore']}"

window.onload = init

# kate: indent-width 2