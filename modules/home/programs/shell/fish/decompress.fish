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
        return 0
    end

    set -l dest .
    if set -q _flag_dir
        mkdir -p -- $_flag_dir; or return 1
        set dest $_flag_dir
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
    for f in $argv
        if not test -f $f
            echo "decompress: not a file: $f" >&2
            set rc 1
            continue
        end

        # Name for single-file formats: strip the last extension
        set -l base (string replace -r '\.[^.]+$' '' -- (path basename $f))

        switch (string lower -- $f)
            case '*.tar' '*.tar.gz' '*.tgz' '*.tar.bz2' '*.tbz2' '*.tar.xz' '*.txz' \
                 '*.tar.zst' '*.tzst' '*.tar.lz4' '*.tar.lz' '*.tar.z'
                tar -xf $f -C $dest
            case '*.zip' '*.jar' '*.apk' '*.whl' '*.epub'
                if type -q unzip
                    unzip -q -o $f -d $dest
                else if test -n "$sz"
                    $sz x -o$dest -y $f >/dev/null
                else
                    echo "decompress: need 'unzip' or 7-Zip" >&2
                    false
                end
            case '*.7z'
                if test -n "$sz"
                    $sz x -o$dest -y $f >/dev/null
                else
                    echo "decompress: need 7-Zip" >&2
                    false
                end
            case '*.rar'
                if type -q unrar
                    unrar x -o+ -idq $f $dest/
                else if test -n "$sz"
                    $sz x -o$dest -y $f >/dev/null
                else if type -q bsdtar
                    bsdtar -xf $f -C $dest
                else
                    echo "decompress: need 'unrar', 7-Zip or bsdtar" >&2
                    false
                end
            case '*.gz'
                gzip -dc $f >$dest/$base
            case '*.bz2'
                bzip2 -dc $f >$dest/$base
            case '*.xz'
                xz -dc $f >$dest/$base
            case '*.zst'
                zstd -dcq $f >$dest/$base
            case '*.lz4'
                lz4 -dcq $f >$dest/$base
            case '*.z'
                gzip -dc $f >$dest/$base
            case '*.lz'
                lzip -dc $f >$dest/$base
            case '*.deb'
                dpkg-deb -x $f $dest
            case '*.rpm'
                if type -q bsdtar
                    bsdtar -xf $f -C $dest
                else
                    rpm2cpio $f | begin
                        cd $dest; and cpio -idm --quiet
                    end
                end
            case '*'
                # iso, cab, dmg, cpio, xar, ... let libarchive / 7-Zip sniff it
                if type -q bsdtar
                    bsdtar -xf $f -C $dest
                else if test -n "$sz"
                    $sz x -o$dest -y $f >/dev/null
                else
                    echo "decompress: unsupported format: $f" >&2
                    false
                end
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
