#  Traveling Salesman Problem, algorithm D.
#  TODO:  Refactor for cleaner, more concise and elegant code
#  Phase II of this contest includes a much bigger map, wider range of speed limits, one-way streets, and 
#  includes acceleration time.  Use A* algorithm for Phase II.   This is more of a "warm up" phase. 

class Rules
  # Speed limit of each X-axis line:	
  SPEED_LIMITX = [100, 80, 90, 65, 75, 55, 40, 30, 25, 30, 45, 60, 55, 80, 95]
  # Speed limit of each Y-axis line:
  SPEED_LIMITY = [95, 85, 70, 76, 71, 45, 30, 25, 20, 20, 35, 50, 55, 70, 60]
  # Each location is given below in the format of label, X, Y:
  LOCATIONS = {
  	'A' => [3, 9],
  	'B' => [4, 13],
  	'C' => [6, 6],
  	'D' => [9, 0],
  	'E' => [12, 12],
  	'F' => [10, 10],
  	'G' => [11, 14],
  	'H' => [13, 12],
  	'I' => [11, 8],
  	'J' => [1, 3],
  	'K' => [9, 2],
  	'L' => [14, 12],
  	'M' => [11, 6],
  	'N' => [7, 7],
  	'O' => [8, 4],
  	'P' => [1, 0],
  	'Q' => [5, 6],
  	'R' => [6, 7],
  	'S' => [4, 2],
  	'T' => [9, 5]
  }
end

# Convert seconds to hh:mm:ss
def secondstoHMS(sec)
  seconds = sec % 60
  minutes = (sec / 60) % 60
  hours = sec / 3600

  format("%02d:%02d:%02d", hours, minutes, seconds) #=> "01:00:00"
end

#  Display the grid of city locations
def printGrid
  grid = []
  15.times do
    grid.push '. . . . . . . . . . . . . . . '
  end

  Rules::LOCATIONS.each { |key, value|   # get location labels with value as array of X, Y
    grid[value[1]][value[0]*2] = key     # have to reverse how we access grid, so Y, X.  Must double X due to spaces
  }

  (0..14).each_with_index do |i|
  	puts grid[14-i]     # Need to show lines in reverse order 
  end
end

# Class to track info about a city location
class Location
  attr_accessor :x, :y, :name, :visited
  def initialize(label, x, y)
  	@x = x
  	@y = y
  	@name = label
    @visited = false
  end
end

# Algorithm D: Take any point at random.  Choose the 8 closest points, then find the FASTEST next destination. 
# Same algorithm as C, but expands and explores a lot more. 
# Continue from there with the next 8 closest.  Continue until all visited.

