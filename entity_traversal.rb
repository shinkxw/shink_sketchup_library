module SHINK_LIBRARY
  class EntityTraversal
    def self.component_tree;RootNode.new.to_tree end
    def self.all;new(Sketchup.active_model.entities) end

    include Enumerable
    def initialize(entities)
      @entities = case entities
                  when Sketchup::Entities, Array then entities
                  else [entities]
                  end
    end

    def each
      current_entitys = @entities
      while current_entitys.length > 0
        next_entitys = []
        current_entitys.each do |entity|
          yield entity
          entity.definition.entities.each{|e| next_entitys << e} if can_traversal?(entity)
        end
        current_entitys = next_entitys
      end
    end

    def each_object
      Enumerator.new do |result|
        current_entitys = @entities
        while current_entitys.length > 0
          next_entitys = []
          current_entitys.find_all{|e| can_traversal?(e)}.each do |entity|
            result << entity
            entity.definition.entities.each{|e| next_entitys << e}
          end
          current_entitys = next_entitys
        end
      end
    end

    def can_traversal?(entity)
      entity.is_a?(Sketchup::ComponentInstance) || entity.is_a?(Sketchup::Group)
    end

    class TreeNode
      attr_accessor :entity
      def self.new_by_guid(guid)
        entity = Sketchup.active_model.find_entity_by_id(guid)
        entity ? get_node(entity) : nil
      end
      def self.get_node(entity)
        case entity
        when Sketchup::ComponentInstance
          ComponentInstanceNode.new(entity)
        when Sketchup::Group
          GroupNode.new(entity)
        end
      end

      include Enumerable
      def initialize(entity);@entity = entity end
      def children;@children ||= init_children end
      def init_children;entities.map{|entity| self.class.get_node(entity)}.compact end
      def name;@name ||= get_name end
      def each(&block)
        children.each do |child|
          yield child
          child.each(&block)
        end
      end
      def to_tree
        hash = {name: name, id: @entity.entityID}
        if children.empty?
          hash[:leaf] = true
        else
          hash[:children] = children.map{|child| child.to_tree}
        end
        hash
      end
    end

    class RootNode < TreeNode
      def initialize;super(Sketchup.active_model) end
      def entities;@entity.entities end
      def get_name
        title = @entity.title
        title == '' ? '无标题' : title
      end
    end

    class ComponentInstanceNode < TreeNode
      def entities;@entity.definition.entities end
      def get_name
        entity_name = @entity.name
        if entity_name == ''
          @entity.definition.name
        else
          "#{entity_name} <#{@entity.definition.name}>"
        end
      end
    end

    class GroupNode < TreeNode
      def entities;@entity.definition.entities end
      def get_name
        entity_name = @entity.name
        entity_name == '' ? '组' : entity_name
      end
    end
  end
end
