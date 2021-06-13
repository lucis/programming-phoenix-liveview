# Test Your Live Views

## Learning Goals
* Readers will learn how to use the reducer pattern to write clean, functional unit tests for their clean, functional code.
* Readers will learn how to use the LiveViewTest module to robustly test a wide variety of LiveView functionality and behaviors, without reaching for JavaScript.

## Outline
* What We'll Test
* Unit test LiveView with reducer pipelines
* LiveView Testing Filtering Behavior
* LiveView Testing Real-Time Updates with Message Passing


By now, you've seen pretty much everything LiveView has to offer---you've used generators to build and customize a full-fledged CRUD feature set, explore how LiveView supports forms, used components to compose complex software out of simple building blocks and even extended the functionality of your live view with Phoenix PubSub for real-time updates in your distributed system. Before we move on to the final part of this journey in which you'll revisit and master these concepts to build the Pentominoes game, there's one more LiveView took you'll need to add to your kit---testing.

You'll find that testing LiveView is easy for two reasons---the reducer pipelines we built into our live views lend themselves nicely to robust unit testing, and the browser-less LiveViewTest module provides us with a set of convenience functions that allows us to fully exercise the functionality of our live views without fancy JavaScript testing frameworks.

All of our tests will be written in ExUnit, Elixir's unit testing framework, with the inclusion of the LiveViewTest module that we will import into our ExUnit tests. With ExUnit and the LiveViewTest module, you keep your tests firmly in Elixir land. This means your LiveView tests are fast, concurrent and unlikely to be flaky, which differs markedly from the experience of work with headless browser testing tools. LiveViewTest is just one more way that LiveView developers are empowered to be highly productive when building single-page apps.

In this chapter, we'll write some tests for functionality related to the survey results portion of the admin dashboard page. We'll start with unit tests that focus on the state management behavior of the `SurveyResultsLive`'s reducer pipeline. Then, we'll move on to leveraging specific LiveViewTest functions to exercise the survey results chart's filtering and real-time updating behaviors.

This will be a short chapter, but when we're done you'll have everything you need to ensure your live views are fully tested.

## Unit Test Your Reducers

In this chapter, we'll focus on testing the behavior of the survey results chart on our admin dashboard. You'll recall that this chart has a few pieces of interesting functionality---it displays average star ratings for each game, allows the user to filter these results by demographic info (age group and/or gender), and even updates in real-time to display new survey results when a user elsewhere in the application submits a survey. That's a lot of features! It may seem daunting to think of testing all of this behavior. So, we'll take a step back and think through what to test and why.

<author>Bruce, I'm trying to lay out _why_ we're writing unit tests for reducer functions, but I think I'm missing the mark a bit</author>

The survey results chart is backed by the `SurveyResultsLive`. This component wraps up the markup for the chart and manages its state and behavior. The component's ability to display the right data at the right time is built into its lifecycle functions---namely the `update/2` and `handle_event/3` functions it implements. These functions enact their state management behavior with the help of a series of reducers that iteratively manipulate the state of the component's socket.

Since these reducer functions are the foundation of our survey results chart's behavior, we'll want to ensure they are appropriately tested. Luckily for us, the functional and composable nature of these functions means they are highly testable.

In this section, we won't exhaustively test all of our component's reducer functions. We'll focus on a few functions that underpin the component's ability to display survey results data and filter it. Let's get started!

### Test Survey Results State

We'll begin with some simple tests of the component's ability to maintain the correct set of survey results in state. There are two different states of the world that the component must be able to reflect---the dataset when no product ratings exist and the dataset when some product rating exist.

We'll tackle the first scenario first and test that the `assign_products_with_average_ratings/1` reducer puts the correct dataset in state when no product ratings exist in the database.

Create a file, `test/pento_web/live/survey_results_live_test.exs` and establish the test module:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/survey_results_live_test.exs"
part="testing.survey_results_live_test.module_definition" />

There are a few things to point out here. We make sure to use the `PentoWeb.ConnCase` behaviour so that we can make web requests using the test connection to start up our live view. Then, we're aliasing the `SurveyResultsLive` component so that we can call on it with ease when testing the reducer functions.

Next up, we'll establish some fixtures and helper functions that we'll use to establish our test data:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/survey_results_live_test.exs"
part="testing.survey_results_live_test.test_data_helpers" />

