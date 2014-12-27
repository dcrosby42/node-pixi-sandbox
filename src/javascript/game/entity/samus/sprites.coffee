sprites =
  samus:
    spriteSheet: "images/samus.json"
    states:
      "stand-right":
        frame: "samus1-04-00"
      "run-right":
        frames: [
          "samus1-06-00"
          "samus1-07-00"
          "samus1-08-00"
        ]
        fps: 20
      "stand-left":
        frame: "samus1-04-00"
        modify:
          scale: { x: -1 }
      "run-left":
        frames: [
          "samus1-06-00"
          "samus1-07-00"
          "samus1-08-00"
        ]
        fps: 20
        modify:
          scale: { x: -1 }
    modify:
      anchor: { x: 0.5, y: 1 }

module.exports = sprites
