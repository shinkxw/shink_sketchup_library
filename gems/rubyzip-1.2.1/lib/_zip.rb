require 'delegate'
require 'singleton'
require 'tempfile'
require 'tmpdir'
require 'fileutils'
require 'stringio'
require 'zlib'
require '_zip/dos_time'
require '_zip/ioextras'
require 'rbconfig'
require '_zip/entry'
require '_zip/extra_field'
require '_zip/entry_set'
require '_zip/central_directory'
require '_zip/file'
require '_zip/input_stream'
require '_zip/output_stream'
require '_zip/decompressor'
require '_zip/compressor'
require '_zip/null_decompressor'
require '_zip/null_compressor'
require '_zip/null_input_stream'
require '_zip/pass_thru_compressor'
require '_zip/pass_thru_decompressor'
require '_zip/crypto/encryption'
require '_zip/crypto/null_encryption'
require '_zip/crypto/traditional_encryption'
require '_zip/inflater'
require '_zip/deflater'
require '_zip/streamable_stream'
require '_zip/streamable_directory'
require '_zip/constants'
require '_zip/errors'

module Zip
  extend self
  attr_accessor :unicode_names, :on_exists_proc, :continue_on_exists_proc, :sort_entries, :default_compression, :write_zip64_support, :warn_invalid_date, :case_insensitive_match

  def reset!
    @_ran_once = false
    @unicode_names = false
    @on_exists_proc = false
    @continue_on_exists_proc = false
    @sort_entries = false
    @default_compression = ::Zlib::DEFAULT_COMPRESSION
    @write_zip64_support = false
    @warn_invalid_date = true
    @case_insensitive_match = false
  end

  def setup
    yield self unless @_ran_once
    @_ran_once = true
  end

  reset!
end

# Copyright (C) 2002, 2003 Thomas Sondergaard
# rubyzip is free software; you can redistribute it and/or
# modify it under the terms of the ruby license.
