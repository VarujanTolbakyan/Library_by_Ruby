require 'active_support/inflector'
require 'json'

class Base
  class << self
    attr_accessor :class_xyz

    def inherited(child)
      unless File.exist?(child.db_dir)
        Dir.mkdir(child.db_dir)
        File.open(child.id_increment, 'w') do |file|
          file.write('0')
        end
      end
    end

    def attribute(name, type = nil)
      #attr_reader name
      define_method(name) do 
       instance_variable_get "@#{name}"
      end
      #difine attribut writer
      define_method("#{name}=") do |value| 
        if type.nil? || value.class == type
         instance_variable_set("@#{name}", value)
        else
          raise TypeError, "expected instance of #{type} but given #{value}:#{value.class}"
        end
      end 
    end

    def belongs_to(relation_name)
      define_method(relation_name) do 
        relation_class = Object.const_get(relation_name.capitalize)
        relation_class.find_by_id(send("#{relation_name}_id"))
      end
    end

    def has_many(relation_name)
      define_method(relation_name) do
        relation_class = Object.const_get(relation_name.to_s.singularize.capitalize)
        relation_class.where("#{self.class.name.downcase}_id" => id)
      end
    end

    def find_by_id(id)
      if File.exist? file_name id
        build_from_file file_name id
      else
        nil
      end
    end

    def db_dir
      "./db/#{self.name.downcase.pluralize}"
    end

    def id_increment
      "#{db_dir}/id_increment.txt"
    end

    def new_id
      id = File.read(id_increment).to_i + 1
      File.write(id_increment, id)
      id
    end

    def file_name(id)
      "#{db_dir}/#{id}.json"
    end

    def all
      all_obj = []
      Dir.glob(file_name('*')).each do |file|
        all_obj << build_from_file(file)
     end
      all_obj
    end

    def create(attributes)
      obj = new
      obj.set_filds(attributes)
      obj.save
      obj
    end
    
    def where(conditions)
      conditioned_objs = []
      all.each do |obj|
        check = true
        conditions.each_pair do |prop_name, value|
          unless obj.send(prop_name) == value
            check = false
            break
          end
        end
        conditioned_objs << obj if check
      end
      conditioned_objs
    end

    def build_from_file(path)
      json_data = File.read path
      hash_data = JSON.parse json_data
      new.set_filds(hash_data)
    end
  end

  attribute :id, Integer

  def to_hash
    hash = {}
    instance_variables.each do |prop_name|
      key = prop_name.to_s.delete '@' 
      hash[key] = instance_variable_get prop_name
    end
    hash
  end

  def to_json
    to_hash.to_json
  end

  def save
    id_initialize if id.nil?
    File.write(file_name, to_json)
  end

  def delete
    File.delete(file_name)
  end

  def file_name
    self.class.file_name(id)
  end

  def id_initialize
    self.id = self.class.new_id
  end

  def update(attributes)
    set_filds(attributes)
    save
  end

  def set_filds(filds_hash)
    filds_hash.each_pair do |fild_name, value|
      if respond_to? "#{fild_name}="
        send("#{fild_name}=", value)
      end
    end
    self
  end
end
