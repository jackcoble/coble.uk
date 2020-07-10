# hugo-theme-bulma
This is my custom theme that I put together for my Hugo [blog](https://blog.3xpl0its.xyz). It uses the Bulma CSS Framework, which is CSS only - there is no JavaScript.

## Installation
Inside your Hugo website directory, create a folder named `themes` if you don't have one and then add the theme as a git submodule.

```bash
$ mkdir themes
$ git submodule add https://github.com/jackcoble/hugo-theme-bulma.git themes/hugo-theme-bulma
```

## Configuration
This is the config.toml I recommend you using for now.

```toml
baseURL = "https://site-url.com/"
languageCode = "en-gb"
title = "Site Name"
theme = "hugo-theme-bulma"
summaryLength = 30

# Code syntax
pygmentsstyle = "monokai"
pygmentscodefences = true
pygmentscodefencesguesssyntax = true

# Pagination
paginate=5

[permalinks]
  posts = "/:year/:month/:title/"
```