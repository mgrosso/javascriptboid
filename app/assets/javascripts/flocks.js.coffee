class @Flock
  constructor: (@name, @avoid, @align, @center, @jitter, @goalseek, @boids, @boidsize, @width, @height ) ->
    
  _random_velocity: (scale) ->
    ((Math.random() + Math.random() + Math.random()) / 3 ) * scale - scale / 2
  _random_velocities: (scale) ->
    (this._random_velocity(scale)  for i in [1.. @boids * 2])
  
  toggle_component: (component) ->
    if @arrow_show[component]
        delete @arrow_show[component]
    else
        @arrow_show[component] = @arrow_colors[component]
  initialize: ->
    # params that need to be passed in, not hard coded:
    $("#cv").bind  'click', (e) => @click( e)
    @arrow_show = { }
    @arrow_colors = {
      inertia: "#000000",
      avoid:   "#ff0000",
      center:  "#00ff00",
      align:   "#0000ff",
      goalseek:"#aaaa00",
      jitter:  "#00aaaa",
      }
    @inertia = 0.9
    @maxv = @boidsize 
    @neighbor_cutoff = @boidsize * 10
    @avoid_cutoff = @boidsize * 2
    @max_neighbors = 4
    # state that changes
    @running = 0
    @loopnum = 0
    @p = ((Math.random() * @width ) for i in [1.. @boids * 2])
    @v = this._random_velocities(@maxv ) 
    @r = new FlockCanvas( @width, @height )
    @r.initialize()
    this
  _draw_bird: (id) ->
    idx = id * 2
    x = @p[idx]
    y = @p[idx+1]
    @r.draw_bird @p[idx], @p[idx+1], @boidsize / 2
    if @halo 
      @r.draw_halo x, y, @neighbor_cutoff 
      @r.draw_halo x, y, @avoid_cutoff 
    for key, color of @arrow_show
      xy2 = @arrows[key][id]
      @r.draw_line x, y, x + 10 * xy2[0], y + 10 * xy2[1], color
    this
  draw: ->
    ( this._draw_bird i ) for i in [0..(@boids-1)]
    this
  redraw: ->
    @r.refresh()
    this.draw()
  _adjust: ( p, delta, max ) ->
    ret = p + delta
    if ret < 0
      ret = max - ret
    else if ret > max
      ret = ret - max
    ret
  _zeros: (len = @boids * 2 ) -> 
    (0 for i in [1..len])
  _length: (a, b) ->
    Math.sqrt( a * a + b * b )
  _pdelta: (a1, a2, size ) ->
    d1 = a1 - a2
    d2 = size + a2 - a1
    ret = if Math.abs(d1) < Math.abs(d2) then d1 else d2
  _norm: (x, y) ->
    if x==0 and y==0 
      ret = [ 0, 0]
    else
      len = @_length(x,y)
      ret = [ x / len, y / len ] 
  _distances: ->
    @neighbors = new NNearest @max_neighbors, @neighbor_cutoff
    @distances = []
    @xdeltas   = []
    @ydeltas   = []
    for i in [0..(@boids-1)]
      for j in [0..(@boids-1)] when j isnt i and j > i
        xd = @_pdelta( @p[i*2], @p[j*2], @width )
        yd = @_pdelta( @p[i*2 + 1], @p[j*2 + 1], @height )
        d = @distances[ i * @boids + j ] = Math.sqrt( xd * xd + yd * yd )
        @neighbors.add d, i, j
        @xdeltas[i * @boids + j] = xd
        @xdeltas[j * @boids + i] = - xd
        @ydeltas[i * @boids + j] = yd
        @ydeltas[j * @boids + i] = - yd
    @distances
  _distance: (i, j ) ->
    if i == j 
      [ 0, 0, 0 ]
    else if j < i
      [ 
        @distances[j * @boids + i], 
        @xdeltas[i * @boids + j], 
        @ydeltas[i * @boids + j] 
      ]
    else
      [ 
        @distances[i * @boids + j],
        @xdeltas[i * @boids + j], 
        @ydeltas[i * @boids + j] 
      ]
  _force: (distance, cutoff) ->
    force = @boidsize / ( distance * distance )
    force = 0 if distance > cutoff 
    force
  _avoid: ->
    ret = @_zeros()
    for i in [0..(@boids-1)]
      ixd = iyd = nixd = niyd = 0
      for j in [0..(@boids-1)] when j isnt i
        [ distance, xd, yd ] = @_distance( i, j )
        force = @_force(distance, @avoid_cutoff )
        ixd = ixd + xd * force
        iyd = iyd + yd * force
        #console.log '_avoid',i,j,'diff=',xd,yd,'distance,force =',distance,force,'ixd,iyd=',ixd,iyd 
      [ nixd, niyd ] = @_norm( ixd, iyd)
      #console.log '_avoid B: ',i, ixd, iyd, nixd, niyd
      ret[i*2] = nixd
      ret[i*2 + 1] = niyd
    ret
  _align: ->
    ret = @_zeros()
    for i, pairs of @neighbors.all()
      x = y = weight = 0
      for pair in pairs
        w = 1 / pair[0]
        j = pair[1]
        weight = weight + w
        x = x + w * @v[j*2]
        y = y + w * @v[j*2+1]
      ret[i*2] = if weight == 0 then 0 else x / weight
      ret[i*2+1] = if weight == 0 then 0 else y / weight
    ret
  _center: ->
    ret = @_zeros()
    for i, pairs of @neighbors.all()
      x = y = 0
      for pair in pairs
        j = pair[1]
        x = x + @v[j*2]
        y = y + @v[j*2+1]
      sz = pairs.length
      ret[i*2] = x / sz
      ret[i*2+1] = y / sz
    ret
  _update_velocities: ->
    zeros  = @_zeros()
    @arrows= { 
      inertia: [],
      avoid:   [],
      center:  [],
      align:   [],
      goalseek:[],
      jitter:  [],
      velocity:[]
      }
    @_distances()
    new_vpairs = [
        [@v,                    @inertia,   'inertia'], 
        [@_avoid(),             @avoid,     'avoid'],
        [@_center(),            @center,    'center'],
        [@_align(),             @align,     'align'], 
        [zeros,                 @goalseek,  'goalseek'],
        [@_random_velocities(1), @jitter,    'jitter'], 
    ]
    @vpairs = new_vpairs
    #console.log @vpairs
    for id in [0..(@boids-1)]
      xi = id * 2
      yi = xi + 1
      len = weight = x = y = 0
      for pair in @vpairs
        @arrows[ pair[2] ][ id ] = [ 0, 0 ]
        continue if len >= @maxv
        ar= pair[0]
        w = pair[1]
        weight = weight + w
        dx = ar[xi] * w
        dy = ar[yi] * w
        delta_len = Math.sqrt( dx * dx + dy * dy )
        if delta_len + len > @maxv
          delta_len = @maxv - len
          dx = dx / delta_len
          dy = dy / delta_len
        x = x + dx
        y = y + dy
        @arrows[ pair[2] ][ id ] = [ x, y ]
      @v[xi] = x
      @v[yi] = y
      @arrows[ 'velocity' ][ id ] = [ x, y ]
    this
  _update: ->
    @_update_velocities()
    for i in [0..(@boids * 2 -1)]
      @p[i] = @_adjust(@p[i], @v[i], (if (i % 2 == 0) then @width else @height ) )
    this
  _frame: ->
    return if @updating == 1 || @running == 0
    if @maxloops > 0
      return if @loopnum++  > @maxloops
    @updating = 1
    this.step()
    @updating = 0
  step: ->
    this._update().redraw()
  start: (loops = -1 ) ->
    @maxloops = loops
    unless @running > 0
      @running = 1
      f = => @_frame()
      setInterval( f, 30)
    this
  stop: ->
    @running = 0
  toggle_halo: ->
    if @halo? and @halo == 1
      @halo = 0 
    else 
      @halo = 1
  nearest: (x,y) ->
    shortest = @width * @width + @height * @height 
    best = -1
    for id in [0..(@boids - 1)] 
      ix = @p[id * 2]
      iy = @p[id * 2 + 1]
      dx = @_pdelta( x, ix, @width)
      dy = @_pdelta( y, iy, @height)
      len = Math.sqrt( dx * dx + dy * dy )
      console.log id, shortest, x, y, ix, iy, dx, dy, len
      if len < shortest 
        best = id
        shortest= len
    best
  is_within: (id, x, y ) ->
    ix = @p[id * 2]
    iy = @p[id * 2 + 1]
    dx = ix - x
    dy = iy - y
    diff2 = dx * dx + dy * dy
    rad2 = (@boidsize/2) * ( @boidsize / 2)
    console.log 'is_within', id, x, y, ix, iy, dx, dy, diff2, rad2 
    diff2 < rad2
  click: (e) ->
    return unless @offset?
    x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft - Math.floor(@offset.left)
    y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop - Math.floor(@offset.top) + 1;
    near = @nearest(x,y)
    within = @is_within(near,x,y)
    console.log x, y, @offset, e, near, within


