#TO DO

class Vertex
	
	attr_accessor :synonyms
	attr_accessor :neighbors
	
	def initialize(synonyms, neighbors = Array.new)
		@synonyms = synonyms
		@neighbors = neighbors
	end
end

class WordNet
    
    attr_accessor :vertices
    attr_accessor :synIds
    
    def initialize(synsets, hypernyms)
    	@vertices = Hash.new
        @synIds = Hash.new
    	File.foreach(synsets) do |line|
			arr = line.split(",")
			id = arr[0].to_i
			syns = arr[1]
            synTemp = syns.split(" ")
            synTemp.each do |val|
                if !(synIds.include? val) then
                    synIds[val] = Array.new
                end
                if !(synIds[val].include? id) then
                    synIds[val].push(id)
                end
            end
			vertices[id] = Vertex.new(syns)
		end
		
		File.foreach(hypernyms) do |line|
			arr = line.split(",")
			source = arr[0].to_i
			arr.shift
			arr.each do |a|
				vertices[source].neighbors.push(a.to_i)
			end
		end
    end
    
    def isnoun(v)
    	x = 0
    	v.each do |w|
    		vertices.each_value do |y|
    			if /#{w}/ =~ y.synonyms then
    				x += 1
    			end
    		end
    	end
    	if x >= v.length then
    		return true
    	else
    		return false
    	end
    end
    
    def nouns
    	x = 0
    	vertices.each_value do |v|
    		x += v.synonyms.split(" ").length
    	end
    	return x
    end
    
    def edges
    	x = 0
    	vertices.each_value do |v|
    		x += v.neighbors.length
    	end
    	return x
    end
    
    def process(x, visited, currLength)
    	if vertices.include? x then
    		if visited.include? x then
    			if visited[x] > currLength then
    				visited[x] = currLength
    			end
    		else
    			visited[x] = currLength
    			vertices[x].neighbors.each do |n|
					process(n, visited, (currLength+1))
				end
    		end
    	end
    end
    
    def length(x, y)
    	
    	shortestPath = 1000000000000000
    	x.each do |m|
    		y.each do |n|
    			
    			currPath = 1000000000000000
    			hash1 = Hash.new
    			hash2 = Hash.new
    			process(m, hash1, 0)
    			process(n, hash2, 0)

    			hash2.each do |k, v|
    				if hash1.include? k then
    					if (hash1[k] + hash2[k]) < currPath then
    						currPath = (hash1[k] + hash2[k])
    					end
    				end
    			end
    			if currPath < shortestPath then
    				shortestPath = currPath
    			end

                hash1.each do |k, v|
                    if hash2.include? k then
                        if (hash1[k] + hash2[k]) < currPath then
                            currPath = (hash1[k] + hash2[k])
                        end
                    end
                end
                if currPath < shortestPath then
                    shortestPath = currPath
                end
                
    		end
    	end
    	
    	if shortestPath == 1000000000000000 then
    		return -1
    	else
    		return shortestPath
    	end
    end
    
    def ancestor(x, y)
    
    	shortestPath = 1000000000000000
    	closestAncestor = -1
    	x.each do |m|
    		y.each do |n|
    			
    			currPath = 1000000000000000
    			currAncestor = -1
    			hash1 = Hash.new
    			hash2 = Hash.new
    			process(m, hash1, 0)
    			process(n, hash2, 0)
    			

    			hash2.each do |k, v|
    				if hash1.include? k then
    					if (hash1[k] + hash2[k]) < currPath then
    						currPath = hash1[k] + hash2[k]
    						currAncestor = k
    					end
    				end
    			end
    			if currPath < shortestPath then
    				shortestPath = currPath
    				closestAncestor = currAncestor
    			end
    		end
    	end
    	
    	if shortestPath == 1000000000000000 then
    		return -1
    	else
    		return closestAncestor
    	end
    end
    
    def root(x, y)

        if !synIds.include? x then
            return [""]
        elsif !synIds.include? y then
            return [""]
        end
        closestSyns = []
    	
    	shortestPath = 1000000000000000
    	synIds[x].each do |m|
    		synIds[y].each do |n|
    			
    			currPath = 1000000000000000
    			currSyns = []
    			hash1 = Hash.new
    			hash2 = Hash.new
    			process(m, hash1, 0)
    			process(n, hash2, 0)
    			
    			hash2.each do |k, v|
    				if hash1.include? k then
    					if (hash1[k] + hash2[k]) == currPath then
    						currSyns += vertices[k].synonyms.split(" ")
    					elsif (hash1[k] + hash2[k]) < currPath then
                            currPath = hash1[k] + hash2[k] 
                            currSyns = vertices[k].synonyms.split(" ")
                        end
    				end
    			end
    			if currPath < shortestPath then
    				shortestPath = currPath
    				closestSyns = currSyns
    			elsif currPath == shortestPath then
                    closestSyns += currSyns
                end
    		end
    	end

    	return closestSyns.sort
    end
    
    def outcastHelper(x, y)
    	
        shortestPath = 1000000000000000
    	synIds[x].each do |m|
    		synIds[y].each do |n|
    			
    			currPath = 1000000000000000
    			hash1 = Hash.new(1000)
    			hash2 = Hash.new(1000)
    			process(m, hash1, 0)
    			process(n, hash2, 0)

    			
    			hash2.each do |k, v|
    				if hash1.include? k then
    					if (hash1[k] + hash2[k]) < currPath then
    						currPath = (hash1[k] + hash2[k])
    					end
    				end
    			end
    			if currPath < shortestPath then
    				shortestPath = currPath
    			end

                hash1.each do |k, v|
                    if hash2.include? k then
                        if (hash1[k] + hash2[k]) < currPath then
                            currPath = (hash1[k] + hash2[k])
                        end
                    end
                end
                if currPath < shortestPath then
                    shortestPath = currPath
                end
    		end
    	end
    	return shortestPath
    end
    
    def outcast(x)
    	
    	dts = {}
    	
    	x.each do |m|
    		list2 = x.uniq
            di = 0

    		list2.each do |n|
    			di += outcastHelper(m,n)**2
    		end
    		dts[m] = di
    	end

        maxVal = -1
        str = ""
        
        dts.each do |k, v| 
            if v > maxVal then
                maxVal = v
                count = 0
                x.each do |thing|
                    if thing == k then
                        count += 1
                    end
                end
                str = "#{k} "*count
                str.strip!
            elsif v == maxVal then
                count = 0
                x.each do |thing|
                    if thing == k then
                        count += 1
                    end
                end
                str += " " + "#{k} "*count
                str.strip!
            end
        end

        sample = str.split(" ")
        sample.sort!
        str2 = ""
        sample.each do |thing2|
            if str2 == "" then
                str2 = thing2
            else
                str2 += " " + thing2
            end
        end
        return str2.strip
    	
    end