We won't go into the details here---you can see that we have a set of fixtures that use module attributes to create user, demographic, product and rating records. Then, we have a set of helper functions that we can call in test setup blocks. These helper functions use the fixtures to create the test records.

Now that we have our setup out of the way, let's spec out a test for our first scenario---no product ratings exist.

Open up a describe block and add a call the `setup/1` function with the list of helpers that will create a user, product and socket struct:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/survey_results_live_test.exs"
part="testing.survey_results_live_test.socket_unit_test_setup" />

If you're unfamiliar with ExUnit's `setup/1` callback, you can learn more about it [here.](https://hexdocs.pm/ex_unit/ExUnit.Callbacks.html#setup/1) This function runs before each test in the specified case and merges the return of each specified function call into the each test's context.

After the first call to `setup/1`, we add in another setup callback, this time giving it a block to execute that establishes the demographic records for two test users.

We're finally ready to write our unit test! Underneath the setup block, create a test block for our scenario, and give the test block access to the `socket` struct we added to the test context via our setup call to `create_socket`:

{:language="elixir"}
~~~
test "no ratings exist", %{socket: socket} do
  # coming soon!
end
~~~

Now, let's think through what we're testing here. We're testing the scenario in which the socket is reduced over with the `assign_products_with_average_ratings/1` function in a world in which no product ratings exist. In that scenario, the resulting socket should contain a key of `:products_with_average_ratings` that points to a value that looks something like this:

{:language="elixir"}
~~~
[{"Test Game", 0}]
~~~

A list of tuples, where each tuple contains a game name and a `0` rating.

In order to unit test the `assign_products_with_average_ratings/1` reducer, we'll want to call it directly with an argument of our test socket struct. However, the `assign_products_with_average_ratings/1` function requires that the socket it is called with has the `:age_filter` and `:gender_filter` keys. So, we'll pipe our socket through the reducers that populate those keys before sending it along to the `assign_products_with_average_ratings/1` function. Something like this:

{:language="elixir"}
~~~
test "no ratings exist", %{socket: socket} do
  socket =
    socket
    |> SurveyResultsLive.assign_age_group_filter()
    |> SurveyResultsLive.assign_gender_filter()
    |> SurveyResultsLive.assign_products_with_average_ratings()
end
~~~

Finally, we'll add our assertion:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/survey_results_live_test.exs"
part="testing.survey_results_live_test.socket_unit_test_no_ratings" />

The composable nature of our component's reducer functions allowed us to orchestrate this test easily. We were able to establish a test socket and then pipe that socket through a set of reducers in order to test their functionality. Since we constructed our LiveView component with small, single-purpose, reuseable reducer functions, we are able to test the state management capabilities of that component by exercising various sets of those functions.

Let's quickly add another, similar, test of the `assign_products_with_average_ratings/1` reducer when product ratings do exist:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/survey_results_live_test.exs"
part="testing.survey_results_live_test.socket_unit_test_ratings_exist" />

Thanks to the composability of our reducer functions, writing tests is quick and easy and can be handled entirely in the world of ExUnit. We haven't even brought in any LiveViewTest functions yet.

### Test Survey Results Filtering

We'll write one more unit test before we move on tests that leverage LiveView functionality. The next core behavior of our survey results chart is it's ability to filter results based on age and gender. The `assign_age_group_filter/1` reducer manages the age group filter portion of our component's state. Testing its ability to do so correctly will ensure that our component contains the correct age group filter state given various inputs. We'll write a unit test for this reducer now.

Our test will play through a few scenarios with the help of a reducer pipeline:

* When an empty socket is given to the reducer pipeline, the resulting socket should have an `:age_group_filter` key that holds the value `"all"`. This represents the starting state of the component on the page.
* When that same socket is then piped through the `assign_age_group_filter/1` filter _again_, this time containing an age group filter of `"18 and under"`, then the resulting socket should retain that age group filter. This represents the ability of to component retain present state when updated via a message from the parent live view---for example with the parent receive a PubSub message that a new rating has been created, and then tells the component to update, our component should retain the age group filter state.
* Once that socket has been updated with the `"18 and under"` age group filter state, then the piped call to the `assign_products_with_average_ratings/1` reducer should result in socket state containing a set of product ratings by users in that age group, and only by users in that age group.

Thanks to the reusable and composeable nature of our reducers, we can construct a test pipeline that allows us to exercise and test each of these scenarios in one beautiful flow. Let's do it!

Open up `test/pento_web/live/survey_results_live_test.exs` and add a test block with the existing `describe`:

{:language="elixir"}
~~~
test "ratings are filtered by age group", %{socket: socket, user: user, product: product, user2: user2} do
  create_rating(2, user, product)
  create_rating(3, user2, product)

  # coming soon!
end
~~~

We open up our test block and create two ratings---one by the user with the "18 and under" demographic and one by the user with different demographic.

Now, we're ready to construct our reducer pipeline and test it. The first thing we want to test is that the `assign_age_group_filter/1` reducer, when called with an empty socket, assigns the `"all"` age group filter. Let's do it:

{:language="elixir"}
~~~
test "ratings are filtered by age group", %{socket: socket, user: user, product: product, user2: user2} do
  create_rating(2, user, product)
  create_rating(3, user2, product)

  socket =
    socket
    |> SurveyResultsLive.assign_age_group_filter()

  assert socket.assigns.age_group_filter == "all"
end
~~~

Run the test, and you'll see it pass:

{:language="session"}
~~~
// ♥ mix test test/pento_web/live/survey_results_live_test.exs:109
Excluding tags: [:test]
Including tags: [line: "109"]

.

Finished in 0.1 seconds
3 tests, 0 failures, 2 excluded

Randomized with seed 48183
~~~

Great! Next up, we want to test that we can take the _same_ socket, update its age group filter to "18 and under", _then_ pipe it to `assigne_age_group_filter/1` and see that the "18 and under" filter is retained in state. We could do something like this:

{:language="elixir"}
~~~
test "ratings are filtered by age group", %{socket: socket, user: user, product: product, user2: user2} do
  create_rating(2, user, product)
  create_rating(3, user2, product)

  socket =
    socket
    |> SurveyResultsLive.assign_age_group_filter()

  assert socket.assigns.age_group_filter == "all"

  socket =
    update_socket(socket, :age_group_filter, "18 and under")
    |> SurveyResultsLive.assign_age_group_filter()

  assert socket.assigns.age_group_filter == "18 and under"
end

defp update_socket(socket, key, value) do
  %{socket | assigns: Map.merge(socket.assigns, Map.new([{key, value}]))}
end
~~~

Here, we use a helper function to set the `:age_group_filter` key in socket assigns to "18 an under". Then, we take our existing socket, pipe it through this helper and into our reducer. Finally, we establish _another_ test assertion. This code works, but we can do better. The beauty of our single-purpose, functional reducers is that they can be piped. With a littler support from a new helper function, we can orchestrate a test pipeline that not only exercises _all_ of the scenarios we layed out above, but _also_ includes test assertions within one elegant flow.

We'll create an assertion helper function that works like a reducer---it will take in an argument of our socket, execute an assertion against that socket, and then return the socket.

Open up the test file and add the following below the `update_socket/3` helper:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/survey_results_live_test.exs"
part="testing.survey_results_live_test.assert_keys" />

Now, we can assemble our test pipeline like this:

{:language="elixir"}
~~~
test "ratings are filtered by age group", %{socket: socket, user: user, product: product, user2: user2} do
  create_rating(2, user, product)
  create_rating(3, user2, product)

  socket
  |> SurveyResultsLive.assign_age_group_filter()
  |> assert_keys(:age_group_filter, "all")
  |> update_socket(:age_group_filter, "18 and under")
  |> SurveyResultsLive.assign_age_group_filter()
  |> assert_keys(:age_group_filter, "18 and under")
end
~~~

We can chain further reducers and assertions onto our pipeline to test the final scenario---asserting that the `assign_products_with_average_ratings/1` reducer function populates the socket with the correct product ratings given the provided filters:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/survey_results_live_test.exs"
part="testing.survey_results_live_test.assert_keys" />

The composable nature of our reducer functions makes them highly testable. It's easy to test the functionality of a single reducer under a variety of circumstances, or to string together any set of reducers to test the combined functionality of the pipelines that support your live view's behavior. With a little help from our `assert_keys/3` function, we were able to construct a beautiful pipeline that handled all of our desired test scenarios in one easy-to-read flow.

Now that we've written a few unit tests that validate the behavior of the reducer building blocks of our live view, let's move on to testing some of the specific LiveView features and behaviors with the help of the LiveViewTest module.

## Test LiveView Without JavaScript
As we move on to testing the LiveView functionality of our survey results chart feature, you'll see that we can provide comprehensive test coverage for the full feature _without writing any JavaScript_. This statement should get some attention from anyone used to the overhead of bringing in an external, JavaScript dependency to write integration tests that are often slow and flaky. So, we'll say it again---you don't need JavaScript to test LiveView!

The LiveViewTest module provides a set of convenience functions that we'll use to write "LiveView tests". LiveView tests use process communication to interact with your live views without a browser. We can use LiveView tests to mount and render a live view, trigger any user interaction that live view supports and then write assertions about the rendered view. In this way, we can test the lifecycle and behavior of our live views entirely in Elixir, without bringing in a browser-based, JavaScript testing dependency.

Remember that the JavaScript that supports LiveView is part of the LiveView framework itself---you the LiveView developer don't have to write any of your own JavaScript to send messages from the client to the server. So, you also don't have to leverage JavaScript to _test_ your live views. You can trust that the JavaScript in the framework does what it's supposed to do, and focus your attention on testing the specific behaviors and features that you built into your own live view.

As a result, we have LiveView tests that are quick and easy to write and that run fast and concurrently. Once again, LiveView saves us from having to split our mindset across the back- and front-end---even our tests are written purely in Elixir. The LiveViewTest module is one more way that LiveView developers are empowered to be highly productive at buildling SPAs.

Okay, enough talk about how great LiveView tests are. Let's actually write some.


## LiveView Test Interactive Features
We've unit tested the individual pieces of code responsible for enacting our component's filtering functionality. Now it's time to test that same filtering behavior by exercising the overall live view. We'll write a LiveView test to tes the following behavior: When a user visits `/admin-dashboard` and selects the "18 and under" age group from the age group drop down menu, then the survey results chart will update to display only product ratings from users in that age group.

To accomplish this, we'll use the LiveViewTest module to run our admin dashboard live view and interact with the survey results component. Along the way, you'll see LiveViewTest helper functions in action, get a taste for the wide variety of interactions they allow you to test and come to understand that you don't need JavaScript to comprehensively test your live views.

We'll begin by setting up a LiveView test for our `AdminDashboardLive` view.

### Setup The LiveView Test
Create a new file, `test/pento_web/live/admin_dashboard_live_test.exs` and key in the following:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/admin_dashboard_live_test.exs"
part="testing.admin_dashboard_live_test.module_setup" />

We're doing a few things here. We define our test module, use the `PentoWeb.ConnCase` behavior that will allow us to route to live views using the test connection, import the `LiveViewTest` module to give us access to LiveView testing conveniences, and through in some fixtures we will use to create our test data.

Next up, add a describe block to encapsulate the feature we're testing--the survey results chart functionality:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/admin_dashboard_live_test.exs"
part="testing.admin_dashboard_live_test.survey_results_setup" />

Our two calls to `setup/1` ensure that we have a product, users, demographics and ratings seeded into the test database for this upcoming set of tests. Here, we're creating two users, one with an "18 and under" demographic and one with a demographic in a different age group. Then, we create a rating associated to each user.

We're also using a test helper created for us way back when we ran the authentication generator--`register_and_log_in_user/1`. This function creates a `conn` struct that contains an authenticated user and session data and makes that `conn` available in the context of any tests in this describe block. This is a necessary step as our `admin-dashboard` live route is an authenticated one.

Now that our setup is completed, we're ready to write our first LiveView test!

### Test The Survey Chart Filter

Let's add a test block within our `describe`:

{:language="elixir"}
~~~
test "it filters by age group", %{conn: conn} do
  # coming soon!
end
~~~

Before we fill in the code for our test, let's make a plan. We'll need to:

* Mount and render the live view
* Find the age group filter drop down menu and select an item from it
* Assert that the re-rendered survey result chart has the correct data and markup

This is the pattern you'll apply to testing live view features from here on out. Run the live view, target some interaction, test the rendered result.

To mount and render the live view, we'll use the `live/2` LiveViewTest function. This function spawns a connected, i.e. WebSocket-backed, LiveView process. We call the function with the test `conn` struct and the path to the live view we want to run and render:

{:language="elixir"}
~~~
test "it filters by age group", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/admin-dashboard")
end
~~~

The call to `live/2` returns a three element tuple with `:ok`, the LiveView process, and the rendered HTML returned from the live view's call to `render/1`. We don't need to introspect on that HTML for the purposes of our test, so we ignore it.

Note that we're starting up the `AdminDashboardLive` view, rather than rendering _just_ the `SurveyResultsLive` component. By spawning the `AdminDashboardLive` view, we're _also_ rendering the components that the view is comprised of. This means our `SurveyResultsLive` component is up and running and is rendered within the `AdminDashboardLive` view represented by the returned `view` variable. So, we'll be able to interact with elements within that component and test that it re-renders appropriately with the parent live view, in response to events. This is the correct way to test LiveView component behavior within a live view page.

Sidebar
To test the *rendering* of a component in isolation, you can use the `render_component/2` function. This will render and return the markup of the specified component, allowing you to write assertions against that markup. This is useful in writing unit tests for stateless components. To test the behavior of a component---i.e. how it is mounted within a parent live view and how DOM events impact its state---you'll need to run the parent live view with the `live/2` function and target events at DOM elements contained within the component.

Now that our live view and up and running in our test, we'll need to find the age group filter form and select its "18 and under" option. We can do this with the help of the LiveViewTest `element/3` function. This function returns an element that we can scope a function to. In other words, we can use it to select an element on the page and then interact with that element via additional convenience functions for rendering clicks, form changes and submits, and more.

LiveViewTest provides a number of such functions for identifying and selecting elements on the page and interacting with them, covering pretty much all of interactions that your users will be able to enact on the page. For a comprehensive look at these functions, you can read through the documentation [here.](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html#functions)

The `element/3` function will do the trick for us here though. We'll use it to find the age group filter drop down form on the page. First, we'll add a unique ID attribute to the form element so that we can find it with the `element/3` function:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/admin_dashboard_live_test.exs"
part="testing.survey_results_live.template.age_group_form" />

Now we can target this element with the `element/3` function:

{:language="elixir"}
~~~
test "it filters by age group", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/admin-dashboard")
  html =
    view
    |> element("#age-group-form")
end
~~~

`element/3` accepts three arguments---the live view we want to select an element within, any query selector, and some optional text to narrow down the query selector even further. If no text filter is provider, it must be true that the query selector returns a single element.

Let's take a look at the returned element now in order to better understand how we will operate on it to simulate user interactions.

Add the following to your test:

{:language="elixir"}
~~~
test "it filters by age group", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/admin-dashboard")
  html =
    view
    |> element("#age-group-form")
    |> IO.inspect
end
~~~

Then, run the test and you'll see the element inspected into the terminal:


{:language="session"}
~~~
// ♥ mix test test/pento_web/live/admin_dashboard_live_test.exs:75
Compiling 1 file (.ex)
Excluding tags: [:test]
Including tags: [line: "75"]

...

#Phoenix.LiveViewTest.Element<
  selector: "#age-group-form",
  text_filter: nil,
  ...
>
.

Finished in 0.3 seconds
2 tests, 0 failures, 1 excluded
~~~

The element struct returned by `element/3` is what we will operate on in order to render click and other DOM events to trigger the re-render of the live view.

Let's operate on that element now by enacting a form change event that selects the "18 and under" option from the age group form element's drop down menu:

{:language="elixir"}
~~~
test "it filters by age group", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/admin-dashboard")
  html =
    view
    |> element("#age-group-form")
    |> render_change(%{"age_group_filter" => "18 and under"})
end
~~~

The `render_change/2` function triggers a form change event against the provided element. It sends the event name that the specified element assigned to its `phx-change` attribute with the value provided as the second argument to `render_change/2`. This event is sent to whichever live view or component the selected element targets with the change event via its `phx-target` attribute.

You'll recall from our form element definition that it is contained within the `SurveyResultsLive` component and specifies a `phx-change` event of `"age_group_filter"` and a `phx-target` of `@myself`:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/admin_dashboard_live_test.exs"
part="testing.survey_results_live.template.age_group_form" />

So, calling `render_change/2` on this element will send the `"age_group_filter"` event to the `SurveyResultsLive` component. This will cause the component to update its own state and re-render the survey results chart with the filtered product rating data.

This means that we're ready to write our assertions. The call to `render_change/2` will return the re-rendered view markup. Let's add an assertion that the re-rendered chart displays the correct data. Recall that the bars in our survey results chart are labeled with the average star rating for the given product, like this:

You can see that the "Tic-Tac-Toe" column, for example, is labeled with its average star rating of 2.75.

So, if we establish test data with two product ratings--a `2.00` rating and a `3.00` rating, and then filter the results by age group so that only the `2.00` rating belonging to the "18 and under" user remains, then the re-rendered page should contain markup with the content `2.00`.

With that in mind, we're almost ready to write our assertion. First, we need to know exactly what markup to assert the presence of. In order to inspect the page in the browser at the right moment in time, LiveViewTest provides a helper for us. The `open_browser/1` function takes in an element or an entire view and renders the markup in the browser. This is a helpful way to introspect into and debug tests by freezing code execution and examining a snapshot of the rendered markup at a specific point in time.

Let's use `open_browser/1` now to inspect the view:

{:language="elixir"}
~~~
test "it filters by age group", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/admin-dashboard")
  html =
    view
    |> open_browser()
    |> element("#age-group-form")
    |> render_change(%{"age_group_filter" => "18 and under"})
end
~~~

Now, run the test via `mix test test/pento_web/live/admin_dashboard_live_test.exs:75` and you should see your default browser open and display the following page:

We can open up the element inspect in order to select the "Test Game" column's label:

Now we know exactly what element to test for, a `<title>` element that should contain the text `2.00` after the filter is applied.

Let's add the assertion to our test:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/admin_dashboard_live_test.exs"
part="testing.admin_dashboard_live_test.survey_results_filtering" />

Now, if you run your test, it will pass. We did it! The LiveViewTest module provided us with everything we needed to mount and render a connected live view, target elements within that live view---even elements nested within child components---and assert the behavior of the view after firing DOM events against those elements.

The test code, like much of the Elixir and LiveView code we've been writing, is clean and elegantly composed with a simple pipeline. All of the test code is written in Elixir with ExUnit and LiveViewTest functions which made it quick and easy for us to conceive of and write our test. Our test runs fast, and it's highly reliable. We didn't need to bring in any JavaScript dependencies and undertake any onerous setup to test our LiveView feature. LiveView tests allow us to focus on the live view behavior we want to test---we don't need JavaScript because we trust that the JavaScript in the LiveView framework will work the way it should.

We only saw a small subset of the LiveViewTest functions that support LiveView testing here. We used `element/3` and `render_change/2` to target and fire our form change event. There are many more LiveViewTest functions that allow you to send any number of DOM events---blurs, form submissions, live navigation and more. The LiveViewTest module provides everything you need to exercise the full functionality of any live view. We won't get into all of those functions here, we'll let you explore more of them on your own. There is one more piece of testing functionality that we'll employ now though.

In the previous chapter, we extended our admin dashboard with some PubSub-backed functionality, allowing it to update the survey results chart in real-time whenever a user submitted a new product rating. LiveViewTests allow us to test this distributed real-time functionality with ease. Before we wrap up, we'll write a test for this real-time update feature.

## LiveView Test Real-Time Features
Testing messaging passing in a distributed application can be painful, but LiveViewTest makes it easy to test the PubSub-backed real-time features we've built into our admin dashboard. That is because, as you've seen, LiveView tests interact with views via process communication. As such, its a simple matter of using the `send/2` function to send a message to your live view, just like a PubSub broadcast would send such a message.

In this section, we'll test our admin dashboard live view's ability to update the survey results chart in real-time when it receives a message that a new product rating has been created. In order to accomplish this, we'll send the appropriate message to the view and then use the render function to test the result.

When we're done, you'll have seen that LiveView tests can indeed exercise the full functionality of any live you will might build.

### Test LiveView Message Passing

To test our real-time survey results chart update feature, we'll follow the same LiveView test pattern we used earlier on this this chapter:

* Mount and render the connected live view
* Enact some interaction with that live view---in this case, send the "rating created" message
* Re-render the view and check some assertion

Open up the `test/pento_web/live/admin_dashboard_live_test.exs` file and add a new test block within the current `describe`:

{:language="elixir"}
~~~
test "it updates to display newly created ratings", %{conn: conn, product: product} do
  # coming soon!
end
~~~

First, our test block will mount and render a connected live view:


{:language="elixir"}
~~~
test "it updates to display newly created ratings", %{conn: conn, product: product} do
  {:ok, view, html} = live(conn, "/admin-dashboard")
end
~~~

Before we target our interaction and establish some assertion, let's think about what we're testing for. Thanks to our setup block, we already have one product with two ratings--a star rating of 2 and a star rating of 3. So, we know our survey results chart will render a bar for this product with a label of `2.50`. We can verify this assumption with the help of the `open_browser/0` function:

{:language="elixir"}
~~~
test "it updates to display newly created ratings", %{conn: conn, product: product} do
  {:ok, view, html} = live(conn, "/admin-dashboard")
  open_browser(view)
end
~~~

Run the test:


{:language="session"}
~~~
mix test test/pento_web/live/admin_dashboard_live_test.exs:84
~~~

And you'll see the page open in the browser:

We can see in fact the chart does have a bar with a `<title>` element containing the text `2.50`.

Our test will need to create a new rating that will change this average star rating title. Then, we'll need to send the "rating created" message to the live view and check that the re-rendered markup contains the appropriately changed `<title>` element.

First, let's add a test assertion looking fot the `2.50` title element to ensure that the starting state of our page is correct:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/admin_dashboard_live_test.exs"
part="testing.admin_dashboard_live_test.survey_results_update_start" />

Now, let's create a new user, demographic and rating with a star value of `3`:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/admin_dashboard_live_test.exs"
part="testing.admin_dashboard_live_test.survey_results_update_create_rating" />

Now we're ready to trigger our live view interaction by sending the event to the view.

Recall that when a user submits a product rating, we use PubSub to broadcast a message, `"rating_created"` with an empty payload. PubSub then sends a message to any subscribers that looks like this:

{:language="elixir"}
~~~
%{event: "rating_created", payload: %{}}
~~~

Our `AdminDashboardLive` view implements the following `handle_info/2` event handler for this event:

<embed language="elixir"
file="code/testing/pento/lib/pento_web/live/admin_dashboard_live.ex"
part="testing.admin_dashboard_live.handle_info.rating_created" />

So this is the shape of the message we will send to the view in our test. We'll use the `send/2` function to do it:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/admin_dashboard_live_test.exs"
part="testing.admin_dashboard_live_test.survey_results_update_send_message" />

Finally, we're ready to re-render the view and execute our assertion:

<embed language="elixir"
file="code/testing/pento/test/pento_web/live/admin_dashboard_live_test.exs"
part="testing.admin_dashboard_live_test.survey_results_update_assertion" />

Now, if we run our test, it should pass.

With that, you've seen a lot of what live view tests can do. Before we go, we'll give you a chance to get your hands dirty.

## Your Turn

LiveView is easy to test for two reasons:

* Writing our live views with small, single-purpose reducer functions makes unit testing clean and easy. We can write beautiful testing flows that ensure the building blocks of our live views are sound.
* LiveView tests with the LiveViewTest module allow you to exercise _all_ of your live view's functionality with pure Elixir. You don't have to bring in a JavaScript testing dependency and you don't have to split your mindset between the backend and the frontend. LiveView's framework handles the JavaScript and doesn't need to be tested.

LiveView tests are just one more way that LiveView developers can be highly productive at building SPAs. Just remember to reach for these two patterns when testing your live views: unit test reducer functions and pipelines, and LiveView test your live view's interactive and real-time behaviors. When writing LiveView tests, you'll follow the basic pattern: mount and render the connected view, enact some interaction with the view (like targeting an event or sending a message), and then execute an assertion against the re-rendered view.

We only saw a handful of LiveView test features in this chapter. We've provided the following exercises for you to gain some experience with even more.

### Give It a Try

These tasks will give you a chance to explore more of the full range of LiveView test capabilities.

* Test the stateless `RatingLive.IndexComponent` with the help of the [`render_component/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html#render_component/3) function. Test that the component renders the product rating form when no product rating exists by the given user and test that the component renders the rating details where such a rating does exist.
* Test the stateful `DemographicLive.FormComponent`. Ensure that the form for a new demographic can be successfully submitted and that the page then updates to display the saved demographic details.
* TBD something with reducer unit tests?...

<author>Bruce, if you had specific exercises in mind, feel free to change/remove/add to these!</author>