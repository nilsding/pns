// Generated by CoffeeScript 1.7.1

/*
 * P.N.S
 * A small, but fun game with toasters and clocks.
 * (c) 2011-2014 nilsding
 *
 * Special thanks to:
 *  @pixeldesu / @s4tori for some graphics
 *  @Jim_Clonk for the game idea
 */
var canvas, clock, closeTitle, collide, ctx, drawNumbers, drawSprite, explosion, gameCanvas, gameControlButton, gameField, gameLoop, gameVars, init, keydownhandler, keyuphandler, laser, newExplosion, newObject, newSprite, openTitle, render, resetGame, shootLaser, sounds, sprites, startGame, statusbar, stopGame, text, title, toaster, updateTitlebar;

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
    image: new Image(),
    sX: 0,
    sY: 0,
    sWidth: width,
    sHeight: height,
    sprite: {
      row: 0,
      column: 0
    }
  };
};

newSprite = function(rows, cols, width, height) {
  return {
    width: width,
    height: height,
    rows: rows,
    columns: cols,
    image: new Image()
  };
};

gameVars = {
  version: "0.4",
  isRunning: false,
  ticks: 60,
  points: 0,
  lives: 5,
  maxLives: 5
};

gameCanvas = {
  width: 800,
  height: 600
};

gameField = {
  posX: 0,
  posY: 64,
  width: gameCanvas.width,
  height: gameCanvas.height - 64,
  background: new Image()
};

statusbar = {
  posX: 0,
  posY: 0,
  width: gameCanvas.width,
  height: gameField.posY,
  gradient: null,
  colourTop: "#555555",
  colourBottom: "#323232"
};

sprites = {
  sprite: newSprite(8, 8, 32, 32)
};

text = {
  sprite: newSprite(2, 10, 27, 23)
};

title = {
  opened: false,
  top: newObject(0, 0, 800, 300),
  bottom: newObject(0, 300, 800, 300)
};

toaster = newObject(25, title.top.height - (188 / 2), 188, 148);

clock = newObject(600, 100, 128, 128);

laser = {
  image: new Image(),
  objects: [],
  isActive: false
};

explosion = {
  sprite: newSprite(1, 27, 78, 81),
  objects: []
};

sounds = {
  music: new SeamlessLoop(),
  explosion: new Audio(),
  shoot: new Audio()
};

init = function() {
  if (window.localStorage['highscore'] == null) {
    window.localStorage['highscore'] = 0;
  }
  if (window.localStorage['musicEnabled'] == null) {
    window.localStorage['musicEnabled'] = true;
  }
  canvas = document.getElementById('gameField');
  ctx = canvas.getContext('2d');
  gameField.background.src = './img/background.png';
  toaster.image.src = './img/toaster.png';
  clock.image.src = './img/clock.png';
  title.top.image.src = './img/title_top.png';
  title.bottom.image.src = './img/title_bottom.png';
  laser.image.src = './img/laser.png';
  text.sprite.image.src = './img/nums.png';
  explosion.sprite.image.src = './img/explosion.png';
  sprites.sprite.image.src = './img/sprites.png';
  sounds.music.addUri('./snd/music.ogg', 21607, "music");
  sounds.music.callback(function() {
    if (window.localStorage['musicEnabled'] === "true") {
      return sounds.music.start("music");
    }
  });
  statusbar.gradient = ctx.createLinearGradient(0, 0, 0, statusbar.height);
  statusbar.gradient.addColorStop(0, statusbar.colourTop);
  statusbar.gradient.addColorStop(1, statusbar.colourBottom);
  document.onkeydown = keydownhandler;
  document.onkeyup = keyuphandler;
  resetGame();
  return render();
};

drawNumbers = function(num, pad, posX, posY) {
  var c, numberStr, spriteX, spriteY, _i, _len, _results;
  numberStr = (Array(pad + 1).join("0") + num).substr(-pad, pad);
  spriteX = 0;
  spriteY = 0;
  _results = [];
  for (_i = 0, _len = numberStr.length; _i < _len; _i++) {
    c = numberStr[_i];
    spriteX = Number(c) * text.sprite.width;
    ctx.drawImage(text.sprite.image, spriteX, spriteY, text.sprite.width, text.sprite.height, posX, posY, text.sprite.width, text.sprite.height);
    _results.push(posX += text.sprite.width - 5);
  }
  return _results;
};

