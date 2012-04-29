describe window.Flock, -> 
  make_test_flock = ( h = {} ) -> 
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
    flock = make_flock h
    flock.view = FlockMockViewer
    flock.initialize()
    flock.add_bird 400, 400, 0, 0
    flock.add_bird 500, 500, 0, 0
    flock

  two_birds_one_frame = ( h = {} ) ->
    window.flock = make_test_flock h
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
