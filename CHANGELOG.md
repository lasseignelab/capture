## CAPTURE 0.5.2 (February 7, 2025) ##

* Fix `cap md5` not working with symlinks

## CAPTURE 0.5.1 (February 5, 2025) ##
:warning: **WARNING** This is a breaking change!

* Change `cap_data_download` default unzip behaviour.  The previous default was
to unzip but is now to simply download the file without unzipping.  To unzip
the `--unzip` option must be added.

    ```bash
    cap_data_download \
        --unzip \
        --md5sum="37c51137ccaeabd4d151f80dc86ce0b3" \
        "https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCm39-2024-A.tar.gz"
    ```

## CAPTURE 0.5.0 (January 31, 2025) ##

* Add tab completion for the `cap` command.

## CAPTURE 0.4.0 (January 13, 2025) ##

* Add `cap md5` options --select and --ignore

## CAPTURE 0.3.1 (December 16, 2024) ##

* Upgrade the Bioconductor version

## CAPTURE 0.3.0 (November 20, 2024) ##

* Improve the `cap_data_download` error handling for md5sum errors.

## CAPTURE 0.2.0 (November 15, 2024) ##

* Add the `cap_array_value` job helper function.

## CAPTURE 0.1.0 (October 29, 2024) ##

* Add the `cap run` environment override option `-e`, `--environment`.

