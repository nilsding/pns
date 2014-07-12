// Generated by CoffeeScript 1.7.1
var canvas, clock, closeTitle, collide, ctx, gameControlButton, gameField, gameLoop, gameVars, init, keydownhandler, keyuphandler, laserImage, laserObjects, newObject, openTitle, render, shootLaser, startGame, stopGame, title, toaster;

canvas = null;

ctx = null;

gameControlButton = null;

newObject = function(x, y, width, height) {
  return {
    posX: x,
    posY: y,
    velX: 0,
    velY: 0,
    width: width,
    height: height,
    image: new Image()
  };
};

gameVars = {
  isRunning: false,
  ticks: 60
};

gameField = {
  width: 800,
  height: 600,
  background: new Image()
};

title = {
  opened: false,
  top: newObject(0, 0, 800, 300),
  bottom: newObject(0, 300, 800, 300)
};

toaster = newObject(25, title.top.height - (188 / 2), 188, 148);

clock = newObject(600, 100, 200, 200);

laserImage = new Image();

laserObjects = [];

init = function() {
  canvas = document.getElementById('gameField');
  ctx = canvas.getContext('2d');
  gameField.background.src = './img/background.png';
  toaster.image.src = './img/toaster.png';
  clock.image.src = './img/clock.png';
  title.top.image.src = './img/title_top.png';
  title.bottom.image.src = './img/title_bottom.png';
  laserImage.src = './img/laser.png';
  gameControlButton = document.getElementById('gameControlButton');
  gameControlButton.innerHTML = "Start Game";
  gameControlButton.onclick = startGame;
  document.onkeydown = keydownhandler;
  document.onkeyup = keyuphandler;
  return render();
};

render = function() {
  var obj, _i, _j, _len, _len1, _ref;
  ctx.drawImage(gameField.background, 0, 0, gameField.width, gameField.height);
  for (_i = 0, _len = laserObjects.length; _i < _len; _i++) {
    obj = laserObjects[_i];
    ctx.drawImage(obj.image, obj.posX, obj.posY, obj.width, obj.height);
  }
  _ref = [clock, toaster, title.top, title.bottom];
  for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
    obj = _ref[_j];
    ctx.drawImage(obj.image, obj.posX, obj.posY, obj.width, obj.height);
  }
  return window.requestAnimationFrame(render);
};

keydownhandler = function(event) {
  if (!gameVars.isRunning) {
    switch (event.keyCode) {
      case 32:
        return startGame();
    }
  } else {
    switch (event.keyCode) {
      case 32:
        event.preventDefault();
        return shootLaser();
      case 37:
        event.preventDefault();
        return toaster.velX = -5;
      case 38:
        event.preventDefault();
        return toaster.velY = -5;
      case 39:
        event.preventDefault();
        return toaster.velX = +5;
      case 40:
        event.preventDefault();
        return toaster.velY = +5;
      case 19:
      case 80:
        return stopGame();
    }
  }
};

keyuphandler = function(event) {
  if (!gameVars.isRunning) {
    return;
  }
  switch (event.keyCode) {
    case 37:
    case 39:
      event.preventDefault();
      return toaster.velX = 0;
    case 38:
    case 40:
      event.preventDefault();
      return toaster.velY = 0;
  }
};

collide = function(a, b) {
  return !((b.posX > a.posX + a.width) || (b.posX + b.width < a.posX) || (b.posY > a.posY + a.height) || (b.posY + b.height < b.posY));
};

shootLaser = function() {
  var laser;
  laser = newObject(0, 0, 71, 71);
  laser.image = laserImage;
  laser.posX = Math.floor(toaster.posX + toaster.width - laser.width);
  laser.posY = Math.floor(toaster.posY + toaster.height / 2 - laser.height / 2);
  laser.velX = 5;
  laser.velY = 0;
  return laserObjects.push(laser);
};

openTitle = function() {
  if (title.top.posY < (-title.top.height)) {
    title.opened = true;
    return;
  }
  title.top.posY -= 15;
  title.bottom.posY += 15;
  return window.setTimeout(openTitle, 1000 / gameVars.ticks);
};

closeTitle = function() {
  if (title.top.posY === 0) {
    title.opened = false;
    return;
  }
  title.top.posY += 15;
  title.bottom.posY -= 15;
  return window.setTimeout(closeTitle, 1000 / gameVars.ticks);
};

gameLoop = function() {
  var i, l, newX, newY, _i, _len;
  if (!gameVars.isRunning) {
    return;
  }
  newX = toaster.posX + toaster.velX;
  newY = toaster.posY + toaster.velY;
  if (newX < gameField.width - toaster.width && newX > 0) {
    toaster.posX = newX;
  }
  if (newY < gameField.height - toaster.height && newY > 0) {
    toaster.posY = newY;
  }
  newX = (clock.posX -= 5);
  if (newX < -200) {
    clock.posX = 800;
    clock.posY = Math.floor((Math.random() * 1000) % (600 - clock.height));
  }
  for (i = _i = 0, _len = laserObjects.length; _i < _len; i = ++_i) {
    l = laserObjects[i];
    if (l == null) {
      continue;
    }
    newX = l.posX + l.velX;
    if (newX < gameField.width) {
      l.posX = newX;
      if (collide(l, clock)) {
        laserObjects.splice(i, 1);
        clock.posX = 800;
        clock.posY = Math.floor((Math.random() * 1000) % (600 - clock.height));
      }
    } else {
      laserObjects.splice(i, 1);
    }
  }
  return window.setTimeout(gameLoop, 1000 / gameVars.ticks);
};

startGame = function() {
  gameControlButton.innerHTML = "Stop Game";
  gameControlButton.onclick = stopGame;
  openTitle();
  gameVars.isRunning = true;
  return gameLoop();
};

stopGame = function() {
  gameControlButton.innerHTML = "Start Game";
  gameControlButton.onclick = startGame;
  closeTitle();
  return gameVars.isRunning = false;
};

window.onload = init;
