describe window.Flock, -> 
  it "can be constructed", ->
    expect(make_flock()).toBeDefined()
  it "moves around", ->
    flock = make_flock(boids: 2)
    expect(todo).toBeDefined()
