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
  #######################################################################
  $("#start").click => f.start()
  $("#stop").click => f.stop()
  $("#toggle_halo").click => f.toggle_halo()
  $("#initialize").click => f.initialize()
  $("#step").click => f.step()
  $("#redraw").click => f.redraw()
  $("#console_debug").click => f.console_debug()
  $("#show_numbers").click => f.toggle_numbers()
  #######################################################################
  vcomp = (name) ->
    $('#' + name).click => 
        f.toggle_component( name )
        $('#' + name).css({color: f.component_color( name )})
  for component in ['avoid', 'align', 'center', 'jitter', 'goalseek' ]
      vcomp component
  return f
