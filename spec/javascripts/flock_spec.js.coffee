describe window.Flock, -> 
  make_args = (h = {}) ->
    h['inertia']   ||= 0
    h['avoid']     ||= 0
    h['align']     ||= 0
    h['center']    ||= 0
    h['jitter']    ||= 0
    h['goalseek']  ||= 0
    h['boids']     ||= 0
    h['boidsize']  ||= 10
    h['maxv']      ||= 10
    h['width']     ||= 1000
    h['height']    ||= 1000
    h['store_history']    ||= true
    h

  make_test_flock = ( h = {} ) -> 
    h = make_args h
    flock = new Flock( h['name'], h['avoid'], h['align'], h['center'], h['jitter'], h['goalseek'], h['boids'], h['boidsize'], h['width'], h['height'], h['store_history'] )
    flock.view = FlockMockViewer
    flock.initialize()
    flock.add_bird 400, 400, 0, 0
    flock.add_bird 450, 450, 0, 0
    flock

  two_birds_one_frame = ( h = {} ) ->
    window.flock = make_test_flock h
    #window.flock.console_debug()
    window.flock.start(1)
 
  it "can be constructed", ->
    expect(make_flock()).toBeDefined()

  it "has only as many birds as we add", ->
    flock = two_birds_one_frame()
    expect(flock.boids).toEqual(flock.num_birds())
    expect(flock.boids).toEqual(2)

  it "has two frames after one update", ->
    flock = two_birds_one_frame()
    expect(flock.loopnum).toEqual(1)
    expect(flock.history.length).toEqual(2)

  it "has three frames after two updates", ->
    flock = make_test_flock()
    flock.start(2)
    expect(flock.loopnum).toEqual(2)
    expect(flock.history.length).toEqual(3)

  it "does not move without a reason", ->
    flock = two_birds_one_frame()
    expect(flock.get_frame_bird_pixel(0,0)).
        toEqual(flock.get_frame_bird_pixel(1,0))

  it "does not center on non-neighbor", ->
    window.flock = flock = make_test_flock {center: 1}
    #flock.console_debug()
    flock.set_bird 1, 500, 500, 0, 0
    flock.start(1)
    expect(flock.get_frame_bird_pixel(0,0)).
        toEqual(flock.get_frame_bird_pixel(1,0))

  it "does not align on non-neighbor", ->
    window.flock = flock = make_test_flock {align: 1}
    #flock.console_debug()
    flock.set_bird 1, 500, 500, 0, 0
    flock.start(1)
    expect(flock.get_frame_bird_pixel(0,0)).
        toEqual(flock.get_frame_bird_pixel(1,0))
  

  it "does center on neighbor", ->
    window.flock = flock = make_test_flock {center: 1}
    #flock.console_debug()
    flock.set_bird 1, 450, 450, 0, 0
    flock.start(1)
    expect(flock.get_frame_bird_pixel(0,0)).
        not.toEqual(flock.get_frame_bird_pixel(1,0))

  it "does align on neighbor", ->
    window.flock = f = make_test_flock {align: 1}
    #f.console_debug()
    f.set_bird 1, 450, 450, -10, -10
    f.maxa = f.maxv * 2 + 1
    f.start(1)
    expect(f.get_frame_bird_pixel(0,0)).
        not.toEqual(f.get_frame_bird_pixel(1,0))
    expect(f.get_frame_bird_vx(1,0)).toBeLessThan(0)
    expect(f.get_frame_bird_vy(1,0)).toBeLessThan(0)
    expect(f.get_frame_bird_vx(1,1)).toBeGreaterThan(-10)
    expect(f.get_frame_bird_vy(1,1)).toBeGreaterThan(-10)
  
  it "knows which are birds within max_distance of which", ->
    window.flock = flock = make_test_flock() 
    #flock.console_debug()
    flock.set_bird 1, 450, 450, 0, 0
    flock.add_bird 650, 650, 0, 0
    flock.start(1)
    nbrs0 = _(flock.neighbors.get(0)).map (x) -> x[1]
    nbrs1 = _(flock.neighbors.get(1)).map (x) -> x[1]
    nbrs2 = _(flock.neighbors.get(2)).map (x) -> x[1]
    expect(nbrs0).toEqual([1])
    expect(nbrs1).toEqual([0])
    expect(nbrs2).toEqual([])

  it "finds neighbors over the wrap around edge", ->
    h = { center: 1, width: 410, height: 1000 }
    window.flock = f = make_test_flock h
    #diamond shape
    #f.console_debug()
    f.set_bird 0, 400, 450, 0, 0
    f.set_bird 1, 40,  400, 0, 0
    f.add_bird    90,  450, 0, 0
    f.add_bird    40,  500, 0, 0
    flock.start(1)
    nbrs0 = _(flock.neighbors.get(0)).map (x) -> x[1]
    nbrs1 = _(flock.neighbors.get(1)).map (x) -> x[1]
    nbrs2 = _(flock.neighbors.get(2)).map (x) -> x[1]
    nbrs3 = _(flock.neighbors.get(3)).map (x) -> x[1]
    expect(nbrs0).toEqual([1,2,3])
    expect(nbrs1).toEqual([0,2,3])
    expect(nbrs2).toEqual([0,1,3])
    expect(nbrs3).toEqual([0,1,2])
  
  it "centers to the center", ->
    window.flock = f = make_test_flock {center: 1}
    #diamond shape
    #f.console_debug()
    f.set_bird 0, 400, 450, 0, 0
    f.set_bird 1, 450, 400, 0, 0
    f.add_bird    500, 450, 0, 0
    f.add_bird    450, 500, 0, 0
    f.maxa = f.maxv * 2 + 1
    f.start(1)
    expect(f.get_frame_bird_px(1,0)).toBeGreaterThan(400)
    expect(f.get_frame_bird_vx(1,0)).toBeGreaterThan(0)
    expect(f.get_frame_bird_py(1,0)).toEqual(450)
    expect(f.get_frame_bird_vy(1,0)).toEqual(0)
    expect(f.get_frame_bird_px(1,1)).toEqual(450)
    expect(f.get_frame_bird_vx(1,1)).toEqual(0)
    expect(f.get_frame_bird_py(1,1)).toBeGreaterThan(400)
    expect(f.get_frame_bird_vy(1,1)).toBeGreaterThan(0)
    expect(f.get_frame_bird_px(1,2)).toBeLessThan(500)
    expect(f.get_frame_bird_vx(1,2)).toBeLessThan(0)
    expect(f.get_frame_bird_py(1,2)).toEqual(450)
    expect(f.get_frame_bird_vy(1,2)).toEqual(0)
    expect(f.get_frame_bird_px(1,3)).toEqual(450)
    expect(f.get_frame_bird_vx(1,3)).toEqual(0)
    expect(f.get_frame_bird_py(1,3)).toBeLessThan(500)
    expect(f.get_frame_bird_vy(1,3)).toBeLessThan(0)
  
  it "figures torus distances correctly", ->
    f = make_test_flock()
    f.console_debug()
    console.log "start: figure torus correctly"
    expect(f._pdelta(90,10,100)).toEqual(20)
    expect(f._pdelta(11,90,100)).toEqual(-21)
    expect(f._pdelta(400,400,410)).toEqual(0)
    expect(f._pdelta(40,40,410)).toEqual(0)
    expect(f._pdelta(400,40,410)).toEqual(50)
    expect(f._pdelta(400,90,410)).toEqual(100)
    expect(f._pdelta(40,400,410)).toEqual(-50)

    expect(f._pdelta(40,91,410)).toEqual(51)
    expect(f._pdelta(91,40,410)).toEqual(-51)

    expect(f._pdelta(90,400,410)).toEqual(-100)
    console.log "done: figure torus correctly"

  it "centers to the center over an edge", ->
    h = { center: 1, width: 410, height: 1000 }
    window.flock = f = make_test_flock h
    #diamond shape
    f.console_debug()
    f.set_bird 0, 400, 450, 0, 0
    f.set_bird 1, 40,  400, 0, 0
    f.add_bird    90,  450, 0, 0
    f.add_bird    40,  500, 0, 0
    f.maxa = 500
    f.start(1)
    expect(f.get_frame_bird_px(1,0)).toBeGreaterThan(400)
    expect(f.get_frame_bird_vx(1,0)).toBeGreaterThan(0)
    expect(f.get_frame_bird_py(1,0)).toEqual(450)
    expect(f.get_frame_bird_vy(1,0)).toEqual(0)
    #expect(f.get_frame_bird_px(1,1)).toEqual(40)
    #expect(f.get_frame_bird_vx(1,1)).toEqual(0)
    #expect(f.get_frame_bird_py(1,1)).toBeGreaterThan(400)
    #expect(f.get_frame_bird_vy(1,1)).toBeGreaterThan(0)
    #expect(f.get_frame_bird_px(1,2)).toBeLessThan(500)
    #expect(f.get_frame_bird_vx(1,2)).toBeLessThan(0)
    #expect(f.get_frame_bird_py(1,2)).toEqual(450)
    #expect(f.get_frame_bird_vy(1,2)).toEqual(0)
    #expect(f.get_frame_bird_px(1,3)).toEqual(450)
    #expect(f.get_frame_bird_vx(1,3)).toEqual(0)
    #expect(f.get_frame_bird_py(1,3)).toBeLessThan(500)
    #expect(f.get_frame_bird_vy(1,3)).toBeLessThan(0)
