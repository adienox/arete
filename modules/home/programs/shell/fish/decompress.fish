function decompress --description 'Extract archives of (almost) any format'
    argparse h/help 'd/dir=' -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -eq 0
        echo 'Usage: decompress [-d DIR] ARCHIVE...'
        echo
        echo '  -d, --dir DIR   extract into DIR (created if missing); default: current dir'
        echo
        echo 'Handles tar(.gz/.bz2/.xz/.zst/.lz4/.lz), zip, 7z, rar, gz, bz2, xz, zst,'
        echo 'lz4, Z, deb, rpm, and falls back to bsdtar / 7-Zip for the rest (iso, cab, ...).'
        echo 'Missing tools are run through comma (`, cmd`) when available.'
        return 0
    end

    set -l dest .
    if set -q _flag_dir
        mkdir -p -- $_flag_dir; or return 1
        set dest $_flag_dir
    end

    # Prefer an installed 7-Zip binary; otherwise ask comma for 7zz
    set -l sz 7zz
    for c in 7zz 7z 7za
        if command -q $c
            set sz $c
            break
        end
    end

    set -l rc 0
    for f in $argv
        if not test -f $f
            echo "decompress: not a file: $f" >&2
            set rc 1
            continue
        end

        # Name for single-file formats: strip the last extension
        set -l base (string replace -r '\.[^.]+$' '' -- (path basename $f))

        # Decompressor for tar.* and single-file formats. It runs as a separate
        # pipeline stage (not via tar's auto-detect) so comma can supply it.
        set -l dc
        switch (string lower -- $f)
            case '*.tar.gz' '*.tgz' '*.tar.z' '*.gz' '*.z'
                set dc gzip -dc
            case '*.tar.bz2' '*.tbz2' '*.bz2'
                set dc bzip2 -dc
            case '*.tar.xz' '*.txz' '*.xz'
                set dc xz -dc
            case '*.tar.zst' '*.tzst' '*.zst'
                set dc zstd -dcq
            case '*.tar.lz4' '*.lz4'
                set dc lz4 -dcq
            case '*.tar.lz' '*.lz'
                set dc lzip -dc
        end

        switch (string lower -- $f)
            case '*.tar'
                __archive_run tar -xf $f -C $dest
            case '*.tar.gz' '*.tgz' '*.tar.z' '*.tar.bz2' '*.tbz2' '*.tar.xz' '*.txz' \
                 '*.tar.zst' '*.tzst' '*.tar.lz4' '*.tar.lz'
                __archive_run $dc $f | __archive_run tar -xf - -C $dest
                set -l ps $pipestatus
                test $ps[1] -eq 0; and test $ps[2] -eq 0
            case '*.zip' '*.jar' '*.apk' '*.whl' '*.epub'
                __archive_run unzip -q -o $f -d $dest
            case '*.7z'
                __archive_run $sz x -o$dest -y $f >/dev/null
            case '*.rar'
                # unrar is unfree, so comma can't fetch it; libarchive reads rar too
                if command -q unrar
                    unrar x -o+ -idq $f $dest/
                else
                    __archive_run bsdtar -xf $f -C $dest
                end
            case '*.gz' '*.bz2' '*.xz' '*.zst' '*.lz4' '*.z' '*.lz'
                __archive_run $dc $f >$dest/$base
            case '*.deb'
                __archive_run dpkg-deb -x $f $dest
            case '*.rpm'
                __archive_run bsdtar -xf $f -C $dest
            case '*'
                # iso, cab, dmg, cpio, xar, ... let libarchive / 7-Zip sniff it
                __archive_run bsdtar -xf $f -C $dest
                or __archive_run $sz x -o$dest -y $f >/dev/null
        end
        or begin
            echo "decompress: failed: $f" >&2
            set rc 1
            continue
        end
        echo "extracted $f"
    end
    return $rc
end
