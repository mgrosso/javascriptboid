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
    flock = make_flock( h)
    flock.view = FlockMockViewer
    flock.initialize()
    flock.add_bird 400, 400, 0, 0
    flock.add_bird 500, 500, 0, 0

  two_birds_one_frame = ( h = {} ) ->
    flock = make_test_flock h
    flock.step()
 
  it "can be constructed", ->
    expect(make_flock()).toBeDefined()
  it "moves around", ->
    flock = two_birds_one_frame(boids: 2)
    expect(flock.bird[0].frame[0].position()).toNotEqual(flock.bird[0].frame[1].position())
