(function() {
  var Car, GameState, KEYCODE_A, KEYCODE_D, KEYCODE_LEFT, KEYCODE_RIGHT, KEYCODE_UP, KEYCODE_W, leftHold, rightHold, upHold;

  KEYCODE_UP = 38;

  KEYCODE_LEFT = 37;

  KEYCODE_RIGHT = 39;

  KEYCODE_W = 87;

  KEYCODE_A = 65;

  KEYCODE_D = 68;

  upHold = false;

  leftHold = false;

  rightHold = false;

  Car = (function() {

    Car.prototype.car_picture = '/images/car.png';

    Car.prototype.locar_picture = '/images/car2.png';

    Car.prototype.car_image = new Image;

    Car.prototype.locar_image = new Image;

    Car.prototype.upHold = false;

    Car.prototype.leftHold = false;

    Car.prototype.rightHold = false;

    Car.prototype.id = 0;

    Car.prototype.canvas_height = 0;

    Car.prototype.canvas_width = 0;

    Car.prototype.isLocal = false;

    Car.prototype.mass = 10;

    Car.prototype.vX = 0;

    Car.prototype.vY = 0;

    Car.prototype.thrust = 0;

    Car.prototype.max_thrust = 7;

    Car.prototype.collision_begin = 0;

    Car.prototype.alive = true;

    Car.prototype.o1x = 0;

    Car.prototype.o2x = 0;

    Car.prototype.o3x = 0;

    Car.prototype.o4x = 0;

    Car.prototype.o1y = 0;

    Car.prototype.o2y = 0;

    Car.prototype.o3y = 0;

    Car.prototype.o4y = 0;

    Car.prototype.fromX = 0;

    Car.prototype.toX = 0;

    Car.prototype.fromY = 0;

    Car.prototype.toY = 0;

    function Car(canvas, id, isLocal) {
      if (isLocal == null) {
        isLocal = false;
      }
      this.canvas_height = canvas.height;
      this.canvas_width = canvas.width;
      this.car_image.src = this.car_picture;
      this.isLocal = isLocal;
      if (this.isLocal === true) {
        this.locar_image.src = this.locar_picture;
        this.car_body = new Bitmap(this.locar_image);
      } else {
        this.car_image.src = this.car_picture;
        this.car_body = new Bitmap(this.car_image);
      }
      this.car_body.rotation = 0;
      this.car_body.bounds = 1;
      this.car_body.hit = 24;
      this.car_body.regX = 17;
      this.car_body.regY = 28;
      this.car_body.shadow = new Shadow("#000000", 4, 3, 5);
      this.r = Math.sqrt(17 * 17 + 28 * 28);
      this.acos = Math.asin(28 / this.r);
      this.ax_collsion = [];
      this.id = id;
    }

    Car.prototype.destroy = function() {
      return delete this.car_body;
    };

    Car.prototype.accelerate = function(collision_thrust) {
      if (collision_thrust == null) {
        collision_thrust = 0;
      }
      if (this.collision_begin === 0) {
        this.thrust += 0.2;
        if (this.thrust >= this.max_thrust) {
          this.thrust = this.max_thrust;
        }
        this.car_body.x -= Math.sin(this.car_body.rotation * (Math.PI / -180)) * this.thrust;
        return this.car_body.y -= Math.cos(this.car_body.rotation * (Math.PI / -180)) * this.thrust;
      } else if (collision_thrust > 0) {
        this.car_body.x -= Math.sin(this.car_body.rotation * (Math.PI / -180)) * collision_thrust;
        return this.car_body.y -= Math.cos(this.car_body.rotation * (Math.PI / -180)) * collision_thrust;
      }
    };

    Car.prototype.brake = function() {
      this.thrust -= 0.4;
      if (this.thrust <= 0) {
        this.thrust = 0;
      }
      this.car_body.x -= Math.sin(this.car_body.rotation * (Math.PI / -180)) * this.thrust;
      return this.car_body.y -= Math.cos(this.car_body.rotation * (Math.PI / -180)) * this.thrust;
    };

    Car.prototype.rotate = function(dir) {
      if (dir == null) {
        dir = 0;
      }
      if (dir !== 0 && this.thrust > 0 && this.collision_begin === 0) {
        return this.car_body.rotation += dir * this.thrust * 0.2;
      }
    };

    Car.prototype.collision = function(obj1, obj2) {
      obj1.car_body.x -= Math.sin(obj2.car_body.rotation * (Math.PI / -180)) * obj2.thrust * 5;
      obj1.car_body.y -= Math.cos(obj2.car_body.rotation * (Math.PI / -180)) * obj2.thrust * 5;
      obj1.car_body.rotation -= obj2.car_body.rotation * 0.01;
      obj1.accelerate(5);
      obj2.car_body.x -= Math.sin(obj1.car_body.rotation * (Math.PI / -180)) * obj1.thrust * 5;
      obj2.car_body.y -= Math.cos(obj1.car_body.rotation * (Math.PI / -180)) * obj1.thrust * 5;
      obj2.car_body.rotation -= obj1.car_body.rotation * 0.01;
      obj2.accelerate(5);
      obj1.collision_begin = Ticker.getTicks();
      obj2.collision_begin = Ticker.getTicks();
      return true;
    };

    Car.prototype.tick = function(users) {
      var dir, self;
      self = this;
      if (Ticker.getTicks() - self.collision_begin >= 5) {
        self.collision_begin = 0;
      }
      if (this.outOfBounds(this.car_body.x, this.car_body.y, this.car_body.bounds)) {
        this.placeInBounds(this.car_body, this.car_body.bounds);
      }
      if (this.leftHold === true || (leftHold === true && this.isLocal === true)) {
        dir = -3;
        this.rotate(dir);
      }
      if (this.rightHold === true || (rightHold === true && this.isLocal === true)) {
        dir = 3;
        this.rotate(dir);
      }
      if ((this.upHold === true) || (upHold === true && this.isLocal === true)) {
        this.accelerate();
      } else {
        this.brake();
      }
      this.o1x = this.car_body.x + this.r * Math.cos(-this.acos + this.car_body.rotation * (Math.PI / 180));
      this.o1y = this.car_body.y + this.r * Math.sin(-this.acos + this.car_body.rotation * (Math.PI / 180));
      this.o2x = this.car_body.x + this.r * Math.cos(this.acos + this.car_body.rotation * (Math.PI / 180));
      this.o2y = this.car_body.y + this.r * Math.sin(this.acos + this.car_body.rotation * (Math.PI / 180));
      this.o3x = this.car_body.x + this.r * Math.cos(-(Math.PI - this.acos) + this.car_body.rotation * (Math.PI / 180));
      this.o3y = this.car_body.y + this.r * Math.sin(-(Math.PI - this.acos) + this.car_body.rotation * (Math.PI / 180));
      this.o4x = this.car_body.x + this.r * Math.cos(Math.PI - this.acos + this.car_body.rotation * (Math.PI / 180));
      this.o4y = this.car_body.y + this.r * Math.sin(Math.PI - this.acos + this.car_body.rotation * (Math.PI / 180));
      this.fromX = Math.min(this.o1x, this.o2x, this.o3x, this.o4x);
      this.toX = Math.max(this.o1x, this.o2x, this.o3x, this.o4x);
      this.fromY = Math.min(this.o1y, this.o2y, this.o3y, this.o4y);
      this.toY = Math.max(this.o1y, this.o2y, this.o3y, this.o4y);
      this.ax_collsion = [];
      return users.map(function(user) {
        if (self.axisCollision(self.fromX, self.toX, self.fromY, self.toY, user.fromX, user.toX, user.fromY, user.toY)) {
          self.ax_collsion.push(user.id);
          if (user.physCollision(self.o1x, self.o1y, self.o2x, self.o2y, self.o3x, self.o3y, self.o4x, self.o4y) || self.physCollision(user.o1x, user.o1y, user.o2x, user.o2y, user.o3x, user.o3y, user.o4x, user.o4y)) {
            return self.collision(self, user);
          }
        }
      });
    };

    Car.prototype.axisCollision = function(x11, x12, y11, y12, x21, x22, y21, y22) {
      return (((x11 > x21 && x11 < x22) || (x12 > x21 && x12 < x22)) && ((y11 > y21 && y11 < y22) || (y12 > y21 && y12 < y22))) || (((x21 > x11 && x21 < x12) || (x22 > x11 && x22 < x12)) && ((y21 > y11 && y21 < y12) || (y22 > y11 && y22 < y12)));
    };

    Car.prototype.physCollision = function(x1, y1, x2, y2, x3, y3, x4, y4) {
      var o1, o2, o3, o4, self;
      self = this;
      o1 = self.car_body.globalToLocal(x1, y1);
      o2 = self.car_body.globalToLocal(x2, y2);
      o3 = self.car_body.globalToLocal(x3, y3);
      o4 = self.car_body.globalToLocal(x4, y4);
      return self.car_body.hitTest(o1.x, o1.y) || self.car_body.hitTest(o2.x, o2.y) || self.car_body.hitTest(o3.x, o3.y) || self.car_body.hitTest(o4.x, o4.y);
    };

    Car.prototype.outOfBounds = function(x, y, bounds) {
      return x < bounds * -2 || y < bounds * -2 || x > this.canvas_width + bounds * 2 || y > this.canvas_height + bounds * 2;
    };

    Car.prototype.placeInBounds = function(o, bounds) {
      if (o.x > this.canvas_width + bounds * 2) {
        o.x = bounds * -2;
      } else if (o.x < bounds * -2) {
        o.x = this.canvas_width + bounds * 2;
      }
      if (o.y > this.canvas_height + bounds * 2) {
        return o.y = bounds * -2;
      } else if (o.y < bounds * -2) {
        return o.y = this.canvas_height + bounds * 2;
      }
    };

    return Car;

  })();

  GameState = (function() {

    GameState.prototype.players = new Array;

    GameState.prototype.width = 500;

    GameState.prototype.height = 400;

    GameState.prototype.hasLocalPlayer = false;

    GameState.prototype.canvas_height = 0;

    GameState.prototype.canvas_width = 0;

    function GameState(canvas) {
      this.stage = new Stage(canvas);
      this.canvas_height = canvas.height;
      this.canvas_width = canvas.width;
      Ticker.setFPS(30);
      Ticker.addListener(window);
    }

    GameState.prototype.tick = function(users) {
      return this.players.map(function(player) {
        return player.tick(users);
      });
    };

    GameState.prototype.addLocalPlayer = function(player, x, y, rotation) {
      this.hasLocalPlayer = true;
      this.localPlayer = player;
      return this.addRemotePlayer(player, x, y, rotation);
    };

    GameState.prototype.addRemotePlayer = function(player, x, y, rotation) {
      player.car_body.x = x;
      player.car_body.y = y;
      player.car_body.rotation = rotation;
      this.players.push(player);
      this.stage.addChild(player.car_body);
      return this.stage.update;
    };

    GameState.prototype.removeRemotePlayer = function(player) {
      this.stage.removeChild(player.car_body);
      return this.stage.update;
    };

    return GameState;

  })();

  jQuery(function() {
    var canvas, game, makeDirection, socket, users;
    socket = io.connect("http://127.0.0.1:3000");
    canvas = document.getElementById('race');
    game = new GameState(canvas);
    users = [];
    Array.prototype.removeById = function(id) {
      return users.map(function(user) {
        if (user.id === id) {
          return users.splice(users.indexOf(user), 1);
        }
      });
    };
    Array.prototype.getById = function(id) {
      console.log("map: " + users);
      return users.map(function(user) {
        console.log(user);
        if (user.id === id) {
          return user;
        }
      });
    };
    makeDirection = function(users, type, id, direction) {
      return users.map(function(user) {
        if (user.id === id) {
          switch (direction) {
            case "left":
              if (type === "move") {
                return user.leftHold = true;
              } else {
                return user.leftHold = false;
              }
              break;
            case "right":
              if (type === "move") {
                return user.rightHold = true;
              } else {
                return user.rightHold = false;
              }
              break;
            case "top":
              if (type === "move") {
                return user.upHold = true;
              } else {
                return user.upHold = false;
              }
          }
        }
      });
    };
    return socket.on("connect", function() {
      return socket.emit("join", function(successful, rusers, user) {
        var localPlayer;
        rusers.pop();
        jQuery.each(rusers, function(i, remoteUser) {
          var rUser;
          if (remoteUser.id !== user.Id) {
            rUser = new Car(canvas, remoteUser.id);
            game.addRemotePlayer(rUser, remoteUser.x, remoteUser.y, remoteUser.rotation);
            users.push(rUser);
            return console.log("user pushed by on-connect user-join: " + rUser + " id: " + remoteUser.id);
          }
        });
        if (successful) {
          localPlayer = new Car(canvas, 1, true);
          game.addLocalPlayer(localPlayer, user.x, user.y, user.rotation);
          socket.on("user-joined", function(remoteUser) {
            var rUser;
            rUser = new Car(canvas, remoteUser.id);
            game.addRemotePlayer(rUser, remoteUser.x, remoteUser.y, remoteUser.rotation);
            users.push(rUser);
            return console.log("user pushed by user-join: " + rUser + " id: " + remoteUser.id);
          });
          socket.on("user-left", function(remoteUser) {
            return users.map(function(user) {
              if (user.id === remoteUser) {
                game.removeRemotePlayer(user);
                users.removeById(user);
                return console.log("user removed by disconnect: " + remoteUser);
              }
            });
          });
          document.onkeydown = function(e) {
            switch (e.keyCode) {
              case KEYCODE_A:
              case KEYCODE_LEFT:
                leftHold = true;
                return socket.emit("move", "left", localPlayer.car_body.x, localPlayer.car_body.y, localPlayer.car_body.rotation);
              case KEYCODE_D:
              case KEYCODE_RIGHT:
                rightHold = true;
                return socket.emit("move", "right", localPlayer.car_body.x, localPlayer.car_body.y, localPlayer.car_body.rotation);
              case KEYCODE_W:
              case KEYCODE_UP:
                upHold = true;
                return socket.emit("move", "top", localPlayer.car_body.x, localPlayer.car_body.y, localPlayer.car_body.rotation);
            }
          };
          socket.on("move", function(id, direction) {
            return makeDirection(users, "move", id, direction);
          });
          document.onkeyup = function(e) {
            switch (e.keyCode) {
              case KEYCODE_A:
              case KEYCODE_LEFT:
                leftHold = false;
                return socket.emit("end_move", "left", localPlayer.car_body.x, localPlayer.car_body.y, localPlayer.car_body.rotation);
              case KEYCODE_D:
              case KEYCODE_RIGHT:
                rightHold = false;
                return socket.emit("end_move", "right", localPlayer.car_body.x, localPlayer.car_body.y, localPlayer.car_body.rotation);
              case KEYCODE_W:
              case KEYCODE_UP:
                upHold = false;
                return socket.emit("end_move", "top", localPlayer.car_body.x, localPlayer.car_body.y, localPlayer.car_body.rotation);
            }
          };
          socket.on("end_move", function(id, direction) {
            return makeDirection(users, "end_move", id, direction);
          });
          window.tick = function() {
            game.stage.tick(game.stage);
            return game.tick(users);
          };
          return window.tickPoint = function(x, y) {
            var g, s;
            s = new Shape;
            g = s.graphics;
            g.beginFill(Graphics.getRGB(255, 0, 0));
            g.drawCircle(0, 0, 3);
            g.endFill();
            s.x = x;
            s.y = y;
            game.stage.addChild(s);
            return game.stage.update;
          };
        }
      });
    });
  });

}).call(this);
