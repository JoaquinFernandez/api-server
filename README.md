api-server
========

Based on project [rest-api](https://github.com/CodyStringham/rest-api).

Welcome to my API homework app. Built upon this amazing [RESTful API blog post](https://codelation.com/blog/rails-restful-api-just-add-water). This API is versioned and set up with json:api standards using rabl.

What's inside of the app
--------
####Models
```ruby
Site :url, :total_lines, :inline, :external
```

####Views
`views/api/v1/sites` contain a index and show

####Controllers
`controllers/api/v1/base_controller` contains the most logic, see private method comments. These will set and get the resource names as needed for each controller.

####Kaminari Pagination
Kaminari has a default page size of 25, to override this pass in a `page` and/or a `page_size` paramater like the following:
```
http://api.rest-api.dev/v1/sites.json?page=1&page_size=10
```

Lets make a call!
--------
#### HTTParty Get
```ruby
HTTParty.get 'http://api.rest-api.dev/api/v1/sites'
```
