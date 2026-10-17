function __archive_run --description 'Run a command; if it is not installed, run it through comma'
    set -l cmd $argv[1]
    if command -q $cmd
        command $cmd $argv[2..-1]
    else if command -q ,
        command , $cmd $argv[2..-1]
    else
        echo "missing command '$cmd' (install it, or install comma)" >&2
        return 127
    end
end
