class CoreGameplayState
  MOVE_SPEED = 300
  NUM_CLOUDS = 5 # max on screen at once
  
  # These other NUM constants are how many live at once
  # (not necessarily the number you see on screen).
  NUM_BALLOONS = 5
  NUM_BIRDS = 3
  
  # Maximum speeds (usually range is 50-100% of this value)
  MAX_CLOUD_SPEED = 200
  MAX_BALLOON_SPEED = 250  
    
  preload: () ->  
    @game.load.image('sky', 'assets/graphics/sky.png')
    @game.load.image('cloud', 'assets/graphics/cloud.png')
    @game.load.image('player', 'assets/graphics/player.png')
    @game.load.image('balloon', 'assets/graphics/balloon.png')
    @game.load.image('ui-balloons', 'assets/graphics/balloons.png')

  create: () ->
    @game.physics.startSystem(Phaser.Physics.ARCADE)
    @numBalloonsCollected = 0
    
    #  A simple background for our game
    @game.add.sprite(0, 0, 'sky')    
    @clouds = @game.add.group()
    @clouds.enableBody = true

    # NUM_CLOUDS clouds, randomly strewn
    for i in [1..NUM_CLOUDS]
      randomX = this._pickCloudX();
      randomY = Math.random() * @game.height
      cloud = @clouds.create(randomX, randomY, 'cloud')
      quarterSpeed = MAX_CLOUD_SPEED / 4      
      # 25-100% of MAX_CLOUD_SPEED
      cloud.body.velocity.x = -(Math.random() * 3 * quarterSpeed) - quarterSpeed
      scale = this._pickCloudScale()
      cloud.scale.setTo(scale, scale)      
    
    @balloons = @game.add.group()
    @balloons.enableBody = true
      
    # NUM_BALLOONS balloons, randomly strewn
    for i in [1..NUM_BALLOONS]
      this._spawnBalloon()
    
    balloons = @game.add.sprite(8, @game.height - 64 - 8, 'ui-balloons')
    
    @numBalloons = @game.add.text(16, @game.height - 32, 'x0', { fill: '#000' })
    
    @player = @game.add.sprite(0, 0, 'player')
    @game.physics.enable(@player, Phaser.Physics.ARCADE)
    
    @game.camera.follow(@player)
    @cursors = game.input.keyboard.createCursorKeys()    
    
  update: () ->
    @game.physics.arcade.overlap(@player, @balloons, this._balloonCollected, null, this)
      
    this._updatePlayerVelocity()
    this._respawnOffScreenClouds()
    this._applyWavesToBalloons()
    this._respawnOffScreenBalloons()
    
  # begin: private methods
  
  _updatePlayerVelocity: () ->
    if @cursors.up.isDown
      @player.body.velocity.y = -1 * MOVE_SPEED;
    else if @cursors.down.isDown
      @player.body.velocity.y = MOVE_SPEED;
    else
      # Standing still
    
    if @cursors.left.isDown
      @player.body.velocity.x = -1 * MOVE_SPEED;
    else if @cursors.right.isDown
      @player.body.velocity.x = MOVE_SPEED;
    else
      # Standing still
    
    # Decelerate
    @player.body.velocity.x *= 0.9 if @player.body.velocity.x != 0      
    @player.body.velocity.y *= 0.9 if @player.body.velocity.y != 0
      
    @player.body.velocity.x = 0 if Math.abs(@player.body.velocity.x) <= 5
    @player.body.velocity.y = 0 if Math.abs(@player.body.velocity.y) <= 5
    
  _respawnOffScreenClouds: () ->
    @clouds.forEach((cloud) ->
      if cloud.x <= -cloud.width
        cloud.x = this._pickCloudX()
        cloud.y = Math.random() * @game.height
        scale = this._pickCloudScale()
        cloud.scale.setTo(scale, scale)
    , this)
    
  _respawnOffScreenBalloons: () ->
    @balloons.forEach((balloon) ->
      if balloon.x <= -balloon.width
        balloon.x = this._pickCloudX()
        balloon.y = Math.random() * (@game.height - 64)
        balloon.randomY = (Math.random() * 500)
    , this)
    
  _applyWavesToBalloons: () ->
    @balloons.forEach((balloon) ->
      balloon.y += (2 * Math.sin((@game.time.now + balloon.randomY) / 500))
    , this)
    
  _pickCloudX: () ->
    return @game.width + (Math.random() * @game.width) 
  
  _pickCloudScale: () ->
    return 0.25 + (Math.random() * 0.75)
    
  _balloonCollected: (player, balloon) ->
      balloon.kill()
      @numBalloonsCollected += 1
      @numBalloons.text = "x#{@numBalloonsCollected}"
      this._spawnBalloon()
      
  _spawnBalloon: () ->
    randomX = this._pickCloudX();
    randomY = Math.random() * (@game.height - 64)
    balloon = @balloons.create(randomX, randomY, 'balloon')
    # 50-100% of target speed
    halfSpeed = MAX_BALLOON_SPEED / 2
    balloon.body.velocity.x = -(Math.random() * halfSpeed) - halfSpeed
    balloon.randomY = (Math.random() * 2500)
    
window.onload = () ->  
  @game = new Phaser.Game(800, 600, Phaser.AUTO, '', new CoreGameplayState)  

