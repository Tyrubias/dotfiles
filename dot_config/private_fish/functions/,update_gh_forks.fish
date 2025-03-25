function ,update_gh_forks --description "Update all GitHub forks from upstream for the authenticated user"
    # Parse command-line options
    argparse --name=,update_gh_forks h/help v/verbose s/sequential -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: ,update_gh_forks [OPTIONS]"
        echo "Update all GitHub forks from their upstream repositories"
        echo
        echo "Options:"
        echo "  -h, --help        Show this help message"
        echo "  -v, --verbose     Show detailed JSON output for each operation"
        echo "  -s, --sequential  Process forks sequentially (don't use parallel)"
        return 0
    end

    # Check if GitHub CLI is available
    if not command -v gh >/dev/null
        echo "Error: GitHub CLI (gh) is not installed or not in PATH" >&2
        return 1
    end

    # Get the authenticated user's login dynamically
    echo "Fetching user information..."
    set -l user (gh api /user --jq '.login' 2>/dev/null)
    if test $status -ne 0 || test -z "$user"
        echo "Error: Failed to get authenticated user. Make sure you're logged in with 'gh auth login'" >&2
        return 1
    end
    echo "Authenticated as: $user"

    # Retrieve forked repositories for the current user
    echo "Retrieving forked repositories..."
    set -l forks (gh api --paginate --jq 'map(select(.fork)) | .[] | "\(.full_name)\t\(.default_branch)"' users/$user/repos 2>/dev/null)
    if test $status -ne 0
        echo "Error: Failed to retrieve repository list" >&2
        return 1
    end

    set -l fork_count (count $forks)
    if test $fork_count -eq 0
        echo "No forks found for user $user"
        return 0
    end
    echo "Found $fork_count forked repositories"

    # Set verbose flag for parallel processes
    set -l verbose_flag 0
    if set -q _flag_verbose
        set verbose_flag 1
    end

    # Determine whether to use parallel processing
    if set -q _flag_sequential || not command -v parallel >/dev/null
        if set -q _flag_sequential
            echo "Using sequential processing as requested..."
        else
            echo "GNU Parallel not found, using sequential processing..."
        end

        # Process forks sequentially
        for fork in $forks
            set -l repo_info (string split -m 1 \t -- $fork)
            set -l repo_name $repo_info[1]
            set -l default_branch $repo_info[2]

            echo "Updating $repo_name..."
            set -l result (gh api --method POST -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /repos/$repo_name/merge-upstream -f branch=$default_branch 2>&1)
            set -l exit_status $status

            if test $exit_status -ne 0
                echo "  Error: $result" >&2
            else if set -q _flag_verbose
                echo $result | jq . 2>/dev/null; or echo "  $result"
            else
                # Extract message if possible
                set -l message (echo $result | jq -r '.message // empty' 2>/dev/null)
                if test -n "$message"
                    echo "  $message"
                else
                    echo "  $result"
                end
            end

            echo ""
        end
    else
        echo "Updating forks using parallel processing..."

        # Build an array of formatted commands
        set -l formatted_commands
        for fork in $forks
            set -l repo_info (string split -m 1 \t -- $fork)
            set -a formatted_commands "$repo_info[1]#$repo_info[2]#$verbose_flag"
        end

        # Run parallel with the formatted commands using the ::: syntax
        parallel --colsep '#' --keep-order '
            echo "Updating {1}...";
            set -l result (gh api --method POST -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /repos/{1}/merge-upstream -f branch={2} 2>&1);
            
            if test $status -ne 0;
                echo "  Error: $result" >&2;
            else if test "{3}" = "1";
                echo $result | jq . 2>/dev/null; or echo "  $result";
            else;
                set -l message (echo $result | jq -r \'.message // empty\' 2>/dev/null);
                if test -n "$message";
                    echo "  $message";
                else;
                    echo "  $result";
                end;
            end;
            
            echo "";
        ' ::: $formatted_commands
    end

    echo "Fork update process completed"
end