class AlgorithmD
  def initialize(locations)
    @locations = locations
  end


  # Run the algorithm, given a particular start location (as an index into location array)
  def run
    start = rand(20)
    puts "     Starting at: #{@locations[start].name}"
    tripDesc = ""             # human-readable List of moves for current trip segment
    @locations[start].visited = true
    visited = 1
    totalTime = 0
    while visited < 20
      group = group_nearest(start)
      best_time = 9999999999

      for i in 0..3
        result = getBestPath(start, group[i]) if group[i]
        if result[0] < best_time
          best_time = result[0]
          best_path = result[1]
          best_dest = group[i]
        end
      end
      tripDesc << best_path
      totalTime += best_time
      @locations[best_dest].visited = true
      start = best_dest
      visited += 1
    end

    puts "***********  Total Trip Time = #{secondstoHMS(totalTime)} **************"
    confirm = "Complete.\n"
    for i in 0..19
      confirm = "Error, not all locations visited!!\n" if !@locations[i].visited
    end
    tripDesc << confirm
    return [totalTime, tripDesc]

  end


  # Get the 4 closest non-visited points to a given location, returned as an array of location numbers
  def group_nearest(location_num)
    nearest_dist = 99
    distances = [[]]   # array of arrays

    for i in 0..19
      # Go through all locations, create array of all point distances from this point
      next if i == location_num || @locations[i].visited
      dx = @locations[i].x - @locations[location_num].x   # distance between two locations, X
      dy = @locations[i].y - @locations[location_num].y   # distance Y

      dist = Math.sqrt(dx*dx + dy*dy)
      distances << [dist, i]
    end

    distances.sort!
    result = []
    for i in 1..4
      result << distances[i][1] if distances[i]
    end

    return result
  end

  # Search for best path between two locations
  def getBestPath(location1, location2)
    best = []  # array to hold time and path description 
    bestTime = 9999999999
    descript = ""

    for i in 0..500    # try 500 paths
      result = getPath(location1, location2)   # Calculate a semi-random path between two points
      if result[0] < bestTime
        # Found a better path
        bestTime = result[0]
        best = result
      end
    end
    descript << "BEST RESULT:\n"
    descript << best[1] + "\n"
    descript << "  Total time: #{best[0]} seconds = #{secondstoHMS(best[0])}\n"
    return [best[0], descript]
  end


  # calulate a random path going from location1 to location2
  def getPath(location1, location2)
    accTime = 0.0     # accumulated driving time in seconds
    fullPath = ""     # track this path

    # counters for distances traveled
    needX = (@locations[location2].x - @locations[location1].x)
    needY = (@locations[location2].y - @locations[location1].y)
    currentX = @locations[location1].x
    currentY = @locations[location1].y

    absX = needX.abs  # Absolute distance to be traveled in X direction 
    absY = needY.abs  # Absolute distance to be traveled Y
    if (absX > 2 || absY > 2)     # allow for a "looser" travel algorithm for longer distances
      loose = true                #   This is meant to meander a bit outside of a direct path to see
    else                          #   if any advantage can be gained
      loose = false
    end
    
    if absX == 0    # sign is 0 is there is no travel needed in X direction
      signX = 0
    else     # Otherwise, sign will be +1 or -1, depending on direction we need to go 
      signX = needX / absX   # direction we are going X
    end
    if absY == 0    # same treatment for Y
      signY = 0
    else
      signY = needY / absY   # direction we are going Y
    end

    fullPath << "Moving from location #{@locations[location1].name} to #{@locations[location2].name}:\n"

    counter = 1
    while (needX != 0 || needY != 0) do
      # make a move
      # if running the more "loose" algorithm, then possibly start with one, two, or three counter-intuitive moves
      if loose && counter == 1 && rand(3) == 1
        moves = rand(3) + 1  # do 1, 2, or 3 counter-intuitive moves
        case rand(2)    # what direction?
        when 0         # make an "exploratory" move in the X direction
          fullPath << "   Exploring X direction #{moves} moves, "
          needX += signX * moves   # make the move if still need progress in this direction
          currentX -= signX * moves
          speed = Rules::SPEED_LIMITX[currentY]   # get the speed limit on this "street"
          fullPath << "speed limit is #{speed}, "
          speed = speed.to_f / 3600.0             # convert speed from mph to miles per second
          time = moves / speed                      # time required is dist traveled (1 mile) / speed
          fullPath << "time required #{time.round(2)}\n"
          accTime += time                         # Add travel time this move, in seconds
          counter += 1
          next

        when 1      # make an "exploratory" move in the Y direction
          fullPath << "   Exploring Y direction #{moves} moves, "
          needY += signY * moves   # make the move if still need progress in this direction
          currentY -= signY * moves
          speed = Rules::SPEED_LIMITY[currentX]    # get the speed limit on this "street"
          fullPath << "speed limit is #{speed}, "
          speed = speed.to_f / 3600.0              # convert speed from mph to miles per second
          time = moves / speed                       # time is dist traveled (1 mile) / speed
          fullPath << "time required #{time.round(2)}\n" 
          accTime += time                          # Add travel time this move, in seconds
          counter += 1
          next
        end
      end

      case rand(2)   # choose a move (one mile) at random, either in X direction or Y
      when 0         # moving in the X direction
        next if needX == 0   # try another move if we don't need to move in X direction
        fullPath << "   Moving X direction, "
        needX -= signX   # make the move if still need progress in this direction
        currentX += signX
        speed = Rules::SPEED_LIMITX[currentY]   # get the speed limit on this "street"
        fullPath << "speed limit is #{speed}, "
        speed = speed.to_f / 3600.0             # convert speed from mph to miles per second
        time = 1.0 / speed                      # time required is dist traveled (1 mile) / speed
        fullPath << "time required #{time.round(2)}\n"
        accTime += time                         # Add travel time this move, in seconds
      when 1      # moving in the Y direction

        next if needY == 0    # try another move if we don't need to move in Y direction
        fullPath << "   Moving Y direction, "
        needY -= signY    # make the move if still need progress in this direction
        currentY += signY
        speed = Rules::SPEED_LIMITY[currentX]    # get the speed limit on this "street"
        fullPath << "speed limit is #{speed}, "
        speed = speed.to_f / 3600.0              # convert speed from mph to miles per second
        time = 1.0 / speed                       # time is dist traveled (1 mile) / speed
        fullPath << "time required #{time.round(2)}\n" 
        accTime += time                          # Add travel time this move, in seconds        
      end
      counter += 1
    end   

    #  Confirm that we are at the end point, otherwise the code is jacked up!! 
    puts "   Travel error!" if currentX != @locations[location2].x || currentY != @locations[location2].y
    accTime = accTime.round(2)     # reduce precision to hundreths of a second
    return [accTime, fullPath]
  end

end


#  Start of main execution
locations = []    # Keep an array of location objects
Rules::LOCATIONS.each { |key, value| 
  # Create all location objects
  locations << Location.new(key, value[0], value[1])
}

alD = AlgorithmD.new(locations)     # initiate class for algorithm A
bestTime = 99999999999999
bestDesc = ""
puts "*****************************************************"
puts "Running algorithm D"


for i in 0..100                 # run Algorithm A 100 times
  result = alD.run
  totalTime = result[0]
  puts "Iteration #{i+1}"
  if totalTime < bestTime
    #  New best time found 
    bestTime = totalTime
    bestDesc = result[1]
  end

  # reset visited and start next iteration
  for j in 0..19
    locations[j].visited = false
  end
end

puts "********************  RESULTS ****************************"
puts "***********  Total Trip Time BEST = #{secondstoHMS(bestTime)} **************"
puts "***********  Trip Path:"
puts bestDesc
puts "***********  Total Trip Time BEST = #{secondstoHMS(bestTime)} **************"

