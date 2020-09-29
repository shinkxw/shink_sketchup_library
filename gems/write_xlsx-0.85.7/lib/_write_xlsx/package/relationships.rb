# -*- coding: utf-8 -*-
require '_write_xlsx/package/xml_writer_simple'
require '_write_xlsx/utility'

module Writexlsx
  module Package
    class Relationships

      include Writexlsx::Utility

      Schema_root     = 'http://schemas.openxmlformats.org'
      Package_schema  = Schema_root + '/package/2006/relationships'
      Document_schema = Schema_root + '/officeDocument/2006/relationships'

      def initialize
        @writer = Package::XMLWriterSimple.new
        @rels   = []
        @id     = 1
      end

      def set_xml_writer(filename)
        @writer.set_xml_writer(filename)
      end

      def assemble_xml_file
        write_xml_declaration do
          write_relationships
        end
      end

      #
      # Add container relationship to XLSX .rels xml files.
      #
      def add_document_relationship(type, target)
        @rels.push([Document_schema + type, target])
      end

      #
      # Add container relationship to XLSX .rels xml files.
      #
      def add_package_relationship(type, target)
        @rels.push([Package_schema + type, target])
      end

      #
      # Add container relationship to XLSX .rels xml files. Uses MS schema.
      #
      def add_ms_package_relationship(type, target)
        schema = 'http://schemas.microsoft.com/office/2006/relationships'
        @rels.push([schema + type, target])
      end

      #
      # Add worksheet relationship to sheet.rels xml files.
      #
      def add_worksheet_relationship(type, target, target_mode = nil)
        @rels.push([Document_schema + type, target, target_mode])
      end

      private

      #
      # Write the <Relationships> element.
      #
      def write_relationships
        attributes = [
                      ['xmlns', Package_schema]
                     ]

        @writer.tag_elements('Relationships', attributes) do
          @rels.each { |rel| write_relationship(*rel) }
        end
      end

      #
      # Write the <Relationship> element.
      #
      def write_relationship(type, target, target_mode = nil)
        attributes = [
          ['Id',     "rId#{@id}"],
          ['Type',   type],
          ['Target', target]
        ]
        @id += 1

        attributes << ['TargetMode', target_mode] if target_mode

        @writer.empty_tag('Relationship', attributes)
      end
    end
  end
end
