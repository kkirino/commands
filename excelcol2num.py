#!/usr/bin/python3

import argparse
import sys


# TODO
# add option to conduct below
# alphabetical column name -> integer
# integer -> alphabetical column name


def get_args():
    parser = argparse.ArgumentParser(
        description="convert alphabetical column names to numbers"
    )
    parser.add_argument(
        "colname", type=str, help="alphabetical letters to convert into numbers"
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = get_args()

    is_alphabets = [0 < (ord(letter.lower()) - 96) < 27 for letter in args.colname]
    is_all_alphabets = sum(is_alphabets) == len(args.colname)
    if is_all_alphabets:
        print(
            sum(
                [
                    (26 ** (len(args.colname) - index - 1)) * (ord(letter.lower()) - 96)
                    for index, letter in enumerate(args.colname)
                ]
            )
        )
        sys.exit(0)
    else:
        print(
            "InputError: column name should be alphabetical letters.", file=sys.stderr
        )
        sys.exit(1)
