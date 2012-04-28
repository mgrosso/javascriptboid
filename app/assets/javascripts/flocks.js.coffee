class @Flock
  constructor: (@name, @avoid, @align, @center, @jitter, @goalseek, @boids, @boidsize, @width, @height ) ->
    
  _random_velocity: (scale) ->
    ((Math.random() + Math.random() + Math.random()) / 3 ) * scale - scale / 2
  _random_velocities: (scale) ->
    (@_random_velocity(scale)  for i in [1.. @boids])
   
  component_color: (component) -> @arrow_colors[component]
  
  toggle_component: (component) ->
    if @arrow_show[component]
        delete @arrow_show[component]
    else
        @arrow_show[component] = @arrow_colors[component]
  initialize: ->
    ###################################################
    # things that belong someplace else
    ###################################################
    $("#cv").bind  'click', (e) => @click( e)
    @arrow_colors = {
      inertia: "#000000",
      avoid:   "#ff0000",
      center:  "#00ff00",
      align:   "#0000ff",
      goalseek:"#aaaa00",
      jitter:  "#00aaaa",
      }
    ###################################################
    # hardcoded params that need to be paramaterized
    ###################################################
    @inertia = 0.9
    @maxv = @boidsize 
    @neighbor_cutoff = @boidsize * 10
    @avoid_cutoff = @boidsize * 2
    @max_neighbors = 4
    @radius = @boidsize / 2
    ###################################################
    # state that changes
    ###################################################
    @arrow_show = { }
    @show_numbers = 0
    @debug = 0
    @running = 0
    @loopnum = 0
    @px = []
    @py = []
    @vx = []
    @vy = []
    @add_random_bird() for i in [1.. @boids]
    @view ||= FlockCanvas
    @r = new @view( @width, @height )
    @r.initialize()
    this
  add_random_bird: ->
    x = Math.random() * @width
    y = Math.random() * @height
    vx = @_random_velocity( @maxv )
    vy = @_random_velocity( @maxv )
    @add_bird(x,y,vx,vy)
  add_bird: (x,y,vx,vy) ->
    @px.push x
    @py.push y
    @vx.push vx
    @vy.push vy
    @px.length
    this
  _x: (id) -> @px[id]
  _y: (id) -> @py[id]
  _vx: (id) -> @vx[id]
  _vy: (id) -> @vy[id]
  _draw_bird: (id) ->
    x = @_x(id)
    y = @_y(id)
    @r.draw_bird x,y,@radius,id
    if @halo 
      @r.draw_halo x, y, @neighbor_cutoff 
      @r.draw_halo x, y, @avoid_cutoff 
    for key, color of @arrow_show
      xy2 = @arrows[key][id]
      @r.draw_line x, y, x + 10 * xy2[0], y + 10 * xy2[1], color
    if @show_numbers then @r.draw_bird_num x, y, id
    this
  draw: ->
    ( @_draw_bird i ) for i in [0..(@boids-1)]
    this
  redraw: ->
    @r.refresh()
    this.draw()
  _move: ( p, delta, max ) ->
    ret = p + delta
    if ret < 0
      ret = max - ret
    else if ret > max
      ret = ret - max
    ret
  _zeros: (len = @boids ) -> 
    (0 for i in [1..len])
  _xy_zeros: (len = @boids ) -> 
    [ @_zeros(), @_zeros() ]
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
    #a pure upper triangular matrix of distances, stored as vector
    @distances = []
    #these matrices store the [xy] component of the vector from i to j 
    #in i*boids+j.  since i_to_j is -1 * j_to_i they are skew symmetric 
    @xdeltas   = []
    @ydeltas   = []
    for i in [0..(@boids-1)]
      for j in [0..(@boids-1)] when j > i
        xd = @_pdelta( @_x(i), @_x(j), @width )
        yd = @_pdelta( @_y(i), @_y(j), @height )
        d = @distances[ i * @boids + j ] = Math.sqrt( xd * xd + yd * yd )
        @neighbors.add d, i, j
        @xdeltas[i * @boids + j] = xd
        @xdeltas[j * @boids + i] = - xd
        @ydeltas[i * @boids + j] = yd
        @ydeltas[j * @boids + i] = - yd
        if @debug then console.log 'distance:',i, j, d, xd, yd, @neighbors.get(i)
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
    ret = @_xy_zeros()
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
      ret[0][i] = nixd
      ret[1][i] = niyd
    ret
  _align: ->
    ret = @_xy_zeros()
    for i, pairs of @neighbors.all()
      x = y = weight = 0
      for pair in pairs
        w = 1 / pair[0]
        j = pair[1]
        weight = weight + w
        x = x + w * @vx[j]
        y = y + w * @vy[j]
      ret[0][i] = if weight == 0 then 0 else x / weight
      ret[1][i] = if weight == 0 then 0 else y / weight
    ret
  _center: ->
    ret = @_xy_zeros()
    for i, pairs of @neighbors.all()
      x = y = 0
      for pair in pairs
        j = pair[1]
        x = x + @_x(j)
        y = y + @_y(j)
      sz = pairs.length
      ret[0][i] = x / sz
      ret[1][i] = y / sz
    ret
  _jitter: ->
    [@_random_velocities(1), @_random_velocities(1) ]
  _update_velocities: ->
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
        [[@vx,@vy],             @inertia,   'inertia'],
        [@_avoid(),             @avoid,     'avoid'],
        [@_center(),            @center,    'center'],
        [@_align(),             @align,     'align'], 
        [@_xy_zeros(),          @goalseek,  'goalseek'],
        [@_jitter(),            @jitter,    'jitter'], 
    ]
    @vpairs = new_vpairs
    if @debug then console.log 'neighbors',@neighbors
    if @debug then console.log 'forces:',@vpairs
    for id in [0..(@boids-1)]
      len = weight = x = y = 0
      for pair in @vpairs
        @arrows[ pair[2] ][ id ] = [ 0, 0 ]
        if @debug then console.log 'update', id, pair[2], 'len,maxv=',len, @maxv
        continue if len >= @maxv
        ar= pair[0]
        w = pair[1]
        weight = weight + w
        dx = ar[0][id] * w
        dy = ar[1][id] * w
        delta_len = Math.sqrt( dx * dx + dy * dy )
        if @debug then console.log 'update', id, pair[2], 'dx,dy,w:', dx, dy, w, 'arX[id],arY[id]=', ar[0][id], ar[1][id], 'x,y=', x, y, 'len, delta_len', len, delta_len
        if delta_len + len > @maxv
          delta_len = @maxv - len
          dx = dx / delta_len
          dy = dy / delta_len
          if @debug then console.log 'update', id, pair[2], delta_len, dx, dy
        x = x + dx
        y = y + dy
        if @debug then console.log 'update', id, pair[2], 'x,y,dx,dy:', x,y, dx, dy
        @arrows[ pair[2] ][ id ] = [ dx, dy ]
      @vx[id] = x
      @vy[id] = y
      @arrows[ 'velocity' ][ id ] = [ x, y ]
    this
  _update: ->
    @_update_velocities()
    for i in [0..(@boids - 1)]
      @px[i] = @_move(@_x(i), @_vx(i), @width )
      @py[i] = @_move(@_y(i), @_vy(i), @height )
    this
  _frame: ->
    return if @updating == 1 || @running == 0
    if @maxloops > 0
      return if @loopnum++  > @maxloops
    @updating = 1
    @step()
    @updating = 0
  toggle_numbers: ->
    @show_numbers = if @show_numbers then 0 else 1
  console_debug: ->
    @debug = if @debug then 0 else 1
    this
  set_debug: (x) ->
    @debug = x
    this
  step: ->
    @_update().redraw()
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
      dx = @_pdelta( x, @_x(id), @width)
      dy = @_pdelta( y, @_y(id), @height)
      len = Math.sqrt( dx * dx + dy * dy )
      if len < shortest 
        best = id
        shortest= len
    best
  is_within: (id, x, y ) ->
    dx = @_x(id) - x
    dy = @_y(id) - y
    ( dx * dx + dy * dy ) < ( @radius * @radius )
  get_bird: (id) ->
    ret = { x: @_x(id), y: @_y(id), vx: @_vx(id), vy: @_vy(id) }
    for component, color of @arrow_colors 
      ret[component] = @arrows[component][id]
    ret
  click: (e) ->
    return unless @offset?
    x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft - Math.floor(@offset.left)
    y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop - Math.floor(@offset.top) + 1;
    near = @nearest(x,y)
    within = @is_within(near,x,y)
    console.log x, y, @offset, e, near, within, @get_bird(near)

root = exports ? this
root.Flock = Flock

