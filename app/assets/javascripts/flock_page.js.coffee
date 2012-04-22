@make_flock = (h = {}) ->
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

  h['avoid']    =   Number(h['avoid'] )
  h['align']    =   Number(h['align'] )
  h['center']   =   Number(h['center'] )
  h['jitter']   =   Number(h['jitter'] )
  h['goalseek'] =   Number(h['goalseek'])

  f = new Flock( h['name'], h['avoid'], h['align'], h['center'], h['jitter'], h['goalseek'], h['boids'], h['boidsize'], h['width'], h['height'] )
  return f
