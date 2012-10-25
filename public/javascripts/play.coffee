KEYCODE_UP = 38
KEYCODE_LEFT = 37
KEYCODE_RIGHT = 39
KEYCODE_W = 87
KEYCODE_A = 65
KEYCODE_D = 68
upHold = false
leftHold = false
rightHold = false





class Car
	car_picture: '/images/car.png'
	locar_picture: '/images/car2.png'
	car_image: new Image
	locar_image: new Image	
	upHold: false
	leftHold: false
	rightHold: false
	id: 0
	canvas_height: 0
	canvas_width: 0	
	isLocal: false
	#speed
	mass: 10
	vX: 0
	vY: 0
	thrust: 0
	max_thrust: 7
	#collision
	collision_begin: 0
	alive: true
	collision_angle: 0
	collision_thrust: 0
	#coords
	o1x:0
	o2x:0
	o3x:0
	o4x:0
	o1y:0
	o2y:0
	o3y:0
	o4y:0
	fromX:0
	toX:0
	fromY:0
	toY:0	

	constructor:(canvas, id, isLocal = false) ->
		this.canvas_height = canvas.height
		this.canvas_width = canvas.width		
		this.car_image.src = this.car_picture
		this.isLocal = isLocal
		if this.isLocal == true
			this.locar_image.src = this.locar_picture
			this.car_body = new Bitmap this.locar_image
		else	
			this.car_image.src = this.car_picture
			this.car_body = new Bitmap this.car_image
		this.car_body.rotation = 0
		this.car_body.bounds = 1
		this.car_body.hit = 24
		this.car_body.regX = 17
		this.car_body.regY = 28
		this.car_body.shadow = new Shadow "#000000", 4, 3, 5
		@r = Math.sqrt(17*17 + 28*28)
		@acos = Math.asin(28/@r)
		@ax_collsion = []
		this.id = id	


	destroy: ->
		delete this.car_body

	# ускорение
	accelerate: (collision_thrust = 0) ->
		if @collision_begin == 0
			@thrust += 0.2
			@thrust = @max_thrust  if @thrust >= @max_thrust
			@car_body.x -= Math.sin(@car_body.rotation*(Math.PI/-180))*@thrust
			@car_body.y -= Math.cos((@car_body.rotation)*(Math.PI/-180))*@thrust
		else if (collision_thrust > 0)
			@car_body.x -= Math.sin(@car_body.rotation*(Math.PI/-180))*collision_thrust
			@car_body.y -= Math.cos((@car_body.rotation)*(Math.PI/-180))*collision_thrust
	# торможение
	brake: ->
		@thrust -= 0.4
		if @thrust <= 0
			@thrust = 0 
		@car_body.x -= Math.sin(@car_body.rotation*(Math.PI/-180))*@thrust
		@car_body.y -= Math.cos((@car_body.rotation)*(Math.PI/-180))*@thrust
	# поворот
	rotate: (dir = 0) ->
		if dir != 0 && @thrust > 0 && @collision_begin == 0
			@car_body.rotation += dir * @thrust * 0.2		
	# столкновение
	set_collision: (obj1, obj2) ->
		#obj1.car_body.x -= Math.sin(obj2.car_body.rotation*(Math.PI/-180))*obj2.thrust*5
		#obj1.car_body.y -= Math.cos(obj2.car_body.rotation*(Math.PI/-180))*obj2.thrust*5
		#obj1.car_body.rotation -= obj2.car_body.rotation * 0.01
		#obj1.accelerate(5)

		#obj2.car_body.x -= Math.sin(obj1.car_body.rotation*(Math.PI/-180))*obj1.thrust*5
		#obj2.car_body.y -= Math.cos(obj1.car_body.rotation*(Math.PI/-180))*obj1.thrust*5
		#obj2.car_body.rotation -= obj1.car_body.rotation * 0.01
		#obj2.accelerate(5)

		obj1.collision_begin = Ticker.getTicks()
		obj1.collision_angle = obj2.car_body.rotation
		obj1.collision_thrust = obj2.thrust

		obj2.collision_begin = Ticker.getTicks()
		obj2.collision_angle = obj1.car_body.rotation
		obj2.collision_thrust = obj1.thrust
	
	collision: ->
		# передаем импульс
		@car_body.x -= Math.sin(@collision_angle*(Math.PI/-180))*@collision_thrust
		@car_body.y -= Math.cos(@collision_angle*(Math.PI/-180))*@collision_thrust
		#@car_body.rotation -= @collision_angle * .25
		# уменьшаем ускорение столкновения
		@collision_thrust -= 0.8
		@collision_thrust = 0 if @collision_thrust <= 0
			


	tick:(users) ->
		self = this	
		# проверяем, имеет ли место столкновение
		if (Ticker.getTicks() - self.collision_begin >= 5)
			self.collision_begin = 0
		else
			@collision()
		# помещаем назад в поле, если выехал за пределы
		if this.outOfBounds(this.car_body.x,this.car_body.y,this.car_body.bounds)
			this.placeInBounds(this.car_body,this.car_body.bounds)
		# поворот влево
		if @leftHold == true || (leftHold == true && @isLocal == true)			
			dir = -3
			@rotate(dir)
		# поворот вправо
		if @rightHold == true || (rightHold == true && @isLocal == true)		
			dir = 3
			@rotate(dir)
		# газ
		if (@upHold == true) || (upHold == true && @isLocal == true)
			@accelerate()
		# тормоз если газа нет
		else
			@brake()

		# сделать просчет 10 раз в секунду вместо 30
		# координаты	
		@o1x = @car_body.x + @r * Math.cos(-@acos + @car_body.rotation*(Math.PI/180))
		@o1y = @car_body.y + @r * Math.sin(-@acos + @car_body.rotation*(Math.PI/180))
		@o2x = @car_body.x + @r * Math.cos(@acos + @car_body.rotation*(Math.PI/180))
		@o2y = @car_body.y + @r * Math.sin(@acos + @car_body.rotation*(Math.PI/180))
		@o3x = @car_body.x + @r * Math.cos(-(Math.PI - @acos) + @car_body.rotation*(Math.PI/180))
		@o3y = @car_body.y + @r * Math.sin(-(Math.PI - @acos) + @car_body.rotation*(Math.PI/180))
		@o4x = @car_body.x + @r * Math.cos(Math.PI - @acos + @car_body.rotation*(Math.PI/180))
		@o4y = @car_body.y + @r * Math.sin(Math.PI - @acos + @car_body.rotation*(Math.PI/180))
		# проекции
		@fromX = Math.min(@o1x,@o2x,@o3x,@o4x)
		@toX = Math.max(@o1x,@o2x,@o3x,@o4x)
		@fromY = Math.min(@o1y,@o2y,@o3y,@o4y)
		@toY = Math.max(@o1y,@o2y,@o3y,@o4y)
		# обнаружение столкновения по проекциям на оси
		@ax_collsion = []
		users.map (user) ->
				if self.axisCollision(self.fromX, self.toX, self.fromY, self.toY, user.fromX, user.toX, user.fromY, user.toY)
					# запоминаем факт столкновения по осям
					self.ax_collsion.push user.id
					# проверяем наличие каждой из вершин нашей машинки в теле другой машинки
					if user.physCollision(self.o1x,self.o1y,self.o2x,self.o2y,self.o3x,self.o3y,self.o4x,self.o4y) || self.physCollision(user.o1x,user.o1y,user.o2x,user.o2y,user.o3x,user.o3y,user.o4x,user.o4y)
						# запуск столкновения
						self.set_collision(self,user)

	# пересечение по осям
	axisCollision: (x11,x12,y11,y12,x21,x22,y21,y22) ->
		(((x11 > x21 && x11 < x22) || (x12 > x21 && x12 < x22)) && ((y11 > y21 && y11 < y22) || (y12 > y21 && y12 < y22))) || (((x21 > x11 && x21 < x12) || (x22 > x11 && x22 < x12)) && ((y21 > y11 && y21 < y12) || (y22 > y11 && y22 < y12)))
	# нахождение точки в теле другой машины
	physCollision: (x1,y1,x2,y2,x3,y3,x4,y4) ->
		self = this
		o1 = self.car_body.globalToLocal(x1, y1)
		o2 = self.car_body.globalToLocal(x2, y2)
		o3 = self.car_body.globalToLocal(x3, y3)
		o4 = self.car_body.globalToLocal(x4, y4)
		self.car_body.hitTest(o1.x,o1.y) || self.car_body.hitTest(o2.x,o2.y) || self.car_body.hitTest(o3.x,o3.y) || self.car_body.hitTest(o4.x,o4.y)


	outOfBounds: (x,y,bounds) -> 
		x < bounds*-2 || y < bounds*-2 || x > @canvas_width+bounds*2 || y > @canvas_height+bounds*2					
	
	placeInBounds: (o, bounds) -> 
		if o.x > this.canvas_width+bounds*2
			o.x = bounds*-2
		else if o.x < bounds*-2
			o.x = this.canvas_width+bounds*2
		if o.y > this.canvas_height+bounds*2
			o.y = bounds*-2
		else if o.y < bounds*-2
			o.y = this.canvas_height+bounds*2	

