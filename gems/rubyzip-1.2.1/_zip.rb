require 'delegate'
require 'singleton'
require 'tempfile'
require 'tmpdir'
require 'fileutils'
require 'stringio'
require 'zlib'
require 'rbconfig'

dir = "#{File.dirname(__FILE__)}/_zip"
Sketchup::require "#{dir}/dos_time"
Sketchup::require "#{dir}/ioextras"
Sketchup::require "#{dir}/ioextras/abstract_input_stream"
Sketchup::require "#{dir}/ioextras/abstract_output_stream"
Sketchup::require "#{dir}/entry"
Sketchup::require "#{dir}/extra_field"
Sketchup::require "#{dir}/extra_field/generic"
Sketchup::require "#{dir}/extra_field/universal_time"
Sketchup::require "#{dir}/extra_field/old_unix"
Sketchup::require "#{dir}/extra_field/unix"
Sketchup::require "#{dir}/extra_field/zip64"
Sketchup::require "#{dir}/extra_field/zip64_placeholder"
Sketchup::require "#{dir}/extra_field/ntfs"
Sketchup::require "#{dir}/entry_set"
Sketchup::require "#{dir}/central_directory"
Sketchup::require "#{dir}/file"
Sketchup::require "#{dir}/input_stream"
Sketchup::require "#{dir}/output_stream"
Sketchup::require "#{dir}/decompressor"
Sketchup::require "#{dir}/compressor"
Sketchup::require "#{dir}/null_decompressor"
Sketchup::require "#{dir}/null_compressor"
Sketchup::require "#{dir}/null_input_stream"
Sketchup::require "#{dir}/pass_thru_compressor"
Sketchup::require "#{dir}/pass_thru_decompressor"
Sketchup::require "#{dir}/crypto/encryption"
Sketchup::require "#{dir}/crypto/null_encryption"
Sketchup::require "#{dir}/crypto/traditional_encryption"
Sketchup::require "#{dir}/inflater"
Sketchup::require "#{dir}/deflater"
Sketchup::require "#{dir}/streamable_stream"
Sketchup::require "#{dir}/streamable_directory"
Sketchup::require "#{dir}/constants"
Sketchup::require "#{dir}/errors"

module Shink::BaseLibrary::Zip
  Zip = self
  VERSION = '1.2.1'
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
