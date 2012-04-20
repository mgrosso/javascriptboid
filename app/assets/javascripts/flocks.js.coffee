class FlockRenderCanvas
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

class Flock
  constructor: (@name, @avoid, @align, @center, @jitter, @goalseek, @boids, @boidsize, @width, @height ) ->
    
  random_velocity: ->
    ((Math.random() + Math.random() + Math.random()) / 3 ) * @boidsize - @boidsize / 2
  
  initialize: ->
    @p = ((Math.random() * @width ) for i in [1.. @boids * 2])
    @v = (this.random_velocity() for i in [1.. @boids * 2])
    @r = new FlockRenderCanvas( @width, @height )
    @r.initialize()
    this
  draw_bird: (id) ->
    idx = id * 2
    @r.draw_bird @p[idx], @p[idx+1], @boidsize / 2
    this
  draw: ->
    ( this.draw_bird i ) for i in [0..(@boids-1)]
    this
  redraw: ->
    @r.refresh()
    this.draw()
  update: ->
    ( @p[i] = @p[i] + @v[i] ) for i in [0..(@boids * 2 -1)]
    this
  frame: ->
    this.live = 1
    this.update().redraw()
    this.live = 0
  loop: ->
    f = => this.frame()
    setInterval( f, 30)
    this
    

this.draw_flock = ->
  f = new Flock "MyFlock", 1, 1, 1, 1, 1, 10, 30, 500, 500
  return f