class GameState
	players: new Array
	width: 500
	height: 400
	hasLocalPlayer: false
	canvas_height: 0
	canvas_width: 0

	constructor:(canvas) ->
		this.stage = new Stage canvas
		this.canvas_height = canvas.height
		this.canvas_width = canvas.width
		Ticker.setFPS 30
		Ticker.addListener window

	tick:(users) ->
		this.players.map (player) ->
			player.tick(users)

	addLocalPlayer: (player, x, y, rotation) ->
		this.hasLocalPlayer = true
		this.localPlayer = player
		this.addRemotePlayer(player, x, y, rotation)

	addRemotePlayer: (player, x, y, rotation) ->
		#directing users randomly to map
		player.car_body.x = x
		player.car_body.y = y
		player.car_body.rotation = rotation
		this.players.push player
		this.stage.addChild player.car_body
		this.stage.update

	removeRemotePlayer: (player) ->
		this.stage.removeChild player.car_body
		this.stage.update


jQuery ->
	socket = io.connect "http://92.38.231.21:3000"
	canvas = document.getElementById 'race'
	#local player	
	game = new GameState canvas
	users = []

	Array.prototype.removeById = (id) ->
		users.map (user) ->
			if user.id == id
				users.splice users.indexOf(user), 1

	Array.prototype.getById = (id) ->
		console.log "map: "+users
		users.map (user) ->
			console.log user
			if user.id == id
				user

	makeDirection = (users, type, id, direction) ->
		users.map (user) ->
			if user.id == id
				switch direction
						when "left"
							if type == "move"
								user.leftHold = true
							else
								user.leftHold = false
						when "right"
							if type == "move"
								user.rightHold = true
							else
								user.rightHold = false
						when "top"
							if type == "move"
								user.upHold = true
							else
								user.upHold = false

	socket.on "connect", ->
		#if connect -> emit join event and wait for params from server
		socket.emit "join", (successful, rusers, user) ->
			rusers.pop()
			jQuery.each rusers, (i, remoteUser) ->
				if remoteUser.id != user.Id # добавляем пользователя только если это не мы сами
					rUser = new Car canvas, remoteUser.id
					game.addRemotePlayer rUser, remoteUser.x, remoteUser.y, remoteUser.rotation
					users.push rUser
					console.log "user pushed by on-connect user-join: " + rUser+ " id: "+remoteUser.id

			if successful
				#creating local player
				localPlayer = new Car(canvas, 1, true) # true means that user is LOCAL
				game.addLocalPlayer localPlayer, user.x, user.y, user.rotation

				#user join event
				socket.on "user-joined", (remoteUser) ->
					rUser = new Car canvas, remoteUser.id
					game.addRemotePlayer rUser, remoteUser.x, remoteUser.y, remoteUser.rotation
					users.push rUser
					console.log "user pushed by user-join: " + rUser + " id: "+remoteUser.id

				#user disconnect event
				socket.on "user-left", (remoteUser) ->
					users.map (user) ->
						if user.id == remoteUser
							game.removeRemotePlayer user
							users.removeById user
							console.log "user removed by disconnect: " + remoteUser

				#key down event
				document.onkeydown = (e) ->
					switch e.keyCode
						when KEYCODE_A,KEYCODE_LEFT
							leftHold = true
							socket.emit "move", "left", localPlayer.car_body.x, localPlayer.car_body.y, localPlayer.car_body.rotation
						when KEYCODE_D,KEYCODE_RIGHT
							rightHold = true
							socket.emit "move", "right", localPlayer.car_body.x, localPlayer.car_body.y, localPlayer.car_body.rotation
						when KEYCODE_W, KEYCODE_UP
							upHold = true	
							socket.emit "move", "top", localPlayer.car_body.x, localPlayer.car_body.y, localPlayer.car_body.rotation
				
				#got remote key down event
				socket.on "move", (id, direction) ->
					makeDirection(users, "move", id, direction)

				#key up event
				document.onkeyup = (e) ->
					switch e.keyCode
						when KEYCODE_A,KEYCODE_LEFT
							leftHold = false
							socket.emit "end_move", "left", localPlayer.car_body.x, localPlayer.car_body.y, localPlayer.car_body.rotation
						when KEYCODE_D,KEYCODE_RIGHT
							rightHold = false
							socket.emit "end_move", "right", localPlayer.car_body.x, localPlayer.car_body.y, localPlayer.car_body.rotation
						when KEYCODE_W, KEYCODE_UP
							upHold = false
							socket.emit "end_move", "top", localPlayer.car_body.x, localPlayer.car_body.y, localPlayer.car_body.rotation							
				
				#got remote key down event
				socket.on "end_move", (id, direction) ->
					makeDirection(users, "end_move", id, direction)		

				#window tick event - broadcasting it the game and to the stage
				window.tick= ->
					game.stage.tick(game.stage)
					game.tick(users)

				window.tickPoint= (x,y) ->
					s = new Shape
					g = s.graphics
					g.beginFill(Graphics.getRGB(255, 0, 0))
					g.drawCircle(0, 0, 3)
					g.endFill()
					s.x = x
					s.y = y
					game.stage.addChild s
					game.stage.update