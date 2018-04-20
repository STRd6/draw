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

createCanvas = (width, height) ->
  canvas = document.createElement 'canvas'
  canvas.width = width
  canvas.height = height
  
  return canvas

applyTransform = (context, t) ->
  context.transform(t.a, t.b, t.c, t.d, t.tx, t.ty)

drawImage = ->
  imageFromURL("https://danielx.whimsy.space/cdn/images/sky.jpg")
  .then (img) ->
    {width, height} = img

    canvas = createCanvas(width, height)
    context = canvas.getContext('2d')

    tmpCanvas = createCanvas(width, height)
    tmpContext = tmpCanvas.getContext('2d')
    maskCanvas = generateMask(width, height)

    context.drawImage(img, 0, 0)

    transform = Matrix.scale(0.95, 0.95, Point(width/2, height/2))
    console.log transform
    applyTransform(context, transform)

    context.globalAlpha = 0.27
    # context.globalCompositeOperation = "hard-light"

    [0..10].forEach ->
      # Draw with mask
      tmpContext.globalCompositeOperation = "source-over"
      tmpContext.clearRect(0, 0, width, height)
      tmpContext.drawImage(maskCanvas, 0, 0)
      tmpContext.globalCompositeOperation = "source-in"
      tmpContext.drawImage(canvas, 0, 0)

      context.drawImage(tmpCanvas, 0, 0)

      # draw without mask
      # context.drawImage(canvas, 0, 0)

    return canvas

generateMask = (width, height) ->
  canvas = createCanvas(width, height)
  context = canvas.getContext('2d')

  # Clear
  context.clearRect(0, 0, width, height)

  transform = Matrix.translate(width/2, height/2).scale(width, height)
  console.log transform
  applyTransform context, transform
  context.globalAlpha = 0.0625

  steps = 50
  [0...steps].forEach (n) ->
    context.arc(0, 0, (n + 1) * 0.5 / steps, 0, Math.TAU)
    context.fillStyle = "black"
    context.fill()

  return canvas

drawImage().then (canvas) ->
  document.body.appendChild canvas
