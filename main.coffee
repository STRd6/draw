require "cornerstone"

canvas = document.createElement 'canvas'

document.body.appendChild canvas

context = canvas.getContext('2d')

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

imageFromURL("https://danielx.whimsy.space/cdn/images/sky.jpg")
.then (img) ->
  {width, height} = img
  console.log width, height
  canvas.width = width
  canvas.height = height

  draw(img)

  transform = Matrix.scale(0.95, 0.95, Point(width/2, height/2))
  console.log transform
  applyTransform(context, transform)
  
  context.globalAlpha = 0.27
  # context.globalCompositeOperation = "hard-light"

  [0..10].forEach ->
    draw(canvas)
