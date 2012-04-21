@draw_flock = (h = {}) ->
  h['name']      ||= "MyFlock"
  h['avoid']     ||= 1
  h['align']     ||= 1
  h['center']    ||= 1
  h['jitter']    ||= 1
  h['goalseek']  ||= 1
  h['boids']     ||= 10
  h['boidsize']  ||= 30
  h['width']     ||= 500
  h['height']    ||= 500
  f = new Flock( h['name'], h['avoid'], h['align'], h['center'], h['jitter'], h['goalseek'], h['boids'], h['boidsize'], h['width'], h['height'] )
  return f


