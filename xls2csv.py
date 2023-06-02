#!/usr/bin/python3

import os
import argparse
import xlrd
import sys
import errno


def get_args():
    parser = argparse.ArgumentParser(description="convert xls to csv")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("-n", "--sheetname", type=str, help="sheet name to convert")
    group.add_argument("-s", "--sheet", type=int, help="sheet number to convert")
    parser.add_argument("xlsfile")
    return parser.parse_args()


if __name__ == "__main__":
    args = get_args()

    file_path = os.path.join(os.getcwd(), args.xlsfile)
    try:
        wb = xlrd.open_workbook(file_path)
        if args.sheetname:
            ws = wb.sheet_by_name(args.sheetname)
        elif args.sheet:
            ws = wb.sheet_by_index(args.sheet - 1)
        else:
            ws = wb.sheet_by_index(0)
        values = [ws.row_values(i) for i in range(ws.nrows)]
        # exception for broken pipe error
        try:
            for value in values:
                print(",".join(map(str, value)))
            sys.exit(0)
        except IOError as e:
            if e.errno == errno.EPIPE:
                pass
            sys.exit(0)
    except FileNotFoundError as e:
        print("FileNotFoundError: {}".format(e), file=sys.stderr)
        sys.exit(1)
    except xlrd.biffh.XLRDError as e:
        print("XLRDError: {}".format(e), file=sys.stderr)
        sys.exit(1)
    except IndexError as e:
        print("IndexError: {}".format(e), file=sys.stderr)
        sys.exit(1)
