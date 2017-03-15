require "lib/tag_cloud"

module BlogHelpers

   def get_blog_author(email)

       allAuthors = data.authors

       allAuthors.each do |author|
           if
               author.imagename = "authorimages/" + email.gsub(/\W/, '') + ".png"
               return author if author.email == email
           end
       end

       return nil
   end

   def tag_cloud(options = {})
       [].tap do |html|
           TagCloud.new(options).render(blog.tags) do |tag, size, unit|
               html << link_to(tag, tag_path(tag), style: "font-size: #{size}#{unit}")
           end
       end.join(" ")
   end

   def raise_error(message)
       puts message.red
       raise message
   end

   def lint_page(current_page)

       #check page for required properties
       [:title, :date, :tags, :author].each do |property|
           raise_error("Blog page '#{current_page.metadata[:page][:title]}' is missing property #{property}.  See 'Required Properties' section of the README") if current_page.metadata[:page][property] == nil
       end

       #validate author config
       author_email = current_page.metadata[:page][:author]

       #validate email address
       raise_error("Author email address is in an incorrect format" ) unless author_email =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

       author_data = get_blog_author author_email

       raise_error("Author data not found in data/authors.yml" ) if author_data == nil

       [:email, :name, :bio].each do |property|
           raise_error("Author profile is missing property #{property}.  See 'Author Bios' section of the README") if author_data[property] == nil
       end

       raise_error("Author image '#{author_data.imagename}' not found in source/authors" ) unless File.exists?(File.join(File.dirname(__FILE__), "..", 'source/', author_data.imagename))

       return

   end
end
