function ,delete_old_branches --description "Delete local Git branches that were deleted on the remote"
    argparse f/force p/prune h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: ,delete_old_branches [OPTIONS] [DIRECTORY]"
        echo "Delete local Git branches that were deleted on their remote"
        echo "Options:"
        echo "  -f, --force    Skip confirmation prompt"
        echo "  -p, --prune    Run git fetch --prune before checking branches"
        echo "  -h, --help     Display this help message"
        return 0
    end

    # Get repository path
    set -l repo_path "."
    test (count $argv) -gt 0; and set repo_path $argv[1]

    # Validate repository
    if not git -C $repo_path rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not a valid Git repository"
        return 1
    end

    # Optionally prune first
    if set -q _flag_prune
        echo "Pruning remote tracking branches..."
        git -C $repo_path fetch --prune
    end

    # Get gone branches using the recommended approach
    set -l gone_branches (git -C $repo_path for-each-ref --format '%(if:equals=gone)%(upstream:track,nobracket)%(then)%(refname:short)%(end)' refs/heads/)

    # Filter out empty entries or whitespace-only entries
    set -l valid_branches
    for branch in $gone_branches
        set -l trimmed_branch (string trim $branch)
        if test -n "$trimmed_branch"
            set -a valid_branches $trimmed_branch
        end
    end

    if test (count $valid_branches) -eq 0
        echo "No branches with deleted remotes found"
        return 0
    end

    # Show branches and confirm
    echo "Found "(count $valid_branches)" branch(es) with deleted remotes:"
    printf "  %s\n" $valid_branches

    if not set -q _flag_force
        read -l -P "Delete these branches? [y/N] " confirm
        string match -q -i y $confirm; or begin
            echo "Operation cancelled"
            return 0
        end
    end

    # Delete branches
    set -l status 0
    for branch in $valid_branches
        if git -C $repo_path branch -D $branch 2>/dev/null
            echo "Deleted: $branch"
        else
            echo "Failed to delete: $branch"
            set status 1
        end
    end

    return $status
end
