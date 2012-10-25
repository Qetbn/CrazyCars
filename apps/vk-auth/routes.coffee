routes = (app,models) ->

  _ = require('underscore')
  VkProfile = models.vk_profile

  parseDate = (input) ->
    parts = input.match(/(\d+)/g)
    return new Date(parts[2], parts[1]-1, parts[0])

  app.get '/vk', (req, res) ->

    app.log.info 'Got connection to API'
    if _.isString(req.query.api_result)

      user = JSON.parse(req.query.api_result)
      user.response[0]['signed'] = new Date
      user.response[0]['bdate'] = parseDate(user.response[0]['bdate'])
      # vk_profile is prepared -> searching it in database
      VkProfile.findOne {uid: user.response[0]['uid']}, (err,docs) ->
        if err?
          app.log.error 'Error with searching users in DB'
          res.redirect('/')
        else
          if _.isObject(docs) && docs.uid?
            app.log.info 'User found, authentificating...'
          else
            app.log.info 'Coldnt find user, creating new...'
            newUser = new VkProfile(user.response[0])
            newUser.save (err) ->
              if err?
                app.log.error 'Got error with creating new user: '+err

      this.session.user = user.response[0]['uid']
      res.redirect('/dash')     

    else
      app.log.warn 'User without handshake sting'
      res.redirect('/login')


module.exports = routes    
