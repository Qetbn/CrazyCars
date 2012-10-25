module.exports = (mongoose) ->
  Schema = mongoose.Schema
  ObjectId = Schema.ObjectId
  VkProfileSchema = new Schema {
    uid : Number,
    score: { type:Number, default: 0}
    bdate : { type: Date, default: Date.now },
    signed : { type: Date, default: Date.now },
    first_name : String,
    last_name : String,
    nickname : String,
    domain : String,
    sex : String,
    city : String,
    country : String,
    timezone : String,
    photo : String,
    photo_medium : String,
    photo_big : String,
    photo_rec : String,
    has_mobile : String,
    rate : String,
    mobile_phone : String,
    home_phone : String,
    university : String,
    university_name : String,
    faculty : String,
    faculty_name : String,
    graduation : String
  }

  this.model = mongoose.model('vk_profile', VkProfileSchema)

  return this
