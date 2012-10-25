io = (app,models,io) ->

	sio = io.listen app
	sio.configure ->
		sio.set "log-level", 5 

	_ = require 'underscore'
	io = require 'socket.io'

	VkProfile = models.vk_profile
	users = []

	getRandomInt = (min, max) ->
		Math.floor(Math.random() * (max - min + 1)) + min	

	updateById = (users, id, x, y, rotation) ->
		users.map (user) ->
			if user.id == id
				user.x = x
				user.y = y
				user.rotation = rotation

	sio.sockets.on "connection", (socket) ->
		socket.on 'join', (callback) ->
			user = {}
			user.x = getRandomInt 150,350
			user.y = getRandomInt 150,350
			user.rotation = getRandomInt 0,360
			user.id = socket.id
			socket.broadcast.emit "user-joined", user
			users.push user
			callback true, users, user

		socket.on "disconnect", ->
			users.splice users.indexOf socket.id, 1
			socket.broadcast.emit "user-left", socket.id

		socket.on "move", (direction,x,y,rotation) ->
			updateById(users, socket.id, x, y, rotation)
			socket.broadcast.emit "move", socket.id, direction

		socket.on "end_move", (direction,x,y,rotation) ->
			updateById(users, socket.id, x, y, rotation)
			socket.broadcast.emit "end_move", socket.id, direction, x, y

module.exports = io
