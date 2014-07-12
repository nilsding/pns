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
  isRunning: false
  ticks: 60

gameField =
  width: 800
  height: 600

title =
  opened: false
  top: newObject 0, 0, 800, 300
  bottom: newObject 0, 300, 800, 300

toaster = newObject 25, title.top.height - (188 / 2), 188, 148

clock = newObject 600, 100, 200, 200

init = ->
  canvas = document.getElementById 'gameField'
  ctx = canvas.getContext '2d'
  toaster.image.src = './img/toaster.png'
  clock.image.src = './img/clock.png'
  title.top.image.src = './img/title_top.png'
  title.bottom.image.src = './img/title_bottom.png'
  
  gameControlButton = document.getElementById 'gameControlButton'
  gameControlButton.innerHTML = "Start Game"
  gameControlButton.onclick = startGame
  
  document.onkeydown = keydownhandler
  document.onkeyup = keyuphandler
  render()

render = ->
  ctx.clearRect(0, 0, gameField.width, gameField.height)
  
  for obj in [clock, toaster, title.top, title.bottom]    # I'm a lazy fuck.
    ctx.drawImage obj.image, obj.posX, obj.posY, obj.width, obj.height
  
  window.requestAnimationFrame render

keydownhandler = (event) ->
  console.log event.keyCode
  unless gameVars.isRunning
    switch event.keyCode
      when 32 # space bar  (title screen)
        startGame()
  else
    switch event.keyCode
      when 32 # space bar  (DER TOTALE LASER)
        null
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
  if newX < gameField.width - toaster.width and newX > 0
    toaster.posX = newX
  if newY < gameField.height - toaster.height and newY > 0
    toaster.posY = newY
  
  newX = (clock.posX -= 5)
  
  if newX < -200
    clock.posX = 800
    clock.posY = Math.floor (Math.random() * 1000) % (600 - clock.height)
  
  window.setTimeout gameLoop, 1000 / gameVars.ticks

startGame = ->
  gameControlButton.innerHTML = "Stop Game"
  gameControlButton.onclick = stopGame
  openTitle()
  gameVars.isRunning = true
  gameLoop()

stopGame = ->
  gameControlButton.innerHTML = "Start Game"
  gameControlButton.onclick = startGame
  closeTitle()
  gameVars.isRunning = false

window.onload = init

# kate: indent-width 2