end

if ARGV.length < 3 || ARGV.length >5
  fail "usage: wordnet.rb <synsets file> <hypersets file> <command> <filename>"
end

synsets_file = ARGV[0]
hypernyms_file = ARGV[1]
command = ARGV[2]
fileName = ARGV[3]

commands_with_0_input = %w(edges nouns)
commands_with_1_input = %w(outcast isnoun)
commands_with_2_input = %w(length ancestor)



case command
when "root"
	file = File.open(fileName)
	v = file.gets.strip
	w = file.gets.strip
	file.close
    wordnet = WordNet.new(synsets_file, hypernyms_file) 
    r =  wordnet.send(command,v,w)  
    r.each{|w| print "#{w} "}
    
when *commands_with_2_input 
	file = File.open(fileName)
	v = file.gets.split(/\s/).map(&:to_i)
	w = file.gets.split(/\s/).map(&:to_i)
	file.close
    wordnet = WordNet.new(synsets_file, hypernyms_file)
    puts wordnet.send(command,v,w)  
when *commands_with_1_input 
	file = File.open(fileName)
	nouns = file.gets.split(/\s/)
	file.close
    wordnet = WordNet.new(synsets_file, hypernyms_file)
    puts wordnet.send(command,nouns)
when *commands_with_0_input
	wordnet = WordNet.new(synsets_file, hypernyms_file)
	puts wordnet.send(command)
else
  fail "Invalid command"
end