drawSprite = function(spr, x, y, posX, posY) {
  var spriteX, spriteY;
  spriteX = x * spr.sprite.width;
  spriteY = y * spr.sprite.height;
  return ctx.drawImage(spr.sprite.image, spriteX, spriteY, spr.sprite.width, spr.sprite.height, posX, posY, spr.sprite.width, spr.sprite.height);
};

render = function() {
  var i, j, obj, _i, _j, _k, _l, _len, _len1, _len2, _m, _n, _o, _p, _q, _r, _ref, _ref1, _ref2, _ref3, _ref4;
  ctx.clearRect(0, 0, gameCanvas.width, gameCanvas.height);
  ctx.drawImage(gameField.background, gameField.posX, gameField.posY, gameField.width, gameField.height);
  ctx.fillStyle = statusbar.gradient;
  ctx.fillRect(statusbar.posX, statusbar.posY, statusbar.width, statusbar.height);
  for (i = _i = 0; _i <= 1; i = ++_i) {
    for (j = _j = 1; _j <= 2; j = ++_j) {
      drawSprite(sprites, i, j, i * sprites.sprite.width, (j - 1) * sprites.sprite.height);
    }
  }
  for (i = _k = 0; _k <= 2; i = ++_k) {
    drawSprite(text, i, 1, statusbar.width - 12 - (3 * text.sprite.width) + (i * text.sprite.width), 0);
  }
  drawNumbers(gameVars.points, 8, statusbar.width - 10 - (7 * text.sprite.width), text.sprite.height + 5);
  for (i = _l = 3; _l <= 6; i = ++_l) {
    drawSprite(text, i, 1, statusbar.width - 12 - (14 * text.sprite.width) + (i * text.sprite.width), 0);
  }
  drawNumbers(window.localStorage['highscore'], 8, statusbar.width - 10 - (14 * text.sprite.width), text.sprite.height + 5);
  for (i = _m = 7; _m <= 9; i = ++_m) {
    drawSprite(text, i, 1, statusbar.width - 12 - (25 * text.sprite.width) + (i * text.sprite.width), 0);
  }
  for (i = _n = 0, _ref = gameVars.maxLives; 0 <= _ref ? _n < _ref : _n > _ref; i = 0 <= _ref ? ++_n : --_n) {
    drawSprite(sprites, 1, 0, statusbar.width - 12 - (18 * sprites.sprite.width) + (i * (sprites.sprite.width + 3)), text.sprite.height + 5);
  }
  for (i = _o = 0, _ref1 = gameVars.lives; 0 <= _ref1 ? _o < _ref1 : _o > _ref1; i = 0 <= _ref1 ? ++_o : --_o) {
    drawSprite(sprites, 0, 0, statusbar.width - 12 - (18 * sprites.sprite.width) + (i * (sprites.sprite.width + 3)), text.sprite.height + 5);
  }
  _ref2 = explosion.objects;
  for (_p = 0, _len = _ref2.length; _p < _len; _p++) {
    obj = _ref2[_p];
    ctx.drawImage(obj.image, obj.sX, obj.sY, obj.sWidth, obj.sHeight, obj.posX, obj.posY, obj.width, obj.height);
  }
  _ref3 = laser.objects;
  for (_q = 0, _len1 = _ref3.length; _q < _len1; _q++) {
    obj = _ref3[_q];
    ctx.drawImage(obj.image, obj.posX, obj.posY, obj.width, obj.height);
  }
  _ref4 = [clock, toaster, title.top, title.bottom];
  for (_r = 0, _len2 = _ref4.length; _r < _len2; _r++) {
    obj = _ref4[_r];
    ctx.drawImage(obj.image, obj.posX, obj.posY, obj.width, obj.height);
  }
  return window.requestAnimationFrame(render);
};

