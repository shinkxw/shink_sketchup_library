# -*- encoding: utf-8 -*-

module Writexlsx
  class Worksheet
    class DataValidation   # :nodoc:
      include Writexlsx::Utility

      attr_reader :value, :source, :minimum, :maximum, :validate, :criteria
      attr_reader :error_type, :cells, :other_cells
      attr_reader :ignore_blank, :dropdown, :show_input, :show_error
      attr_reader :error_title, :error_message, :input_title, :input_message

      def initialize(*args)
        # Check for a cell reference in A1 notation and substitute row and column.
        row1, col1, row2, col2, options = row_col_notation(args)
        if row2.respond_to?(:keys)
          options_to_instance_variable(row2.dup)
          row2, col2 = row1, col1
        elsif options.respond_to?(:keys)
          options_to_instance_variable(options.dup)
        else
          raise WriteXLSXInsufficientArgumentError
        end
        raise WriteXLSXInsufficientArgumentError if [row1, col1, row2, col2].include?(nil)
        check_for_valid_input_params

        check_dimensions(row1, col1)
        check_dimensions(row2, col2)
        @cells = [[row1, col1, row2, col2]]

        @value = @source  if @source
        @value = @minimum if @minimum

        @validate = valid_validation_type[@validate.downcase]
        if @validate == 'none'
          @validate_none = true
          return
        end
        if ['list', 'custom'].include?(@validate)
          @criteria  = 'between'
          @maximum   = nil
        end

        check_criteria_required
        check_valid_citeria_types
        @criteria = valid_criteria_type[@criteria.downcase]

        check_maximum_value_when_criteria_is_between_or_notbetween
        @error_type = has_key?(:error_type) ? error_type_hash[@error_type.downcase] : 0

        convert_date_time_value_if_required
        # Check that the input title doesn't exceed the maximum length.
        if @input_title && @input_title.length > 32
          raise "Length of input title '#{@input_title}' exceeds Excel's limit of 32"
        end
        # Check that the input message doesn't exceed the maximum length.
        if @input_message && @input_message.length > 255
          raise "Length of input message '#{@input_message}' exceeds Excel's limit of 255"
        end
        set_some_defaults

      # A (for now) undocumented parameter to pass additional cell ranges.
        @other_cells.each { |cells| @cells << cells } if has_key?(:other_cells)
      end

      def options_to_instance_variable(params)
        params.each do |k, v|
          instance_variable_set("@#{k}", v)
        end
      end

      def keys
        self.instance_variables.collect { |v| v.to_s.sub(/@/, '').to_sym }
      end

      def validate_none?
        @validate_none
      end

      #
      # Write the <dataValidation> element.
      #
      def write_data_validation(writer) #:nodoc:
        @writer = writer
        @writer.tag_elements('dataValidation', attributes) do
          # Write the formula1 element.
          write_formula_1(@value)
          # Write the formula2 element.
          write_formula_2(@maximum) if @maximum
        end
      end

      private

      #
      # Write the <formula1> element.
      #
      def write_formula_1(formula) #:nodoc:
        # Convert a list array ref into a comma separated string.
        formula   = %!"#{formula.join(',')}"! if formula.kind_of?(Array)

        formula = formula.sub(/^=/, '') if formula.respond_to?(:sub)

        @writer.data_element('formula1', formula)
      end

      #
      # Write the <formula2> element.
      #
      def write_formula_2(formula) #:nodoc:
        formula = formula.sub(/^=/, '') if formula.respond_to?(:sub)

        @writer.data_element('formula2', formula)
      end

      def attributes
        sqref      = ''
        attributes = []

        # Set the cell range(s) for the data validation.
        @cells.each do |cells|
          # Add a space between multiple cell ranges.
          sqref += ' ' if sqref != ''

          row_first, col_first, row_last, col_last = cells

          # Swap last row/col for first row/col as necessary
          row_first, row_last = row_last, row_first if row_first > row_last
          col_first, col_last = col_last, col_first if col_first > col_last

          # If the first and last cell are the same write a single cell.
          if row_first == row_last && col_first == col_last
            sqref += xl_rowcol_to_cell(row_first, col_first)
          else
            sqref += xl_range(row_first, row_last, col_first, col_last)
          end
        end

        attributes << ['type', @validate]
        attributes << ['operator', @criteria] if @criteria != 'between'

        if @error_type
          attributes << ['errorStyle', 'warning'] if @error_type == 1
          attributes << ['errorStyle', 'information'] if @error_type == 2
        end
        attributes << ['allowBlank',       1] if @ignore_blank != 0
        attributes << ['showDropDown',     1] if @dropdown     == 0
        attributes << ['showInputMessage', 1] if @show_input   != 0
        attributes << ['showErrorMessage', 1] if @show_error   != 0

        attributes << ['errorTitle',  @error_title]   if @error_title
        attributes << ['error',       @error_message] if @error_message
        attributes << ['promptTitle', @input_title]   if @input_title
        attributes << ['prompt',      @input_message] if @input_message
        attributes << ['sqref',       sqref]
      end

      def has_key?(key)
        keys.index(key)
      end

      def set_some_defaults
        @ignore_blank ||= 1
        @dropdown     ||= 1
        @show_input   ||= 1
        @show_error   ||= 1
      end

      def check_for_valid_input_params
        check_parameter(self, valid_validation_parameter, 'data_validation')

        unless has_key?(:validate)
          raise WriteXLSXOptionParameterError, "Parameter :validate is required in data_validation()"
        end
        unless valid_validation_type.has_key?(@validate.downcase)
          raise WriteXLSXOptionParameterError,
          "Unknown validation type '#{@validate}' for parameter :validate in data_validation()"
        end
        if @error_type && !error_type_hash.has_key?(@error_type.downcase)
          raise WriteXLSXOptionParameterError,
          "Unknown criteria type '#param[:error_type}' for parameter :error_type in data_validation()"
        end
      end

      def check_criteria_required
        unless has_key?(:criteria)
          raise WriteXLSXOptionParameterError, "Parameter :criteria is required in data_validation()"
        end
      end

      def check_maximum_value_when_criteria_is_between_or_notbetween
        if @criteria == 'between' || @criteria == 'notBetween'
          unless has_key?(:maximum)
            raise WriteXLSXOptionParameterError,
            "Parameter :maximum is required in data_validation() when using :between or :not between criteria"
          end
        else
          @maximum = nil
        end
      end

      def check_valid_citeria_types
        unless valid_criteria_type.has_key?(@criteria.downcase)
          raise WriteXLSXOptionParameterError,
          "Unknown criteria type '#{@criteria}' for parameter :criteria in data_validation()"
        end
      end

      def convert_date_time_value_if_required
        @date_1904 = date_1904?
        if @validate == 'date' || @validate == 'time'
          unless convert_date_time_value(:value) && convert_date_time_value(:maximum)
            raise WriteXLSXOptionParameterError, "Invalid date/time value."
          end
        end
      end

      def error_type_hash
        {'stop' => 0, 'warning' => 1, 'information' => 2}
      end

      def valid_validation_type # :nodoc:
        {
          'any'             => 'none',
          'any value'       => 'none',
          'whole number'    => 'whole',
          'whole'           => 'whole',
          'integer'         => 'whole',
          'decimal'         => 'decimal',
          'list'            => 'list',
          'date'            => 'date',
          'time'            => 'time',
          'text length'     => 'textLength',
          'length'          => 'textLength',
          'custom'          => 'custom'
        }
      end

      # List of valid input parameters.
      def valid_validation_parameter
        [
         :validate,
         :criteria,
         :value,
         :source,
         :minimum,
         :maximum,
         :ignore_blank,
         :dropdown,
         :show_input,
         :input_title,
         :input_message,
         :show_error,
         :error_title,
         :error_message,
         :error_type,
         :other_cells
        ]
      end

      # List of valid criteria types.
      def valid_criteria_type  # :nodoc:
        {
          'between'                     => 'between',
          'not between'                 => 'notBetween',
          'equal to'                    => 'equal',
          '='                           => 'equal',
          '=='                          => 'equal',
          'not equal to'                => 'notEqual',
          '!='                          => 'notEqual',
          '<>'                          => 'notEqual',
          'greater than'                => 'greaterThan',
          '>'                           => 'greaterThan',
          'less than'                   => 'lessThan',
          '<'                           => 'lessThan',
          'greater than or equal to'    => 'greaterThanOrEqual',
          '>='                          => 'greaterThanOrEqual',
          'less than or equal to'       => 'lessThanOrEqual',
          '<='                          => 'lessThanOrEqual'
        }
      end

      def convert_date_time_value(key)  # :nodoc:
        value = instance_variable_get("@#{key}")
        if value && value =~ /T/
          date_time = convert_date_time(value)
          instance_variable_set("@#{key}", date_time) if date_time
          date_time
        else
          true
        end
      end

      def date_1904?
        @date_1904
      end
    end
  end
end
