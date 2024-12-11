## How to run

#### dev

```
bundle i
rake db:setup
rails s
```

Doc & play with endpoint: `http://0.0.0.0:3000/api-doc`  
Endpoint itself: `http://0.0.0.0:3000/users/1/cars`

#### run tests

```
RAILS_ENV=test rake db:seed
rspec
```

#### To play with one million records

Uncomment part of code in `db/seeds.rb` at line 17 and run `RAILS_ENV=development rake db:reset`

## Solution description

I decided to go with minimum deps for this task and do all the stuff in DB: merging data, sorting, filtering.  
There are pros and cons, I think we will discuss em during the interview.

### Details

* `app/users/cars_controller.rb` - main controller, it returns cars for the given user;
* `app/queries/user_cars.rb`- UserCars query where all the *magic* 🪄 happens actually;
* `app/services/recommendation_ai.rb` - simple wrapper service for external call;

##### UserCars query object

Query encapsulates all the search logic:

- takes AI recommendations;
- builds subquery for labels and scores;
- filters and sorts final data.

##### RecommendationAI service

- caches results to avoid multiple calls for the same user;
- fails with short timeout (no long waits);

### Tests

I used RSpec to:

- check if API response data matches the desired one;
- Rswag for API documentation and schema validation;  
