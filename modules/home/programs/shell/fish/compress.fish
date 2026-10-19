function compress --description 'Create an archive; the format is chosen from the output extension'
    if test (count $argv) -eq 0; or contains -- $argv[1] -h --help
        echo 'Usage: compress [ARCHIVE.ext] INPUT...'
        echo
        echo '  compress project/              -> project.tar.zst'
        echo '  compress a b c/                -> archive.tar.zst'
        echo '  compress out.tar.xz a b c/'
        echo '  compress notes.txt.gz notes.txt   (single-file formats take one file)'
        echo
        echo 'Formats: tar tar.gz tgz tar.bz2 tbz2 tar.xz txz tar.zst tar.lz4'
        echo '         zip 7z rar gz bz2 xz zst lz4'
        echo 'Missing tools are run through comma (`, cmd`) when available.'
        return 0
    end

    set -l ext_re '\.(tar|tar\.(gz|bz2|xz|zst|lz4)|tgz|tbz2|txz|zip|7z|rar|gz|bz2|xz|zst|lz4)$'
    set -l out
    set -l inputs

    # First arg is the output name if it looks like an archive and doesn't exist yet
    if test (count $argv) -ge 2; and not test -e $argv[1]
        and string match -qr -- $ext_re (string lower -- $argv[1])
        set out $argv[1]
        set inputs $argv[2..-1]
    else
        set inputs $argv
        if test (count $inputs) -eq 1
            set out (path basename (string trim --right --chars=/ -- $inputs[1])).tar.zst
        else
            set out archive.tar.zst
        end
    end

    for i in $inputs
        if not test -e $i
            echo "compress: no such file or directory: $i" >&2
            return 1
        end
    end

    if test -e $out
        echo "compress: refusing to overwrite existing '$out'" >&2
        return 1
    end

    # Prefer an installed 7-Zip binary; otherwise ask comma for 7zz
    set -l sz 7zz
    for c in 7zz 7z 7za
        if command -q $c
            set sz $c
            break
        end
    end

    # Compressor for tar.* and single-file formats. It runs as a separate
    # pipeline stage (not via tar -I) so comma can supply it if missing.
    set -l cc
    switch (string lower -- $out)
        case '*.tar.gz' '*.tgz' '*.gz'
            set cc gzip -c
        case '*.tar.bz2' '*.tbz2' '*.bz2'
            set cc bzip2 -c
        case '*.tar.xz' '*.txz' '*.xz'
            set cc xz -T0 -c
        case '*.tar.zst' '*.zst'
            set cc zstd -T0 -q -c
        case '*.tar.lz4' '*.lz4'
            set cc lz4 -q -c
    end

    set -l rc 0
    switch (string lower -- $out)
        case '*.tar'
            __archive_run tar -cf $out $inputs
        case '*.tar.gz' '*.tgz' '*.tar.bz2' '*.tbz2' '*.tar.xz' '*.txz' '*.tar.zst' '*.tar.lz4'
            __archive_run tar -cf - $inputs | __archive_run $cc >$out
            set -l ps $pipestatus
            test $ps[1] -eq 0; and test $ps[2] -eq 0
        case '*.zip'
            __archive_run zip -qr $out $inputs
        case '*.7z'
            __archive_run $sz a $out $inputs >/dev/null
        case '*.rar'
            __archive_run rar a -idq $out $inputs
        case '*.gz' '*.bz2' '*.xz' '*.zst' '*.lz4'
            if test (count $inputs) -ne 1; or not test -f $inputs[1]
                echo "compress: this format takes exactly one regular file (use .tar.* for directories)" >&2
                return 1
            end
            __archive_run $cc $inputs[1] >$out
        case '*'
            echo "compress: unsupported format: $out" >&2
            return 1
    end
    or set rc 1

    if test $rc -ne 0
        echo "compress: failed to create '$out'" >&2
        rm -f -- $out
        return 1
    end
    echo "created $out"
end
