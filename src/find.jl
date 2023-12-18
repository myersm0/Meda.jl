
function find_entries(query::String;
		collection::NamedVector{Content}, model::Py, k::Int = 10, top_n::Int = 5
	)
	soln = make_clusters(collection.array; k = k)
	clust_sizes = [sum(soln .== c) for c in 1:k]
	scores, ks = rank_by_relevance(query, collection; model = model)
	matches = ks[1:top_n]
	return (ks = ks, scores = scores, matches = matches, soln = soln)
end

function print_results(
		soln::Vector{Int}; 
		collection::NamedVector{Content}, ks::Vector{Int}, matches::Vector{Int},
		n_per_group::Int = 5, maxchar::Int = 64
	)
	clusters = unique(soln)
	for c in clusters
		inds = findall(soln .== c)
		rank_order = [findfirst(ks .== i) for i in inds]
		inds = inds[sortperm(rank_order)]
		for (i, ind) in enumerate(inds)
			if i > n_per_group
				println("  … (omitting $(length(inds) - i + 1) results)")
				break
			end
			meta = collection[ind].meta
			purpose = meta["purpose"]
			if length(purpose) > maxchar
				purpose = "$(purpose[1:(maxchar - 2)]) …"
			end
			print("▪ ")
			bold = ind in matches
			underline = bold
			printstyled(meta["key"]; bold = bold, underline = underline)
			println(": $purpose")
		end
		println()
	end
end



