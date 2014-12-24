PIXI = require 'pixi.js'
FlipBook = require "../flip_book"
_ = require 'lodash'
$ = require 'jquery'
DebugShapes = require '../debug_shapes'
Mousetrap = require '../vendor/mousetrap_wrapper'
window.wtf = Mousetrap

KeyboardController = require '../keyboard_controller'

class Cycle
  constructor: (arr) ->
    @_items = _.clone(arr)
    @_i = 0
    @_length = @_items.length
  
  next: ->
    x = @_items[@_i]
    @_i += 1
    @_i = 0 if @_i >= @_length
    x



class SamusPreview
  constructor: ->

  setupInput: ->
    $('#d-pad-right').on "click", =>
      @buttonRight()
    $('#reset').on "click", =>
      @reset()
    # Mousetrap.bind 'right', => @buttonRight()
    Mousetrap.bind 'r', => @reset()

    Mousetrap.bind 'w', => @cursorUp()
    Mousetrap.bind 'a', => @cursorLeft()
    Mousetrap.bind 's', => @cursorDown()
    Mousetrap.bind 'd', => @cursorRight()
    Mousetrap.bind 'z', => @stand()

    @keyboardController = new KeyboardController
      "right": 'runRight'

  graphicsToPreload: ->
    [ "images/samus.json"
      "images/room0.png"
    ]

  slice: (col,keys) ->
    _.pick col, (v,k) -> _.contains(keys,k)

  setupStage: (@stage) ->
    @mapLayer = new PIXI.DisplayObjectContainer()
    @mapLayer.scale.set(1.25,1)
    @stage.addChild @mapLayer

    @sampleMapBg = PIXI.Sprite.fromFrame("images/room0.png")
    @mapLayer.addChild @sampleMapBg
    
    @spriteLayer = new PIXI.DisplayObjectContainer()
    @spriteLayer.scale.set(2.666,2)
    @stage.addChild @spriteLayer
    window.spriteLayer = @spriteLayer

    @overlay = new PIXI.DisplayObjectContainer()
    @overlay.scale.set(2.666,2)
    @stage.addChild @overlay

    @spritesByName = @collectSprites()

    # XXX
    window.sprites = @spritesByName
    window.stage = @stage

    # @layoutAllSprites(@spritesByName)
    # names = new Cycle(_.keys(@spritesByName))
    
    runningSprites = @slice @spritesByName, [
      # "samus1-04-00"
      "samus1-06-00"
      "samus1-07-00"
      "samus1-08-00"
    ]
    runningSprites["samus1-06-00"]
    @runFrames = new Cycle(_.keys(runningSprites))
    window.runningSprites = runningSprites

    # @flipBook = new FlipBook(@spritesByName, defaultFrame: "samus1-03-00")
    @flipBook = new FlipBook @spritesByName
    
    # @flipBook.renderable = true
    # @flipBook.scale.set(4,4)
    # @flipBook.interactive = true
    # @flipBook.mousedown = (data) =>
      # console.log "flipbook:",data
    @flipBook.x = 50
    @flipBook.y = 208
    window.book = @flipBook

    # @flipBookTracker = DebugShapes.dot()
    # @flipBookTracker.updatePosition(@flipBook.position)

    @spriteLayer.addChild(@flipBook)

    # @addBoxes()

    @cursor = new PIXI.Graphics()
    @cursor.lineStyle(1, 0x9999FF)
    @cursor.drawRect(-5,-5,10,10)
    @cursor.moveTo(0,0).lineTo(-5,0).moveTo(0,0).lineTo(0,-5).moveTo(0,0).lineTo(5,0).moveTo(0,0).lineTo(0,5)
    @cursor.position.set(0,0)
    @overlay.addChild(@cursor)

    @setupInput()
    @holdTime = null 

  addBoxes: ->
    size = 10
    y = 200
    for i in [0...100]
      box = new PIXI.Graphics()
      box.lineStyle(1, 0x00FF00)
      box.drawRect(0,0,size,size)
      box.position.set(i*size, y)
      @overlay.addChild(box)

  buttonRight: ->
    @flipBook.showFrame(@runFrames.next())
    # @flipBook.x += 15
    # @cursorTo @flipBook.position

  stand: ->
    @flipBook.showFrame("samus1-04-00")



  reset: ->
    @flipBook.x = 50

  layoutAllSprites: (sprites) ->
    topEdge = 0
    leftEdge = 0
    rightEdge = 512
    console.log "rightEdge: #{rightEdge}"
    cursorX = leftEdge
    cursorY = topEdge
    for name,sprite of sprites
      if cursorX + sprite.width > rightEdge
        cursorX = 0
        cursorY += sprite.height + 10
      sprite.position.x = cursorX
      sprite.position.y = cursorY
      @stage.addChild sprite
      cursorX += sprite.width


  collectSprites: ->
    byName = {}
    # for i in [0..28]
    for i in [4,6,7,8]
      snum = @_lpad("00", i)
      fname = "samus1-#{snum}-00"
      sprite = PIXI.Sprite.fromFrame(fname)
      sprite.anchor.set(0.5,1)
      # sprite.scale.set(4,4)
      # sprite.interactive = true
      # sprite.mousedown = (data) ->
      #   console.log "SPRITE MOUSEDOWN", data
      # sprite.scale.x = 2
      # sprite.scale.y = 2
      byName[fname] = sprite
    byName

  update: (dt) ->
    x = @keyboardController.update()
    console.log x if x

    if @keyboardController.isActive('runRight')
      @runRight = true
    else
      @runRight = false
      @holdTime = null
      

    if @runRight
      @holdTime += dt if @holdTime?
      if !@holdTime? or @holdTime > 0.05 # 20 fps means 1/20 delay between frames
        @flipBook.showFrame(@runFrames.next())
        @holdTime = 0
      @flipBook.x += 88 * dt
    else
      @flipBook.showFrame("samus1-04-00")

  ################

  _lpad: (fmt,num) ->
    str = ""+num
    fmt.substring(0,fmt.length - str.length) + str

  cursorTo: (pos) ->
    @cursor.position.set(pos.x,pos.y)

  cursorUp: ->
    @cursor.y -= 10
    @showCursorPosition()
  cursorLeft: ->
    @cursor.x -= 10
    @showCursorPosition()
  cursorDown: ->
    @cursor.y += 10
    @showCursorPosition()
  cursorRight: ->
    @cursor.x += 10
    @showCursorPosition()

  showCursorPosition: ->
    console.log "CURSOR: #{@cursor.x},#{@cursor.y}"

module.exports = SamusPreview

