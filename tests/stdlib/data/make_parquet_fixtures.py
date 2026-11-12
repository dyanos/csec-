"""Regenerate the Parquet fixtures used by tests/stdlib/positive/17-20 (needs pyarrow).

    python tests/stdlib/data/make_parquet_fixtures.py

Every "people_*" file holds the same 10-row table written with a different combination of page
version, encoding, and compression, so the tests can check one set of expected values against each.
"""

import datetime
import decimal
import os

import pyarrow as pa
import pyarrow.parquet as pq

HERE = os.path.dirname(os.path.abspath(__file__))


def people():
    return pa.table(
        {
            "id": pa.array(range(1, 11), pa.int64()),
            "name": pa.array(["alice", "bob", "carol", None, "dave", "erin", "frank", None, "grace", "heidi"], pa.string()),
            "region": pa.array(["east", "west", "east", "north", "west", "east", "north", "west", "east", "west"], pa.string()),
            "score": pa.array([1.5, 2.5, 3.0, 4.0, None, 6.25, 7.0, 8.5, 9.0, 10.75], pa.float64()),
            "flag": pa.array([True, False, True, True, False, False, True, False, True, True], pa.bool_()),
            "small": pa.array([-3, -2, -1, 0, 1, 2, 3, 4, 5, 6], pa.int32()),
        }
    )


def write(name, table, **options):
    pq.write_table(table, os.path.join(HERE, name), **options)


def main():
    table = people()
    # Dictionary pages, data page v1, SNAPPY, three row groups.
    write("people_snappy_dict.parquet", table, compression="snappy", row_group_size=4)
    # PLAIN values in data page v2, no compression.
    write("people_plain_v2.parquet", table, compression="none", use_dictionary=False, data_page_version="2.0")
    write("people_gzip.parquet", table, compression="gzip")
    write("people_lz4.parquet", table, compression="lz4")
    write("people_zstd.parquet", table, compression="zstd")
    # DELTA_* and BYTE_STREAM_SPLIT encodings in data page v2.
    write(
        "people_delta.parquet",
        table,
        compression="snappy",
        use_dictionary=False,
        data_page_version="2.0",
        column_encoding={
            "id": "DELTA_BINARY_PACKED",
            "small": "DELTA_BINARY_PACKED",
            "name": "DELTA_BYTE_ARRAY",
            "region": "DELTA_LENGTH_BYTE_ARRAY",
            "score": "BYTE_STREAM_SPLIT",
        },
    )

    # Logical types: date, timestamp, decimal, float32, INT96 timestamps, fixed-size binary.
    types = pa.table(
        {
            "day": pa.array([datetime.date(1970, 1, 2), datetime.date(2024, 2, 29), None], pa.date32()),
            "at_ms": pa.array([datetime.datetime(1970, 1, 1, 0, 0, 1), datetime.datetime(2000, 1, 1), None], pa.timestamp("ms")),
            "price": pa.array([decimal.Decimal("12.34"), decimal.Decimal("-0.05"), None], pa.decimal128(9, 2)),
            "big_price": pa.array([decimal.Decimal("123456789012.345"), None, decimal.Decimal("-1.000")], pa.decimal128(20, 3)),
            "ratio": pa.array([0.5, -2.25, None], pa.float32()),
            "code": pa.array([b"abc", b"xyz", None], pa.binary(3)),
        }
    )
    write("types.parquet", types, compression="none")
    write(
        "types_int96.parquet",
        pa.table({"at_ns": pa.array([datetime.datetime(1970, 1, 1, 0, 0, 2), datetime.datetime(2001, 9, 9, 1, 46, 40)], pa.timestamp("ns"))}),
        use_deprecated_int96_timestamps=True,
        compression="none",
    )

    # Nested columns (not supported) next to flat ones.
    nested = pa.table(
        {
            "id": pa.array([1, 2, 3], pa.int64()),
            "tags": pa.array([["a"], [], ["b", "c"]], pa.list_(pa.string())),
            "point": pa.array([{"x": 1, "y": 2}, {"x": 3, "y": 4}, None], pa.struct([("x", pa.int64()), ("y", pa.int64())])),
            "label": pa.array(["one", "two", "three"], pa.string()),
        }
    )
    write("nested.parquet", nested, compression="snappy")


if __name__ == "__main__":
    main()
