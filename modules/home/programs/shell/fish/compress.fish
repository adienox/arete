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

    # Locate a 7-Zip binary (name varies by distro)
    set -l sz
    for c in 7zz 7z 7za
        if type -q $c
            set sz $c
            break
        end
    end

    set -l rc 0
    switch (string lower -- $out)
        case '*.tar'
            tar -cf $out $inputs
        case '*.tar.gz' '*.tgz'
            tar -czf $out $inputs
        case '*.tar.bz2' '*.tbz2'
            tar -cjf $out $inputs
        case '*.tar.xz' '*.txz'
            tar -I 'xz -T0' -cf $out $inputs
        case '*.tar.zst'
            tar -I 'zstd -T0' -cf $out $inputs
        case '*.tar.lz4'
            tar -I lz4 -cf $out $inputs
        case '*.zip'
            if type -q zip
                zip -qr $out $inputs
            else if test -n "$sz"
                $sz a -tzip $out $inputs >/dev/null
            else
                echo "compress: need 'zip' or 7-Zip installed" >&2
                return 1
            end
        case '*.7z'
            if test -z "$sz"
                echo "compress: need 7-Zip installed" >&2
                return 1
            end
            $sz a $out $inputs >/dev/null
        case '*.rar'
            if not type -q rar
                echo "compress: need 'rar' installed" >&2
                return 1
            end
            rar a -idq $out $inputs
        case '*.gz' '*.bz2' '*.xz' '*.zst' '*.lz4'
            if test (count $inputs) -ne 1; or not test -f $inputs[1]
                echo "compress: this format takes exactly one regular file (use .tar.* for directories)" >&2
                return 1
            end
            switch (string lower -- $out)
                case '*.gz'
                    gzip -c $inputs[1] >$out
                case '*.bz2'
                    bzip2 -c $inputs[1] >$out
                case '*.xz'
                    xz -T0 -c $inputs[1] >$out
                case '*.zst'
                    zstd -T0 -q -c $inputs[1] >$out
                case '*.lz4'
                    lz4 -q -c $inputs[1] >$out
            end
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
