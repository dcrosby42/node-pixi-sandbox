jquery    = require 'jquery'

PixiHarness = require './pixi_harness'
SamusPreview = require './samus/preview'
BigScreen = require './vendor/bigscreen_wrapper'

jquery ->
  el = jquery('#game-holder')[0]

  samusPreview = new SamusPreview()
  harness = new PixiHarness
    domElement: el
    delegate: samusPreview
    width: 640
    height: 480
    stage_background: 0x000033

  harness.start()

  gameView = harness.view
  $('#fullscreen').on "click", ->
    BigScreen.doTheBigThing gameView


# for console debugging and messing around:
window.$  = jquery
window._  = require 'lodash'

# [
#   {offset: 0, frame: "F0"}
#   {offset: 50, frame: "F1"}
#   {offset: 100, frame: "F2"}
#   # how would I know to wait 50 millis before flipping back to 0?
# ]

