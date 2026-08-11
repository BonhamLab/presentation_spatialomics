# BioJulia GitHub organisation stats
#
# Requires: gh CLI (authenticated as a BioJulia admin/collaborator so that
#           starred_at timestamps are returned — GitHub restricted these to
#           admins/collaborators in July 2026), plus JSON, DataFrames, Dates.
#
#   using Pkg; Pkg.add(["JSON", "DataFrames"])
#
# All gh calls go through Cmd() and read(cmd, String). Pagination is delegated
# to `gh --paginate --slurp`, which returns an outer array of pages; we flatten.

module GHInfo

export monthly_star_history,
       org_repos,
       all_histories,
       history_dataframe,
       activity_summary,
       repo_history,
       commit_table

using JSON, DataFrames, Dates

const ORG = "BioJulia"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Run a gh api call and parse its JSON stdout.
gh_json(args::Cmd) = JSON.parse(read(`gh api $args`, String))

# gh --paginate --slurp returns [[page1...], [page2...], ...]; flatten to one vector.
function gh_paginated(endpoint::AbstractString; accept=nothing)
    args = ["--paginate", "--slurp"]
    accept !== nothing && append!(args, ["-H", "Accept: $accept"])
    push!(args, endpoint)
    pages = JSON.parse(read(`gh api $(Cmd(args))`, String))
    reduce(vcat, pages; init=Any[])
end

# GitHub ISO-8601 timestamps: "2017-08-10T14:23:01Z"
parse_gh_datetime(s) = DateTime(s, dateformat"yyyy-mm-ddTHH:MM:SSZ")
parse_gh_date(s)     = Date(parse_gh_datetime(s))

# ---------------------------------------------------------------------------
# 1. Monthly star history for a repo (e.g. "BioJulia/Bio.jl")
# ---------------------------------------------------------------------------

function star_timestamps(repo::AbstractString)
    stars = gh_paginated("/repos/$repo/stargazers";
                         accept="application/vnd.github.star+json")
    sort!([parse_gh_datetime(s["starred_at"]) for s in stars])
end

"Return a DataFrame with one row per month: :month, :new_stars, :cumulative."
function monthly_star_history(repo::AbstractString)
    ts = star_timestamps(repo)
    isempty(ts) && return DataFrame(month=Date[], new_stars=Int[], cumulative=Int[])

    months = firstdayofmonth.(Date.(ts))
    df = combine(groupby(DataFrame(month=months), :month), nrow => :new_stars)
    sort!(df, :month)
    df.cumulative = cumsum(df.new_stars)
    df
end

# Example (the one you asked to be shown explicitly):
#   bio_stars = monthly_star_history("BioJulia/Bio.jl")

# ---------------------------------------------------------------------------
# 2. Repo list + total count
# ---------------------------------------------------------------------------

function latest_release(org, repo)
    cmd = `gh api /repos/$org/$repo/releases/latest`
    p = pipeline(cmd; stderr=devnull)
    io = IOBuffer()
    success(pipeline(p; stdout=io)) || return (missing, missing)
    r = JSON.parse(String(take!(io)))
    (r["tag_name"], parse_gh_date(r["published_at"]))
end

"DataFrame of all org repos with a few useful columns; row count = total repos."
function org_repos(org::AbstractString=ORG)
    repos = gh_paginated("/orgs/$org/repos?per_page=100&type=all")
    df = DataFrame(
        name       = [r["name"] for r in repos],
        full_name  = [r["full_name"] for r in repos],
        archived   = [r["archived"] for r in repos],
        stars      = [r["stargazers_count"] for r in repos],
        forks      = [r["forks_count"] for r in repos],
        open_issues= [r["open_issues_count"] for r in repos],
        created    = [parse_gh_date(r["created_at"]) for r in repos],
        pushed     = [parse_gh_date(r["pushed_at"]) for r in repos],
    )
    rel = [latest_release(org, n) for n in df.name]
    df.last_release      = first.(rel)
    df.last_release_date = last.(rel)
    return df
