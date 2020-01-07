module SHINK_LIBRARY
  module EntityUID
    module_function

    @uid_entity_hash = {}

    def get_entity_uid_by_entity_id(entity_id)
      entity = Sketchup.active_model.find_entity_by_id(entity_id.to_i)
      raise "entity_id为#{entity_id}的实体未找到" if entity.nil?
      get_entity_uid(entity)
    end

    def get_entity_uid(entity)
      uid = entity.get_attribute("SHINK_LIBRARY", "uid")
      if uid.nil?
        entity_type = entity.class.name.split('::')[-1]
        uid = "#{entity_type}-#{UID.generate}"
        SuEntityAttribute.add_set(entity, "SHINK_LIBRARY", "uid", uid)
        @uid_entity_hash[uid] = entity
      end
      return uid
    end

    def get_entity_by_uid(uid)
      entity = @uid_entity_hash[uid]
      return entity if entity && !entity.deleted?#缓存
      entity = find_entity_by_uid(uid)
      @uid_entity_hash[uid] = entity
      return entity
    end

    def find_entity_by_uid(uid)
      type = uid.split('-')[0]
      case type
      when 'ComponentInstance', 'Group'
        EntityTraversal.all.each_object.find{|e| e.get_attribute("SHINK_LIBRARY", "uid") == uid}
      when 'ComponentDefinition'
        Sketchup.active_model.definitions.find{|e| e.get_attribute("SHINK_LIBRARY", "uid") == uid}
      when 'Material'
        Sketchup.active_model.materials.find{|e| e.get_attribute("SHINK_LIBRARY", "uid") == uid}
      else
        raise "未定义的查找类型: #{type}"
      end
    end
  end
end