keydownhandler = function(event) {
  switch (event.keyCode) {
    case 77:
      if (window.localStorage['musicEnabled'] === "true") {
        sounds.music.stop("music");
        window.localStorage['musicEnabled'] = false;
      } else {
        sounds.music.start("music");
        window.localStorage['musicEnabled'] = true;
      }
  }
  if (!gameVars.isRunning) {
    switch (event.keyCode) {
      case 32:
        document.getElementById('info').style.display = "none";
        return startGame();
    }
  } else {
    switch (event.keyCode) {
      case 32:
        event.preventDefault();
        if (!laser.isActive && laser.objects.length < 5) {
          shootLaser();
          return laser.isActive = true;
        }
        break;
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
        document.getElementById('info').style.display = "";
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
    case 32:
      return laser.isActive = false;
  }
};

collide = function(a, b) {
  return !((b.posX > a.posX + a.width) || (b.posX + b.width < a.posX) || (b.posY > a.posY + a.height) || (b.posY + b.height < a.posY));
};

shootLaser = function() {
  var _laser;
  _laser = newObject(0, 0, 71, 71);
  _laser.image = laser.image;
  _laser.posX = Math.floor(toaster.posX + toaster.width - _laser.width);
  _laser.posY = Math.floor(toaster.posY + toaster.height / 2 - _laser.height / 2);
  _laser.velX = 5;
  _laser.velY = 0;
  return laser.objects.push(_laser);
};

newExplosion = function(x, y) {
  var _explosion;
  _explosion = newObject(x, y, explosion.sprite.width, explosion.sprite.height);
  _explosion.image = explosion.sprite.image;
  _explosion.sprite.row = 0;
  _explosion.sprite.column = 0;
  return explosion.objects.push(_explosion);
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
  var e, i, l, newX, newY, _i, _j, _len, _len1, _ref, _ref1;
  if (!gameVars.isRunning) {
    return;
  }
  newX = toaster.posX + toaster.velX;
  newY = toaster.posY + toaster.velY;
  if (newX < gameField.width + gameField.posX - toaster.width && newX > 0 + gameField.posX) {
    toaster.posX = newX;
  }
  if (newY < gameField.height + gameField.posY - toaster.height && newY > 0 + gameField.posY) {
    toaster.posY = newY;
  }
  newX = (clock.posX -= 5);
  if (newX < -200 || collide(toaster, clock)) {
    newExplosion(clock.posX, clock.posY);
    clock.posX = 800;
    clock.posY = Math.floor((Math.random() * 1000) % (gameField.height - clock.height) + gameField.posY);
    gameVars.lives--;
  }
  _ref = laser.objects;
  for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
    l = _ref[i];
    if (l == null) {
      continue;
    }
    newX = l.posX + l.velX;
    if (newX < gameField.width + gameField.posX) {
      l.posX = newX;
      if (collide(l, clock)) {
        gameVars.points += Math.round(100 / laser.objects.length);
        updateTitlebar();
        if (Number(window.localStorage['highscore']) < gameVars.points) {
          window.localStorage['highscore'] = gameVars.points;
        }
        laser.objects.splice(i, 1);
        newExplosion(clock.posX, clock.posY);
        clock.posX = 800;
        clock.posY = Math.floor((Math.random() * 1000) % (gameField.height - clock.height) + gameField.posY);
      }
    } else {
      laser.objects.splice(i, 1);
    }
  }
  _ref1 = explosion.objects;
  for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
    e = _ref1[i];
    if (e == null) {
      continue;
    }
    if (e.sprite.column !== explosion.sprite.columns) {
      e.sprite.column++;
      e.sX = e.sprite.column * explosion.sprite.width;
    } else {
      explosion.objects.splice(i, 1);
    }
  }
  if (gameVars.lives === 0) {
    stopGame();
    resetGame();
  }
  return window.setTimeout(gameLoop, 1000 / gameVars.ticks);
};

startGame = function() {
  openTitle();
  gameVars.isRunning = true;
  return gameLoop();
};

stopGame = function() {
  closeTitle();
  return gameVars.isRunning = false;
};

resetGame = function() {
  gameVars.points = 0;
  gameVars.lives = gameVars.maxLives;
  toaster.velX = 0;
  toaster.velY = 0;
  toaster.posX = 25;
  toaster.posY = title.top.height - (188 / 2);
  clock.posX = 600;
  clock.posY = 100;
  laser.objects = [];
  explosion.objects = [];
  return updateTitlebar();
};

updateTitlebar = function(spacer) {
  var titlebar;
  if (spacer == null) {
    spacer = "&nbsp;&nbsp;&nbsp;||&nbsp;&nbsp;&nbsp;";
  }
  titlebar = document.getElementById("title");
  return titlebar.innerHTML = "P.N.S " + gameVars.version + spacer + "Score: " + gameVars.points + spacer + "Highscore: " + window.localStorage['highscore'];
};

window.onload = init;
