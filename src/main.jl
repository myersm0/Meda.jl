
using NamedArrays

function arg_parse_wrapper(args)
	s = ArgParseSettings()
	@add_arg_table! s begin
		"program"
			help = "Must be `find` or `create`"
			arg_type = Symbol
			required = true
		"--base_dir"
			help = "The root directory where contents are stored"
			arg_type = String
			default = "$(ENV["HOME"])/content/"
		"--keyfile"
			help = "Within each directory, what the metadata file is called"
			arg_type = String
			default = "meta.json"
		"--purpose"
			help = "If creating a directory, describe your purpose"
			arg_type = String
		"--query"
			help = "If searching for a directory, specify a natural language query"
			arg_type = String
		"--maxchar"
			help = "The maximum number of characters to print per line in results"
			arg_type = Int
			default = 64
		"--k"
			help = "The number of distinct topics to model"
			arg_type = Int
			default = 5
		"--n_per_group"
			help = "Show a maximum of this many results per topic"
			arg_type = Int
			default = 5
		"--top_n"
			help = "Highlight this many top-ranking results with bold font"
			arg_type = Int
			default = 5
	end
	return parse_args(s; as_symbols = true)
end

function julia_main()::Cint
	args = arg_parse_wrapper(ARGS)

	if args[:program] == :find
		haskey(args, :query) || error(KeyError)
		query = args[:query]
		contents = readdir(args[:base_dir])
		model = load_sbert()
		collection = NamedArray(
			[
				Content("$(args[:base_dir])/$x/$(args[:keyfile])"; model = model) 
				for x in contents
			],
			(contents)
		)
		ks, scores, matches, soln = find_entries(
			query; collection = collection, model = model, k = args[:k]
		)
		print_results(soln; collection = collection, ks = ks, matches = matches)
	elseif args[:program] == :create
		haskey(args, :purpose) || error(KeyError)
		create(; purpose = args[:purpose], base_dir = args[:base_dir])
	end

	return 0
end



