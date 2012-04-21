class @FlockCanvas
  constructor: (@width, @height ) ->
    
  initialize: ->
    jqobj = $("#cv")
    @cnv = jqobj.get 0
    @cnv.width = @width
    @ctx = @cnv.getContext '2d'
    @pi2 = 2 * Math.PI
    this
  draw_circle: (x,y,size) -> 
    @ctx.beginPath()
    @ctx.arc x, y, size, 0, @pi2, false
    @ctx.fillStyle = "#a8cb8a"
    @ctx.fill()
    @ctx.closePath()
    @ctx.strokeStyle = "#232323"
    @ctx.stroke()
    this
  draw_rect: (x,y,size) -> 
    @ctx.lineWidth = 4
    @ctx.strokeStyle = "#4ed66f"
    @ctx.strokeRect x, y, size, size
    this
  refresh: -> 
    @ctx.fillStyle = "#ffffff"
    @ctx.fillRect(0, 0, @width, @height)
    this
  draw_bird: (x,y,size) -> 
    this.draw_circle x, y, size


