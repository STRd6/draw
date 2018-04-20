require "cornerstone"

draw = (img) ->
  context.drawImage(img, 0, 0)

imageFromURL = (url) ->
  new Promise (resolve, reject) ->
    img = new Image
    img.onload = ->
      resolve img
    img.onerror = reject

    img.src = url

applyTransform = (context, t) ->
  context.transform(t.a, t.b, t.c, t.d, t.tx, t.ty)

drawImage = ->
  imageFromURL("https://danielx.whimsy.space/cdn/images/sky.jpg")
  .then (img) ->
    canvas = document.createElement 'canvas'
    context = canvas.getContext('2d')

    {width, height} = img
    canvas.width = width
    canvas.height = height

    context.drawImage(img, 0, 0)

    transform = Matrix.scale(0.95, 0.95, Point(width/2, height/2))
    console.log transform
    applyTransform(context, transform)

    context.globalAlpha = 0.27
    # context.globalCompositeOperation = "hard-light"

    [0..10].forEach ->
      context.drawImage(canvas, 0, 0)

    return canvas

generateMask = (width, height) ->
  canvas = document.createElement 'canvas'
  canvas.width = width
  canvas.height = height
  context = canvas.getContext('2d')

  # Clear
  context.fillStyle = "black"
  context.fillRect(0, 0, width, height)

  transform = Matrix.translate(width/2, height/2).scale(width, height)
  console.log transform
  applyTransform context, transform
  context.globalAlpha = 0.0625

  steps = 50
  [0...steps].forEach (n) ->
    context.arc(0, 0, (n + 1) * 0.5 / steps, 0, Math.TAU)
    context.fillStyle = "white"
    context.fill()

  return canvas

document.body.appendChild generateMask(960, 540)

drawImage().then (canvas) ->
  document.body.appendChild canvas
