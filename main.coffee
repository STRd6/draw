require "cornerstone"

style = document.createElement "style"
style.textContent = require "./style"
document.head.appendChild style

draw = (img) ->
  context.drawImage(img, 0, 0)

eventToLocal = (element, event) ->
  {left, top} = element.getBoundingClientRect()
  {clientX, clientY} = event

  x: clientX - left
  y: clientY - top

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

    targetPoint = Point(width/2, height/2)

    -> # Add movement listener
      document.addEventListener "mousemove", (e) ->
        {x, y} = eventToLocal(canvas, e)

        targetPoint.x = x
        targetPoint.y = y

        return

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
      context.filter = "none"

      context.drawImage(img, 0, 0)

      steps = 6
      steps.times (n) ->
        context.filter = ""
        ratio = 1 - (n + t) / steps

        if n is 0
          context.globalAlpha = t
        else
          context.globalAlpha = 1

        transform = Matrix.scale(ratio, ratio, targetPoint)
        applyTransform(context, transform)

        context.filter = "hue-rotate(#{90 - ratio * 360}deg)"
        # context.globalCompositeOperation = "hard-light"
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

    t += dt
    if t >= 1
      t = 0

    canvas.draw(t)

  window.requestAnimationFrame animate
