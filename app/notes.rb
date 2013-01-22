module Notes

  FIND_DEFAULT = {
    :limit => 10,
    :offset => 0,
  }

  def self.api_users
    Auth.applications.values.collect{|a| a.name}
  end

  def self.fix_user_name name
    name.gsub(/\.|@|\s/,"_")
  end

  def self.taxonomies
    @taxonomies ||= []
  end

  def self.taxonomies= taxonomies
    @taxonomies = taxonomies
  end

end