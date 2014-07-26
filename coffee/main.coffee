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

gameVars =
  version: "0.2"
  isRunning: false
  ticks: 60
  points: 0
  lives: 0

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
  logo: newObject(8, 8, 48, 48)

text =
  sprites: new Image()
  spriteWidth: 27
  spriteHeight: 23

title =
  opened: false
  top: newObject 0, 0, 800, 300
  bottom: newObject 0, 300, 800, 300

toaster = newObject 25, title.top.height - (188 / 2), 188, 148

clock = newObject 600, 100, 128, 128

laserImage = new Image()
laserObjects = []
laserActive = false

init = ->
  unless window.localStorage['highscore']?
    window.localStorage['highscore'] = 0
  canvas = document.getElementById 'gameField'
  ctx = canvas.getContext '2d'

  gameField.background.src = './img/background.png'
  toaster.image.src = './img/toaster.png'
  clock.image.src = './img/clock.png'
  title.top.image.src = './img/title_top.png'
  title.bottom.image.src = './img/title_bottom.png'
  laserImage.src = './img/laser.png'
  text.sprites.src = './img/nums.png'
  statusbar.logo.image.src = './img/logo.png'
  
  statusbar.gradient = ctx.createLinearGradient 0, 0, 0, statusbar.height
  statusbar.gradient.addColorStop 0, statusbar.colourTop
  statusbar.gradient.addColorStop 1, statusbar.colourBottom
  
  #gameControlButton = document.getElementById 'gameControlButton'
  #gameControlButton.innerHTML = "Start Game"
  #gameControlButton.onclick = startGame
  
  document.onkeydown = keydownhandler
  document.onkeyup = keyuphandler
  
  updateTitlebar()
  render()

drawNumbers = (num, pad, posX, posY) ->
  numberStr = (Array(pad + 1).join("0") + num).substr(-pad, pad)
  spriteX = 0
  spriteY = 0
  for c in numberStr
    spriteX = Number(c) * text.spriteWidth
    ctx.drawImage text.sprites, spriteX, spriteY, text.spriteWidth, text.spriteHeight, posX, posY, text.spriteWidth, text.spriteHeight
    posX += text.spriteWidth - 5

drawSprite = (x, y, posX, posY) ->
  spriteX = x * text.spriteWidth
  spriteY = y * text.spriteHeight
  ctx.drawImage text.sprites, spriteX, spriteY, text.spriteWidth, text.spriteHeight, posX, posY, text.spriteWidth, text.spriteHeight

render = ->
  ctx.clearRect 0, 0, gameCanvas.width, gameCanvas.height
  ctx.drawImage gameField.background, gameField.posX, gameField.posY, gameField.width, gameField.height
  
  ctx.fillStyle = statusbar.gradient
  ctx.fillRect statusbar.posX, statusbar.posY, statusbar.width, statusbar.height
  
  # score
  for i in [0..2]
    drawSprite i, 1, statusbar.width - 12 - (3 * text.spriteWidth) + (i * text.spriteWidth), 0
  drawNumbers gameVars.points, 8, statusbar.width - 10 - (7 * text.spriteWidth), text.spriteHeight + 5
  
  # hiscore
  for i in [3..6]
    drawSprite i, 1, statusbar.width - 12 - (14 * text.spriteWidth) + (i * text.spriteWidth), 0
  drawNumbers window.localStorage['highscore'], 8, statusbar.width - 10 - (14 * text.spriteWidth), text.spriteHeight + 5
  
  for obj in laserObjects
    ctx.drawImage obj.image, obj.posX, obj.posY, obj.width, obj.height
  
  for obj in [clock, toaster, statusbar.logo, title.top, title.bottom]
    ctx.drawImage obj.image, obj.posX, obj.posY, obj.width, obj.height
  
  window.requestAnimationFrame render

keydownhandler = (event) ->
  unless gameVars.isRunning
    switch event.keyCode
      when 32 # space bar  (title screen)
        document.getElementById('info').style.display = "none"
        startGame()
  else
    switch event.keyCode
      when 32 # space bar  (DER TOTALE LASER)
        event.preventDefault()
        if not laserActive and laserObjects.length < 5
          shootLaser()
          laserActive = true
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
      laserActive = false

collide = (a, b) -> not ((b.posX > a.posX + a.width) or
                         (b.posX + b.width < a.posX) or
                         (b.posY > a.posY + a.height) or
                         (b.posY + b.height < a.posY))

shootLaser = ->
  # create a new laser object
  laser = newObject 0, 0, 71, 71
  laser.image = laserImage
  
  laser.posX = Math.floor(toaster.posX + toaster.width - laser.width)
  laser.posY = Math.floor(toaster.posY + toaster.height / 2 - laser.height / 2)
  laser.velX = 5
  laser.velY = 0
  laserObjects.push laser

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
  
  if newX < -200
    clock.posX = 800
    clock.posY = Math.floor (Math.random() * 1000) % (gameField.height - clock.height) + gameField.posY
  
  for l, i in laserObjects
    continue unless l?
    newX = l.posX + l.velX
    if newX < gameField.width + gameField.posX
      l.posX = newX
      # collision detection!!!!
      if collide(l, clock)
        gameVars.points += Math.round(100 / laserObjects.length)
        updateTitlebar()
        if Number(window.localStorage['highscore']) < gameVars.points
          window.localStorage['highscore'] = gameVars.points
        laserObjects.splice i, 1
        clock.posX = 800
        clock.posY = Math.floor (Math.random() * 1000) % (gameField.height - clock.height) + gameField.posY
    else
      laserObjects.splice i, 1
  
  window.setTimeout gameLoop, 1000 / gameVars.ticks

startGame = ->
  #gameControlButton.innerHTML = "Stop Game"
  #gameControlButton.onclick = stopGame
  openTitle()
  gameVars.isRunning = true
  gameLoop()

stopGame = ->
  #gameControlButton.innerHTML = "Start Game"
  #gameControlButton.onclick = startGame
  closeTitle()
  gameVars.isRunning = false

updateTitlebar = (spacer="&nbsp;&nbsp;&nbsp;||&nbsp;&nbsp;&nbsp;") ->
  titlebar = document.getElementById "title"
  titlebar.innerHTML = "P.N.S #{gameVars.version}#{spacer}Score: #{gameVars.points}#{spacer}Highscore: #{window.localStorage['highscore']}"

window.onload = init

# kate: indent-width 2