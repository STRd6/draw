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
  context.setTransform(t.a, t.b, t.c, t.d, t.tx, t.ty)

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
      return

    return canvas

generateMask = (width, height, t=0, canvas) ->
  debugger
  canvas ?= createCanvas(width, height)
  context = canvas.getContext('2d')

  # Clear
  context.clearRect(0, 0, width, height)

  transform = Matrix.translate(width/2, height/2).scale(width, height)

  applyTransform context, transform
  context.globalAlpha = 0.0625

  context.fillStyle = "black"
  steps = 20
  steps.times (n) ->
    context.beginPath()
    context.arc(0, 0, (n + 1 - t) * 0.5 / steps, 0, Math.TAU)
    context.closePath()
    context.fill()

    return

  # Restore
  context.globalAlpha = 1
  context.resetTransform()

  return canvas

drawImage().then (canvas) ->
  document.body.appendChild canvas

do ->
  t = 0
  dt = 1/60
  animCanvas = createCanvas(960, 540)
  document.body.appendChild animCanvas
  animateMask = ->
    window.requestAnimationFrame animateMask

    generateMask(960, 540, t, animCanvas)

    t += dt
    if t >= 1
      t = 0

  window.requestAnimationFrame animateMask
