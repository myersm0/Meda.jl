
function randhex(n::Int = 6)
	@chain "0123456789abcdef" begin
		split(_, "")
		sample(_, n; replace = true)
		join
	end
end

function create(; purpose::String, base_dir::String, date::Union{String, Nothing} = nothing)
	key = randhex(6)
	dest = "$base_dir/$key/"
	!isdir(dest) || error("Target directory $key already exists")
	run(`mkdir -p $dest`)

	meta = Dict(
		:key => key,
		:purpose => purpose,
		:author => ENV["USER"],
		:created => isnothing(date) ? string(Dates.today()) : date
	)

	outname = "$dest/meta.json"
	open(outname, "w") do fid
		JSON.print(fid, meta, 4) # pretty print json with tabwidth 4
	end

	println("Successfully created a new content directory at $dest")
	return key
end


