### Version Changelog
1.1.0 Updated to use [Paint v. 2.0](https://github.com/janlelis/paint) gem.

1.0.1 Fixes issue [#33](https://github.com/thoom/restclient/issues/33).

1.0.0 RestClient => RestUp. _Finally_ out of beta.
 - Fixes Github issue [#30](https://github.com/thoom/restclient/issues/30) by renaming RestClient to RestUp.
 - Fixes Github issue [#28](https://github.com/thoom/restclient/issues/28). `--form` converts JSON to form data only. 
   To use form data, manually set the header using the `-h` option or set the header in the configuration.
 - Fixes Github issues [#24](https://github.com/thoom/restclient/issues/24) and [#25](https://github.com/thoom/restclient/issues/25). Use `--verbose` or set `flags: { display: verbose }` in config.
 - Fixes Github issue [#31](https://github.com/thoom/restclient/issues/31). Use `-c` or `--config` to pass in another config file.
 - Fixes Github issue [#20](https://github.com/thoom/restclient/issues/20).
 - Fixes Github issue [#11](https://github.com/thoom/restclient/issues/11).


0.14.3 Fixes Github issues [#21](https://github.com/thoom/restclient/issues/21) and [#26](https://github.com/thoom/restclient/issues/26). 
You can use YAML now instead of JSON for JSON requests. Since JSON is a subset of YAML, this is not a breaking change.

0.14.2 Fixes Github issue [#17](https://github.com/thoom/restclient/issues/17). It also simplifies how files or data are passed into the client.
Breaking change because flags -f and -d have been removed. Instead just pass in with STDIN instead.

0.13.0 Fixes Github issue [#13](https://github.com/thoom/restclient/issues/13). 
Breaking change since it no longer creates a config file if one doesn't exist.

0.12.1: Fixes Github issues [#12](https://github.com/thoom/restclient/issues/12) and [#19](https://github.com/thoom/restclient/issues/19). 
If using the library class instead of the CLI, you can pass in a `Thoom::HashConfig` object,
instead of requiring a YAML file. CLI no longer generates a deprecated warning in the Ruby 2.3.

0.11.3: Adds a simple response time to the output.

0.11.2: Fixes Github issue [#10](https://github.com/thoom/restclient/issues/10).

0.11.1: Fixes Github issues [#2](https://github.com/thoom/restclient/issues/2), [#5](https://github.com/thoom/restclient/issues/5), [#6](https://github.com/thoom/restclient/issues/6), [#7](https://github.com/thoom/restclient/issues/7), and [#8](https://github.com/thoom/restclient/issues/8). If a configuration file is not found,
there is now a simple wizard that will ask a few questions and then generate the config file.

0.10.1: Fixes Github issues [#1](https://github.com/thoom/restclient/issues/1) and [#4](https://github.com/thoom/restclient/issues/4). `PUT`, `PATCH`, and `POST` all set a default `JSON` content type. Added `--response-only` flag.

0.10.0: Fixed a bug missed where headers in the YAML file were not parsed. Changed the YAML :headers: to use a hash instead of array.

0.9.3: Rewrote console output mechanism. Fixed a few bugs related to YAML configuration. Added `--response-code-only` and `--success-only` flags.

0.9.0: Significant internal refactoring to the client. Also changed console coloring dependency to the `Paint` gem instead of `Colored` gem.

0.8.5: Added option to save response to the filename in the content-disposition if that header is passed.

0.8.4: Added option to save response to a file by passing in the -o {file} arg. For binary files, response is never output in summary.

0.7.5: Added option to change the request timeout. Added option to disable TLS cert validation (Useful with self-signed certs).

0.7.0: Removed dependency on Nokogiri for XML parsing.
