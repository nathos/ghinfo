# ghinfo
jq-powered Bash script experiment to display useful information about GitHub users &amp; repos

## What is it?

`ghinfo` displays summaries of GitHub users and repositories. Quickly grab stats, get a sense of project activiy, and display clone URLs all without leaving the command line.

## Usage

* To display a summary of a GitHub user:

  ``` ./ghinfo.sh -u <username> ```

* To display a summary of a GitHub repository:

  ``` ./ghinfo.sh -r <username/repositoryname> ```

**NOTE:** `ghinfo.sh` must be executable: ```chmod 755 ghinfo.sh```

## Dependencies

`ghinfo` uses the [`jq` JSON processor](http://stedolan.github.io/jq/) and `curl`.

See the [detailed installation instructions for `jq`](http://stedolan.github.io/jq/download/). 

Mac users can easily install `jq` with [Homebrew](http://brew.sh):

``` brew install jq ```