end

# repos_df = org_repos()
# total_repos = nrow(repos_df)

# ---------------------------------------------------------------------------
# 3. Commit + release history per repo
# ---------------------------------------------------------------------------

# Releases reference tags by name; tags carry the real commit SHA. Join through
# /tags to map SHA => release tag (release target_commitish is unreliable).
function release_shas(org, repo)
    tags = gh_paginated("/repos/$org/$repo/tags?per_page=100")
    rels = gh_paginated("/repos/$org/$repo/releases?per_page=100")
    tagname_to_sha = Dict(t["name"] => t["commit"]["sha"] for t in tags)
    Dict(tagname_to_sha[r["tag_name"]] => r["tag_name"]
         for r in rels if haskey(tagname_to_sha, r["tag_name"]))
end

"Vector of NamedTuples (commit, date, release) for one repo, newest first."
function repo_history(org, repo)
    commits = gh_paginated("/repos/$org/$repo/commits?per_page=100")
    rel = release_shas(org, repo)
    [(; commit = c["sha"],
        date   = parse_gh_date(c["commit"]["author"]["date"]),
        release = get(rel, c["sha"], nothing))
     for c in commits]
end

# The Dict form you described:
#   history["BioSequences.jl"] =>
#     [(commit="a1b2…", date=Date(2017,8,10), release="v3.1.0"),
#      (commit="c3d4…", date=Date(2017,8,9),  release=nothing), …]
function all_histories(repos_df::DataFrame; org::AbstractString=ORG)
    history = Dict{String, Vector{NamedTuple}}()
    for name in repos_df.name
        history[name] = repo_history(org, name)
    end
    history
end

# Same data, long-format DataFrame — easier for grouped analysis / plotting.
function history_dataframe(history::AbstractDict)
    df = DataFrame(repo=String[], commit=String[], date=Date[],
                   release=Union{String,Missing}[])
    for (repo, entries) in history, e in entries
        push!(df, (repo, e.commit, e.date,
                   e.release === nothing ? missing : e.release))
    end
    df
end

# Per-repo activity summary as a DataFrame.
function activity_summary(history::AbstractDict)
    df = DataFrame(
        repo          = String[],
        n_commits     = Int[],
        n_releases    = Int[],
        first_commit  = Date[],
        last_commit   = Date[],
    )
    for (repo, entries) in history
        isempty(entries) && continue
        dates = [e.date for e in entries]
        push!(df, (repo,
                   length(entries),
                   count(e -> e.release !== nothing, entries),
                   minimum(dates),
                   maximum(dates)))
    end
    sort!(df, :n_commits, rev=true)
end


function commits_since(org, repo, since::Date)
    ep = "/repos/$org/$repo/commits?per_page=100&since=$(since)T00:00:00Z"
    GHInfo.gh_paginated(ep)
end

# committer identity: prefer GitHub login, fall back to git author name
function committer(c)
    a = c["author"]
    a !== nothing && haskey(a, "login") ? a["login"] : c["commit"]["author"]["name"]
end

function commit_table(org, repos, since::Date)
    df = DataFrame(repo=String[], committer=String[], date=Date[])
    for repo in repos
        for c in commits_since(org, repo, since)
            push!(df, (repo, committer(c), GHInfo.parse_gh_date(c["commit"]["author"]["date"])))
        end
    end
    df
end

# ---------------------------------------------------------------------------
# Example driver (uncomment to run):
# ---------------------------------------------------------------------------
# repos_df    = org_repos()
# @info "Total repos" total = nrow(repos_df)
#
# bio_stars   = monthly_star_history("BioJulia/Bio.jl")
#
# history     = all_histories(repos_df)
# history_df  = history_dataframe(history)
# activity_df = activity_summary(history)
#
end # module
