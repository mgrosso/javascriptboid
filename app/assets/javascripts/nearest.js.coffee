class @NNearest
  constructor: (@max_neighbors, @max_distance) ->
    @neighbors = []
  add: (distance, from, to) ->
    return if ( from == to ) or ( distance > @max_distance )
    sorted = @neighbors[from] ?= []
    sorted.push( [distance, to ])
    if(@max_neighbors > 0 )
      sorted.sort()
      sorted.pop() if sorted.length > @max_neighbors
    @
  get: (from) -> @neighbors[from]
  all: -> @neighbors

