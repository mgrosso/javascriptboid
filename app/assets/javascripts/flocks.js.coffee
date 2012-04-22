class @Flock
  constructor: (@name, @avoid, @align, @center, @jitter, @goalseek, @boids, @boidsize, @width, @height ) ->
    
  random_velocity: (scale) ->
    ((Math.random() + Math.random() + Math.random()) / 3 ) * scale - scale / 2
  random_velocities: (scale) ->
    (this.random_velocity(scale)  for i in [1.. @boids * 2])
  
  initialize: ->
    # params that need to be passed in, not hard coded:
    @inertia = 1
    @vscale = @boidsize * 5
    @neighbor_cutoff = @boidsize * 10
    @max_neighbors = 4
    # state that changes
    @running = 0
    @loopnum = 0
    @p = ((Math.random() * @width ) for i in [1.. @boids * 2])
    @v = this.random_velocities(@vscale ) 
    @r = new FlockCanvas( @width, @height )
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
    force = 0 if distance > @boidsize * cutoff 
    force
  _avoid: ->
    ret = @_zeros()
    for i in [0..(@boids-1)]
      ixd = iyd = nixd = niyd = 0
      for j in [0..(@boids-1)] when j isnt i
        [ distance, xd, yd ] = @_distance( i, j )
        force = @_force(distance, 2 )
        ixd = ixd + xd * force
        iyd = iyd + yd * force
        ##console.log '_avoid',i,j,'diff=',xd,yd,'distance,force =',distance,force,'ixd,iyd=',ixd,iyd 
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
    @_distances()
    vpairs = [
        [@v,                    @inertia], 
        [@_avoid(),             @avoid], 
        [@_center(),            @center], 
        [@_align(),             @align], 
        [zeros,                 @goalseek],
        [@random_velocities(1), @jitter], 
    ]
    #console.log vpairs
    for id in [0..(@boids-1)]
      xi = id * 2
      yi = xi + 1
      weight = x = y = 0
      for pair in vpairs
        ar= pair[0]
        w = pair[1]
        weight = weight + w
        x = x + ar[xi] * w
        y = y + ar[yi] * w
      xw = x / weight
      yw = y / weight
      len = Math.sqrt( x * x + y * y )
      xnew = ( xw / len  ) * @vscale
      ynew = ( yw / len  ) * @vscale
      #console.log( 'vupdate', id, 'x,y=', @v[xi], @v[yi], 'rawnew=', x, y, 'wnew=',xw, yw, 'scale, len=', @vscale, len, '[xy]new=', xnew, ynew )
      @v[xi] = xnew
      @v[yi] = ynew
    this
  _update: ->
    @_update_velocities()
    for i in [0..(@boids * 2 -1)]
      @p[i] = @_adjust(@p[i], @v[i], (if (i % 2 == 0) then @width else @height ) )
    this
  frame: ->
    return if @updating == 1 || @running == 0
    if @maxloops > 0
      return if @loopnum++  > @maxloops
    @updating = 1
    this._update().redraw()
    @updating = 0
  start: (loops = -1 ) ->
    @maxloops = loops
    unless @running > 0
      @running = 1
      f = => @frame()
      setInterval( f, 30)
    this
  stop: ->
    @running = 0
