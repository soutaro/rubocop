# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of *and* and *or* without control flow operators.
      class NonControlAndOr < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Use `%s` instead of `%s`.'.freeze

        OPS = { 'and' => '&&', 'or' => '||' }.freeze

        VALUE_NODE_TYPES = Set.new([:int, :true, :false, :nil, :self, :string, :float]).freeze

        def on_and(node)
          process_logical_op(node)
        end

        def on_or(node)
          process_logical_op(node)
        end

        private

        def process_logical_op(node)
          unless valid_rhs?(node.children.last)
            add_offense(node, :operator, format(MSG, OPS[node.type.to_s], node.type))
          end
        end

        def style
          :permissive
        end

        def valid_rhs?(node)
          return true if style == :conservative && control_flow_operator_node?(node)
          return true if style == :permissive && control_flow_operator_node?(node) || !value_node?(node)
          false
        end

        def control_flow_operator_node?(node)
          node.type == :break || node.type == :return || node.type == :retry || node.type == :next
        end

        def value_node?(node)
          case node.type
          when :array
            node.children.all? { |child| value_node?(child) }
          else
            VALUE_NODE_TYPES.member?(node.type)
          end
        end

        # def autocorrect(node)
        #   expr1, expr2 = *node
        #   replacement = (node.and_type? ? '&&' : '||')
        #   lambda do |corrector|
        #     [expr1, expr2].each do |expr|
        #       if expr.send_type?
        #         correct_send(expr, corrector)
        #       elsif expr.return_type?
        #         correct_other(expr, corrector)
        #       elsif expr.assignment?
        #         correct_other(expr, corrector)
        #       end
        #     end
        #     corrector.replace(node.loc.operator, replacement)
        #   end
        # end

        # def correct_send(node, corrector)
        #   receiver, method_name, *args = *node
        #   return correct_not(node, receiver, corrector) if method_name == :!
        #   return correct_setter(node, corrector) if setter_method?(method_name)
        #   return unless correctable_send?(node)

        #   corrector.replace(whitespace_before_arg(node), '('.freeze)
        #   corrector.insert_after(args.last.source_range, ')'.freeze)
        # end

        # def correct_setter(node, corrector)
        #   receiver, _method_name, *args = *node
        #   corrector.insert_before(receiver.source_range, '('.freeze)
        #   corrector.insert_after(args.last.source_range, ')'.freeze)
        # end

        # # ! is a special case:
        # # 'x and !obj.method arg' can be auto-corrected if we
        # # recurse down a level and add parens to 'obj.method arg'
        # # however, 'not x' also parses as (send x :!)
        # def correct_not(node, receiver, corrector)
        #   if node.loc.selector.source == '!'
        #     return unless receiver.send_type?

        #     correct_send(receiver, corrector)
        #   elsif node.keyword_not?
        #     correct_other(node, corrector)
        #   else
        #     raise 'unrecognized unary negation operator'
        #   end
        # end

        # def correct_other(node, corrector)
        #   return unless node.source_range.begin.source != '('
        #   corrector.insert_before(node.source_range, '(')
        #   corrector.insert_after(node.source_range, ')')
        # end

        # def setter_method?(method_name)
        #   method_name.to_s.end_with?('=')
        # end

        # def correctable_send?(node)
        #   _receiver, method_name, *args = *node
        #   # don't clobber if we already have a starting paren
        #   return false unless !node.loc.begin || node.loc.begin.source != '('
        #   # don't touch anything unless we are sure it is a method call.
        #   return false unless args.last && method_name.to_s =~ /[a-z]/

        #   true
        # end

        # def whitespace_before_arg(node)
        #   begin_paren = node.loc.selector.end_pos
        #   end_paren = begin_paren
        #   # Increment position of parenthesis, unless message is a predicate
        #   # method followed by a non-whitespace char (e.g. is_a?String).
        #   end_paren += 1 unless node.source =~ /\?\S/
        #   range_between(begin_paren, end_paren)
        # end
      end
    end
  end
end
