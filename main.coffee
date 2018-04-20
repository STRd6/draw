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

loadImage = ->
  imageFromURL("https://danielx.whimsy.space/cdn/images/sky.jpg")
  .then (img) ->
    {width, height} = img

    canvas = createCanvas(width, height)
    context = canvas.getContext('2d')

    tmpCanvas = createCanvas(width, height)
    tmpContext = tmpCanvas.getContext('2d')
    maskCanvas = generateMask(width, height)

    # Draw with mask
    tmpContext.globalCompositeOperation = "source-over"
    tmpContext.clearRect(0, 0, width, height)
    tmpContext.drawImage(maskCanvas, 0, 0)
    tmpContext.globalCompositeOperation = "source-in"
    tmpContext.drawImage(img, 0, 0)

    canvas.draw = (t) ->
      context.resetTransform()
      context.globalCompositeOperation = "source-over"
      context.drawImage(img, 0, 0)

      # context.globalCompositeOperation = "hard-light"

      steps = 5
      steps.times (n) ->
        ratio = 1 - (n + t) / steps

        if n is 0
          context.globalAlpha = t
        else
          context.globalAlpha = 1

        transform = Matrix.scale(ratio, ratio, Point(width/2, height/2))
        applyTransform(context, transform)

        context.drawImage(tmpCanvas, 0, 0)
  
        # draw without mask
        # context.drawImage(canvas, 0, 0)
        return

    return canvas

generateMask = (width, height, canvas) ->
  canvas ?= createCanvas(width, height)
  context = canvas.getContext('2d')

  # Clear
  context.clearRect(0, 0, width, height)

  transform = Matrix.translate(width/2, height/2).scale(width, height)

  applyTransform context, transform

  context.fillStyle = "black"
  steps = 20
  steps.times (n) ->
    context.globalAlpha = 0.0625
    context.beginPath()
    context.arc(0, 0, n * 0.5 / steps, 0, Math.TAU)
    context.closePath()
    context.fill()

    return

  # Restore
  context.globalAlpha = 1
  context.resetTransform()

  return canvas

loadImage().then (canvas) ->
  document.body.appendChild canvas

  t = 0
  dt = 1/60
  animate = ->
    window.requestAnimationFrame animate

    canvas.draw(t)

    t += dt
    if t >= 1
      t = 0

  window.requestAnimationFrame animate
