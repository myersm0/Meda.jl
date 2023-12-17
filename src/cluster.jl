
function make_clusters(collection::Vector{Content}; k::Int = 5)
	n = length(collection)
	d = length(collection[1].embedding)
	embeddings = zeros(Float32, n, d)
	for (i, elem) in enumerate(collection)
		embeddings[i, :] .= elem.embedding
	end
	pca = fit(PCA, embeddings'; maxoutdim = 5)
	reduced_embeddings = transform(pca, embeddings')
	distances = pairwise(CosineDist(), reduced_embeddings, dims = 2)
	hc = hclust(distances, linkage = :average)
	return cutree(hc, k = k)
end



