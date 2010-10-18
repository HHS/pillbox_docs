require 'yaml'
Pill

Practice
for key, obj in YAML.load_file('db/seeds/practices.yml')
  Practice.create(obj)
end

Pill
for obj in YAML.load_file('db/seeds/pills.yml')
  begin
    Pill.create(obj.attributes)
  rescue => e
    puts obj.name
  end
#  Pill.create(p.merge(:accepted_names=>([p[:accepted_names]].flatten - [nil]), :messages=>([p[:messages]].flatten) - [nil]))
end

PillCategory
for key, obj in YAML.load_file('db/seeds/pill_categories.yml')
  PillCategory.create(obj)
end

=begin
for pill_category_with_ivars in pill_categories = YAML.load_file('lib/pill_categories.yml')
  pill_category_hash = pill_category_with_ivars.ivars
  pills_hash_array = pill_category_hash.delete('pills')
  pill_category = PillCategory.create(pill_category_hash)
  for pills_hash in pills_hash_array
    p = Pill.create(pills_hash.merge(:pill_category=>pill_category))

  end
end
=end

