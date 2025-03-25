function ,update_git_repos -d "Update all Git repositories in a directory"
    # Parse arguments
    argparse h/help -- $argv 2>/dev/null

    # Show help if requested
    if set -q _flag_help
        echo "Usage: ,update_git_repos [DIRECTORY]"
        echo "Update all Git repositories in the specified directory (or current directory if not specified)."
        echo ""
        echo "This function:"
        echo "  Finds Git repositories in the directory (ignoring nested ones)"
        echo "  Fetches all branches and tags from all remotes with pruning"
        echo "  Updates the current branch with rebasing"
        echo "  Updates other branches with hub sync if available"
        echo "  Updates submodules"
        return 0
    end

    # Set search directory
    set -l search_dir "."
    test (count $argv) -gt 0; and set search_dir $argv[1]

    # Verify directory exists
    if not test -d $search_dir
        echo "Error: Directory '$search_dir' does not exist"
        return 1
    end

    # Verify git is installed
    if not command -v git >/dev/null
        echo "Error: git command not found"
        return 1
    end

    # Determine how to find git repos
    set -l find_cmd
    if command -v fd >/dev/null
        # Fix: Properly escape the regex pattern
        set find_cmd "fd -a -H -t d '\\.git\$' $search_dir"
    else
        set find_cmd "find $search_dir -type d -name '.git' -print"
    end

    # Check for hub availability
    set -l has_hub (command -v hub >/dev/null; and echo true; or echo false)

    echo "Updating Git repositories in $search_dir..."

    # Initialize counters
    set -l updated 0
    set -l skipped 0
    set -l errors 0

    # Process each git repository
    eval $find_cmd | while read -l gitdir
        set -l repo_dir (dirname "$gitdir")

        # Skip nested repositories
        if git -C (dirname "$repo_dir") rev-parse --is-inside-work-tree 2>/dev/null >/dev/null
            echo "Skipping nested repository: $repo_dir"
            set skipped (math $skipped + 1)
            continue
        end

        echo "Updating repository: $repo_dir"

        # Fetch updates
        echo "Fetching updates..."
        if not git -C $repo_dir fetch --all --prune --tags
            echo "Error: Failed to fetch for $repo_dir"
            set errors (math $errors + 1)
            continue
        end

        # Get current branch
        set -l current_branch (git -C $repo_dir branch --show-current 2>/dev/null)

        if test -z "$current_branch"
            echo "Warning: Not on a branch in $repo_dir (possibly in detached HEAD state)"
        else
            # Update current branch
            echo "Updating branch: $current_branch..."
            if not git -C $repo_dir pull --rebase --autostash
                echo "Error: Failed to update branch in $repo_dir"
                set errors (math $errors + 1)
                continue
            end

            # Update other branches with hub if available
            if test "$has_hub" = true
                echo "Syncing other branches with hub..."
                hub -C $repo_dir sync 2>/dev/null; or echo "Warning: hub sync encountered issues (continuing)"
            end
        end

        # Update submodules if they exist
        if test -f "$repo_dir/.gitmodules"
            echo "Updating submodules..."
            git -C $repo_dir submodule update --init --recursive; or echo "Warning: Submodule update encountered issues (continuing)"
        end

        echo "Finished updating $repo_dir"
        echo ""
        set updated (math $updated + 1)
    end

    # Display summary
    echo "Summary:"
    echo "  Updated: $updated repositories"
    echo "  Skipped: $skipped repositories (nested)"
    echo "  Errors: $errors repositories"

    # Return success only if no errors occurred
    test $errors -eq 0
end
