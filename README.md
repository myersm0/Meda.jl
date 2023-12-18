
# Meda

## Description
This is an experimental program that uses LLM-fueled semantic search and topic modeling in order to maintain, organize, and search a user-created, flat collection of directories with heterogeneous contents. It's deliberately _not_ production-ready; for example, every time you run this program it has to load the `sentence-BERT` model in Python, compile functions, etc, which is very inefficient for a small program like this that's designed to be run frequently from the command line. It's just intended as a proof of concept and as a working solution until something better comes along.

The semantic search aspect of this works very well, in my experience. The topic modeling part (based on a hierarchical clustering of PCA-reduced embeddings) is less successful, but good enough: in the test data I show that it fairly well recovers the original 7 topics that they were generated from (more on that below).

## Motivation
I deal with a lot of projects of an exploratory or unpredictable nature. Some of them mature into bigger or more stable projects. Those that don't, there may still be value, but it may be unclear how to organize them, what are the common threads, etc. On top of that, there are innumerable things like datasets, models, course materials, notes, etc, that I'd like to keep track of. I've increasingly found that a traditional hierarchical organization for this kind of thing is not very satisfactory, for several reasons such as:
- inflexible
- complex (it can lead to deep mazes of directories and long file paths)

My solution is to store practically everything that may be of a transient or unpredictable nature in a single directory called `content`. By "almost everything", I mean datasets, media, documents, code, etc. I make no distinction among those things, but rather leave it to metadata to capture the nature of groupings among them, in such a way that a semantic search can group the content for me dynamically according to my needs in any given use case. Also there's almost no nesting of directories within `content`; the only exception is where there's a very strong organizational convention, such as grouping some code's contents into subfolders like `assets`, `docs`, etc.

Furthermore, my approach gives each directory a _random, meaningless name_, by default a 6-character hexademical string, which we'll refer to as a `key`. There are a few reasons for this:
- unburdens you from having to choose a name for everything yourself (any name you choose will end up being the wrong one, I argue: because in the interest of brevity it can't fully capture all you need it to say, and because changing needs over time will invalidate whatever you choose anyway)
- rewards user(s) for developing a rich set of metadata and docs for each item (because the semantic search capabilities are only as good as the materials that you feed into it)

## Installation
This package works best by building it into an relocatable app via [PackageCompiler.jl](https://julialang.github.io/PackageCompiler.jl/stable/apps.html#Creating-an-app).

You may first have to do `pip install sentence_transformers` to install the required Python library. You may also need to install and build the Julia package `PythonCall` in such a way that it has access to the virtual environment (if any) in which `sentence_transformers` is accessible.

Then clone the repo or install it as a package in Julia:
```
using Pkg
Pkg.install(url = "https://github.com/myersm0/Meda.jl")
```

Then at the root directory of the project, start Julia with `julia --project` and then:
```
using PackageCompiler
create_app(".", "Meda")
```

## Usage
In this repo under `test/data/content/`, I have a collection of 70 example directories, each with a `meta.json` file having a statement of purpose (generated by GPT-4) on one of 7 distinct topics.

Then, from the shell, if I have the `Meda` executable in my path I can type:
```bash
Meda find --query="great developments in technology" --base_dir="./test/data/content/"
```

I get the following (abbreviated) result:
```
▪ 452cea: JavaScript snippets and libraries for interactive web applications
▪ 0705d1: Responsive web design tutorials and best practices
▪ fe7a1d: React components and hooks for front-end development
  … (omitting 7 results)

▪ d58ad0: Gallery of restored photographs from the Industrial Revolution (***)
▪ 69b7db: Collection of advanced post-processing techniques in Adobe Photoshop
▪ 4cfa56: Guide to vintage camera collection and maintenance
  … (omitting 3 results)

▪ c28593: Compilation of quick and easy 30-minute meals
▪ 192ae6: Dietary advice and recipes for weight loss and muscle gain
▪ 4d30e0: Nutritional guides and meal plans for athletes
  … (omitting 5 results)

▪ b2054c: Interactive timeline of significant scientific discoveries (***)
▪ 22610e: Space exploration timelines and historical documents (***)
▪ 69575d: Audiovisual materials on the space race of the 20th century (***)
  … (omitting 12 results)
```

In each line in the result, we see a hexadecimal key (a random name for the folder containing some content) and a description of the contents of the folder that it refers to. What's happening here is that the 70 `meta.json` files from my GPT-4-generated testing set are parsed and clustered into `k` topics. Each topic is sorted by relevance to my query, "great developments in technology." Those results that are among the `top_n` most relevant to my query are given in bold (denoted with `(***)` in the above due to Markdown limitations). For each topic, up to `n_per_group` results are shown, and then the rest are elided. For brevity, only four of ten topics are shown above.

The parameters mentioned above (`k`, `top_n`, `n_per_group`) are all additional command lines args that you can specify, each with a default value of 5.

To create a new `key` and a directory for it:
```
Meda create --purpose="My reason for creating this directory" --base_dir="~/content/"
```

## TODO
There are several obvious next steps but which unfortunately I probably won't have the bandwidth to implement myself:
- create a dependency graph of relationships among items
- add comments from code into the body of metadata that gets searched
