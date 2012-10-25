KEYCODE_UP = 38
KEYCODE_LEFT = 37
KEYCODE_RIGHT = 39
KEYCODE_W = 87
KEYCODE_A = 65
KEYCODE_D = 68
upHold = false
leftHold = false
rightHold = false


b2Vec2 = Box2D.Common.Math.b2Vec2
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2Body = Box2D.Dynamics.b2Body
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2World = Box2D.Dynamics.b2World
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
b2RevoluteJointDef = Box2D.Dynamics.Joints.b2RevoluteJointDef
b2MouseJointDef = Box2D.Dynamics.Joints.b2MouseJointDef
b2DebugDraw = Box2D.Dynamics.b2DebugDraw
b2Fixture = Box2D.Dynamics.b2Fixture
b2AABB = Box2D.Collision.b2AABB
world = new b2World(new b2Vec2(0, 0), true)


class Car
	alive: true
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
	max_speed: 7

	constructor:(canvas, id, isLocal = false) ->
		############
		# easelJS bingings
		############
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
		#this.car_body.shadow = 15
		this.car_body.shadow = new Shadow "#000000", 4, 3, 5
		this.id = id
		############
		# box2d bingings
		############
		bodyDef = new b2BodyDef
		bodyDef.type = b2Body.b2_dynamicBody
		fixDef = new b2FixtureDef
		fixDef.density = 10
		fixDef.friction = .1
		fixDef.restitution = 0.1
		fixDef.shape = new b2CircleShape(0.3)
		bodyDef.position.Set @car_body.x, @car_body.y
		fixDef.shape = new b2PolygonShape
		fixDef.shape.SetAsBox .6, 1.3
		
		@car = world.CreateBody(bodyDef)
		@car.CreateFixture fixDef
		@xx = @car.GetWorldCenter().x
		@yy = @car.GetWorldCenter().y

		@wheel_tr = @wheel(@xx + .5, @yy - 1)
		@wheel_tl = @wheel(@xx - .5, @yy - 1)
		@wheel_br = @wheel(@xx + .5, @yy + 1)
		@wheel_bl = @wheel(@xx - .5, @yy + 1)

		@joint_wheel_tr = @revJoint @car,@wheel_tr
		@joint_wheel_tl = @revJoint @car,@wheel_tl
		@joint_wheel_br = @revJoint @car,@wheel_br
		@joint_wheel_bl = @revJoint @car,@wheel_bl

		@maxSteeringAngle = 1
		@steeringAngle = 0
		@steer_speed = 3
		@engine_speed = 300
		@mspeed = undefined
		@moveTop = false
		@moveBottom = false
		#vectors
		@p1r = new b2Vec2()
		@p2r = new b2Vec2()
		@p3r = new b2Vec2()
		@p1l = new b2Vec2()
		@p2l = new b2Vec2()
		@p3l = new b2Vec2()

	wheel: (x, y) ->
		@bodyDef = new b2BodyDef
		@bodyDef.type = b2Body.b2_dynamicBody
		@bodyDef.position.Set x, y
		@fixDef = new b2FixtureDef
		@fixDef.density = 30
		@fixDef.friction = 10
		@fixDef.restitution = 0.1
		@fixDef.shape = new b2PolygonShape
		@fixDef.shape.SetAsBox .2, .4
		@fixDef.isSensor = true
		wheel = world.CreateBody(@bodyDef)
		wheel.CreateFixture @fixDef
		wheel
	revJoint: (body1, wheel) ->
		revoluteJointDef = new b2RevoluteJointDef()
		revoluteJointDef.Initialize body1, wheel, wheel.GetWorldCenter()
		revoluteJointDef.lowerAngle = -Math.PI / 3
		revoluteJointDef.upperAngle = Math.PI / 3
		revoluteJointDef.enableLimit = true
		revoluteJointDef.motorSpeed = 0
		revoluteJointDef.maxMotorTorque = 1000
		revoluteJointDef.enableMotor = true
		revoluteJoint = world.CreateJoint(revoluteJointDef)
		revoluteJoint
	steerforward: ->
		@wheel_br.ApplyForce new b2Vec2(-@p3r.x, -@p3r.y), @wheel_br.GetWorldPoint(new b2Vec2(0, 0))
		@wheel_bl.ApplyForce new b2Vec2(-@p3l.x, -@p3l.y), @wheel_bl.GetWorldPoint(new b2Vec2(0, 0))
	steerbackward: ->
		@wheel_tr.ApplyForce new b2Vec2(@p3r.x, @p3r.y), @wheel_tr.GetWorldPoint(new b2Vec2(0, 0))
		@wheel_tl.ApplyForce new b2Vec2(@p3l.x, @p3l.y), @wheel_tl.GetWorldPoint(new b2Vec2(0, 0))
	cancelVel: (wheel) ->
		aaaa = new b2Vec2()
		bbbb = new b2Vec2()
		newlocal = new b2Vec2()
		newworld = new b2Vec2()
		aaaa = wheel.GetLinearVelocityFromLocalPoint(new b2Vec2(0, 0))
		bbbb = wheel.GetLocalVector(aaaa)
		newlocal.x = -bbbb.x
		newlocal.y = bbbb.y
		newworld = wheel.GetWorldVector(newlocal)
		wheel.SetLinearVelocity newworld				

	destroy: ->
		delete this.car_body

	drawPoint: (x,y,stage) ->


	tick:(users) ->
		self = this	
		#box2d world
		@cancelVel @wheel_tr
		@cancelVel @wheel_tl
		@cancelVel @wheel_br
		@cancelVel @wheel_br

		@mspeed = @steeringAngle - @joint_wheel_tl.GetJointAngle()
		@joint_wheel_tl.SetMotorSpeed @mspeed * @steer_speed

		@mspeed = @steeringAngle - @joint_wheel_tr.GetJointAngle()
		@joint_wheel_tr.SetMotorSpeed @mspeed * @steer_speed	

		@p1r = @wheel_tr.GetWorldCenter()
		@p2r = @wheel_tr.GetWorldPoint(new b2Vec2(0, -1))
		@p3r.x = (@p2r.x - @p1r.x) * @engine_speed
		@p3r.y = (@p2r.y - @p1r.y) * @engine_speed

		@p1l = @wheel_tl.GetWorldCenter()
		@p2l = @wheel_tl.GetWorldPoint(new b2Vec2(0, -1))
		@p3l.x = (@p2l.x - @p1l.x) * @engine_speed
		@p3l.y = (@p2l.y - @p1l.y) * @engine_speed

		if @moveTop == true
			@steerbackward()

		#if this.outOfBounds(this.car_body.x,this.car_body.y,this.car_body.bounds)
			#this.placeInBounds(this.car_body,this.car_body.bounds)

		if @leftHold == true || (leftHold == true && upHold == true && @isLocal == true)			
			@steeringAngle = -@maxSteeringAngle
			#this.car_body.rotation -=5
			#this.car_body.x -= Math.sin(this.car_body.rotation*(Math.PI/-180))*5
			#this.car_body.y -= Math.cos((this.car_body.rotation	)*(Math.PI/-180))*5

		if @rightHold == true || (rightHold == true && upHold == true && @isLocal == true)	
			@steeringAngle = @maxSteeringAngle		
			#this.car_body.rotation +=4
			#this.car_body.x -= Math.sin(this.car_body.rotation*(Math.PI/-180))*7
			#this.car_body.y -= Math.cos((this.car_body.rotation)*(Math.PI/-180))*7

		if (@leftHold != true && @rightHold != true && @upHold == true) || (leftHold != true && rightHold != true && upHold == true && @isLocal == true)
			@moveTop = true
			#this.car_body.x -= Math.sin(this.car_body.rotation*(Math.PI/-180))*6
			#this.car_body.y -= Math.cos((this.car_body.rotation)*(Math.PI/-180))*6

		#this.car_body.x = Math.min(this.max_speed, Math.max(-this.max_speed, this.car_body.x))
		#this.car_body.y = Math.min(this.max_speed, Math.max(-this.max_speed, this.car_body.y))

	outOfBounds: (x,y,bounds) -> 
		x < bounds*-2 || y < bounds*-2 || x > this.canvas_width+bounds*2 || y > this.canvas_height+bounds*2					
	
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
	socket = io.connect "http://127.0.0.1:3000"
	canvas = document.getElementById 'race'
	#local player	
	game = new GameState canvas
	users = new Array

	debugDraw = new b2DebugDraw()
	debugDraw.SetSprite canvas.getContext("2d")
	debugDraw.SetDrawScale 30 #define scale
	debugDraw.SetFillAlpha 0.3 #define transparency
	debugDraw.SetLineThickness .3
	debugDraw.SetFlags b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit
	world.SetDebugDraw debugDraw	

	SCALE = 30
	###
	# boundaries - floor
	floorFixture = new b2FixtureDef
	floorFixture.density = 1
	floorFixture.restitution = 1
	floorFixture.shape = new b2PolygonShape
	floorFixture.shape.SetAsBox 550 / SCALE, 10 / SCALE
	floorBodyDef = new b2BodyDef
	floorBodyDef.type = b2Body.b2_staticBody
	floorBodyDef.position.x = -25 / SCALE
	floorBodyDef.position.y = 509 / SCALE
	#floor = world.CreateBody(floorBodyDef)
	#floor.CreateFixture floorFixture

	# boundaries - left
	leftFixture = new b2FixtureDef
	leftFixture.shape = new b2PolygonShape
	leftFixture.shape.SetAsBox 0, 400
	leftBodyDef = new b2BodyDef
	leftBodyDef.type = b2Body.b2_staticBody
	leftBodyDef.position.x = -10
	leftBodyDef.position.y = -10
	left = world.CreateBody(leftBodyDef)
	left.CreateFixture leftFixture

	# boundaries - right
	rightFixture = new b2FixtureDef
	rightFixture.shape = new b2PolygonShape
	rightFixture.shape.SetAsBox 25 / SCALE, 480 / SCALE
	rightBodyDef = new b2BodyDef
	rightBodyDef.type = b2Body.b2_staticBody
	rightBodyDef.position.x = 450 / SCALE
	rightBodyDef.position.y = 25 / SCALE
	#right = world.CreateBody(rightBodyDef)
	#right.CreateFixture rightFixture	
	###
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
		socket.emit "join", (successful, users, user) ->
			users.pop()
			jQuery.each users, (i, remoteUser) ->
				if remoteUser.id != user.Id # добавляем пользователя только если это не мы сами
					rUser = new Car canvas, remoteUser.id
					game.addRemotePlayer rUser, remoteUser.x, remoteUser.y, remoteUser.rotation
					users.push rUser
					console.log "user pushed by user-join: " + remoteUser	

			if successful
				#creating local player
				localPlayer = new Car(canvas, 1, true) # true means that user is LOCAL
				game.addLocalPlayer localPlayer, user.x, user.y, user.rotation

				#user join event
				socket.on "user-joined", (remoteUser) ->
					rUser = new Car canvas, remoteUser.id
					game.addRemotePlayer rUser, remoteUser.x, remoteUser.y, remoteUser.rotation
					users.push rUser
					console.log "user pushed by user-join: " + remoteUser					

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
					world.Step 1 / 60, 10, 10
					world.DrawDebugData()
					world.ClearForces()

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