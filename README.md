# CSV2Avro

Convert CSV files to Avro like a boss.

## Installation

    $ gem install csv2avro

or if you prefer to live on the edge, just clone this repository and build it from scratch.

## Usage

### Basic
```
$ csv2avro --schema ./spec/support/schema.avsc ./spec/support/data.csv
```
This will process the data.csv file and creates a *data.avro* file and a *data.bad.csv* file with the bad rows.

You can override the bad-rows file location with the `--bad-rows [BAD_ROWS]` option.

### Streaming
```
$ cat ./spec/support/data.csv | csv2avro --schema ./spec/support/schema.avsc --bad-rows ./spec/support/data.bad.csv > ./spec/support/data.avro
```
This will process the *input stream* and push the avro data to the *output stream*. If you're working with streams you will need to specify the `--bad-rows` location.

### Advanced features

#### AWS S3 storage

```
aws s3 cp s3://csv-bucket/transactions.csv - | csv2avro --schema ./transactions.avsc --bad-rows ./transactions.bad.csv | aws s3 cp - s3://avro-bucket/transactions.avro
```

This will stream your file stored in AWS S3, converts the data and pushes it back to S3. For more information, please check the [AWS CLI documentation](http://docs.aws.amazon.com/cli/latest/reference/s3/index.html).

#### Convert compressed files

```
gunzip -c ./spec/support/data.csv.gz | csv2avro --schema ./spec/support/schema.avsc --bad-rows ./spec/support/data.bad.csv > ./spec/support/data.avro
```

This will uncompress the file and converts it to avro, leaving the original file intact.

### More

For a full list of available options, run `csv2avro --help`
```
$ csv2avro --help
Version 1.0.0 of CSV2Avro
Usage: csv2avro [options] [file]
    -s, --schema SCHEMA              A file containing the Avro schema. This value is required.
    -b, --bad-rows [BAD_ROWS]        The output location of the bad rows file.
    -d, --delimiter [DELIMITER]      Field delimiter. If none specified, then comma is used as the delimiter.
    -a [ARRAY_DELIMITER],            Array field delimiter. If none specified, then comma is used as the delimiter.
        --array-delimiter
    -D, --write-defaults             Write default values.
    -c, --stdout                     Output will go to the standard output stream, leaving files intact.
    -h, --help                       Prints help
```

## Contributing

1. Fork it ( https://github.com/sspinc/csv2avro/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
