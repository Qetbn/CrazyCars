routes = (app,models) ->

  _ = require('underscore')
  VkProfile = models.vk_profile

  app.get '/dash', (req, res) ->
    if this.session.user?
      uid = this.session.user
      VkProfile.findOne {uid: uid}, (err, vk_profile) ->
        res.render "#{__dirname}/views/dash",
        title: 'Game'
        stylesheet: 'dash'
        vk_profile: vk_profile

module.exports = routes    
