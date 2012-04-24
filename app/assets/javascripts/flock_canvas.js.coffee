class @FlockCanvas
  constructor: (@width, @height ) ->
    
  initialize: ->
    $("#cv").bind  'click', (e) => @click( e)
    jqobj = $("#cv")
    @cnv = jqobj.get 0
    @cnv.width = @width
    @ctx = @cnv.getContext '2d'
    @pi2 = 2 * Math.PI
    this
  draw_halo: (x,y,size) -> 
    @ctx.beginPath()
    @ctx.arc x, y, size, 0, @pi2, false
    @ctx.closePath()
    @ctx.strokeStyle = "#232323"
    @ctx.stroke()
  draw_circle: (x,y,size) -> 
    @ctx.beginPath()
    @ctx.arc x, y, size, 0, @pi2, false
    @ctx.fillStyle = "#a8cb8a"
    @ctx.fill()
    @ctx.closePath()
    @ctx.strokeStyle = "#232323"
    @ctx.stroke()
    this
  draw_line: (x1,y1,x2,y2,color) ->
    @ctx.beginPath()
    @ctx.moveTo x1, y1
    @ctx.lineTo x2, y2
    @ctx.lineWidth = 1
    @ctx.strokeStyle = color
    @ctx.stroke()
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
  click: (e) ->
    return unless @offset?
    x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft - Math.floor(@offset.left)
    y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop - Math.floor(@offset.top) + 1;
    console.log x, y, @offset, e

