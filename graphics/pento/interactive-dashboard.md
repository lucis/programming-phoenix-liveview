## Learning Goals
* Learn how to build and render server-side SVG charts
* Leverage components to manage complex state changes triggered by user interactivity
* Continue to cement our understanding of the core/boundary principles of our LiveView application as we build out our new feature
* Continue to build clean and composable reducer pipelines to manage LiveView state
send_update/2` function

## Outline
* Intro/What We'll Build
* Interactive Survey Results with Server-Side-Rendered SVG Chart
* The `AdminDashboardLive` LiveView
* The `SurveyResultsLive` Component
* Querying for Survey Results Data
* Building a Server-Side-Rendered SVG Chart
* Interactive Survey Results Filtering
* Refactoring Charts with Macros

## Intro
In the previous chapter, we introduced the concept of components as a way to organize and compartmentalize the markup and state of our single page apps. The focus of this chapter is interactivity. In this chapter, we'll continue to work with components to handle complex state changes brought about by user activity. We'll teach a component to handle a set of events triggered by user behavior. As a bonus, we'll build out some server-side SVG charts and build clean, re-usable chart rendering code with the help of macros

## What We'll Build: The Admin Dashboard
Over the next two chapters, we'll build out an admin dashboard that uses components to support the following features:
* A bar chart representing product survey results that displays each product and its average star rating. The chart will be filterable by demographic info and will update with new ratings in real-time.
* A table tracking user engagement with our products by displaying a real-time list of users who are viewing those products.
* A scatter plot chart representing the current sales of each of our products. The chart should update in real-time to reflect any new sales for a given product and their dollar amounts.

Here's what we're going for:

<imagedata fileref="images/interactive_dashboard/admin-dashboard-overview.png" width="65%"/>


## Interactive Survey Results Chart
In this chapter, we'll build the product survey chart. We'll build a component that renders an SVG chart on the server, representing all of our products and their average star ratings. Then, we'll make our chart responsive by building out the ability for users to filter survey results by demographic information.

##  The `AdminDashboardLive` LiveView
We'll begin by building out the scaffolding for our feature––the `AdminDashboardLive` LiveView. Then, we'll define a basic component, `SurveyResultsLive`, and render it statefully from `AdminDashboardLive`.

First off, let's define `AdminDashboardLive` and mount it at the `/admin-dashboard` live route in our application's router.

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web/live/admin_dashboard_live.ex"
part="interactive_dashboard.admin_dashboard_live.mount" />

Note that we're setting the ID with which we will render our stateful component in our LiveView's socket assigns. This is because we will need access to this ID later on to implement our PubSub-backed live-update feature. More on that later.

We'll mount our new LiveView in the router:

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web/router.ex"
part="interactive_dashboard.router.admin_dashboard_live" />

Now we'll build a simple template for our LiveView to implicitly render.

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web/live/admin_dashboard_live.html.leex"
part="interactive_dashboard.admin_dashboard_live.template.header" />

Now, if we start up our server and, as an authenticated user, point our browser at `/admin-dashboard`, we should see the following:

<imagedata fileref="images/interactive_dashboard/admin-dashboard-header.png" width="65%"/>

Now we're ready to build out our `SurveyResultsLive` component!

## The `SurveyResultsLive` Component
We'll start by implementing a basic component and template that doesn't do much. We'll render it as a stateful component from the `AdminDashboardLive` LiveView and make sure everything's working.

Our component will start off simple:

{:language="elixir"}
~~~
# lib/pento_web/live/survey_results_live.ex
defmodule PentoWeb.SurveyResultsLive do
  use PentoWeb, :live_component
end
~~~

And our template, which the component will implicitly render, will simply render a header for now:

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web/live/survey_results_live.html.leex"
part="interactive_dashboard.survey_results_live.template.header" />

We're ready to render the component statefully from the parent LiveView. Recall that a component is stateful if it is rendered via a call to `live_component/3` with an `:id`. Earlier, we added a string that we will use for this ID to the `AdminDashboardLive`'s socket assigns. We'll use that assignment in the `AdminDashboardLive` template to render our stateful component now.

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web/live/admin_dashboard_live.html.leex"
part="interactive_dashboard.admin_dashboard_live.template.render_survey_results_live" />

Now, if we point our browser at `/admin-dashboard`, we should see:

<imagedata fileref="images/interactive_dashboard/survey-results-header.png" width="65%"/>

Now that everything is wired up and running, we're ready to build the survey results bar chart.

## Fetching Survey Results Data

In order to render products and their average star ratings in a chart, we'll need to be able to query for this data in the form of a list of product names and their associated average star ratings. The format of this data is somewhat dictated by the manner in which we will need to feed it into our chart. More on that later. For now, its enough to understand that we need to fetch a list of products and average ratings that looks like this:

{:language="elixir"}
~~~
[
  {"Tic-Tac-Toe", 3.4285714285714284},
  {"Ping Pong", 2.5714285714285716},
  {"Pictionary", 2.625}
]
~~~

While the work of *composing* queries is predictable and reliable, the work of *executing* queries is anything but. You can't be certain of what the results of executing a database query will be, and such work is often dependent on input from a user. So, the execution of our query will be the responsibility of our app's `Catalog` context. The context acts as our application's boundary, and it's where we can located code that deals with uncertainty and with input from the outside world.

The certain and predictable work of composing queries happens in our application's core. We'll build a query for fetching products with their average ratings by implementing some query reducer functions in the `Pento.Catalog.Product.Query` query builder module. We'll compose and execute the query in the `Catalog` context.

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento/catalog/product/query.ex"
part="interactive_dashboard.products.query_builder.with_average_ratings" />

Our function starts with the base query and pipes that query through a set of two reducers--one that adds the statement that joins products on ratings, and another that selects the product name and the average of its ratings' starts. This query will return a list of tuples where the first element in the tuple is the product name and the second element is the average of the product's ratings' stars.

If we fire up IEx and execute our query, we should see something like the following:

{:language="elixir}
~~~
iex> alias Pento.Catalog.Product
Pento.Catalog.Product
iex> alias Pento.Repo
Pento.Repo
iex> > Product.Query.with_average_ratings() |> Repo.all()
[debug] QUERY OK source="products" db=0.8ms queue=0.6ms idle=1542.9ms
SELECT p0."name", avg(r1."stars")::float FROM "products" AS p0 INNER JOIN "ratings" AS r1 ON r1."product_id" = p0."id" GROUP BY p0."id" []
[
  {"Tic-Tac-Toe", 3.4285714285714284},
  {"Ping Pong", 2.5714285714285716},
  {"Pictionary", 2.625}
]
~~~

Let's define a function in the `Catalog` function that can execute this query.

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento/catalog.ex"
part="interactive_dashboard.catalog.products_with_average_ratings" />

Now we can use this context function in our `SurveyResultsLive` component to fetch our bar chart data and add it to socket assigns. We'll use the `update/2` component lifecycle function to do just that by composing a reducer pipeline that does just that.

{:language="elixir"}
~~~
# lib/pento_web/live/survey_results_live.ex
defmodule PentoWeb.SurveyResultsLive do
  use PentoWeb, :live_component
  alias Pento.Catalog

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_products_with_average_ratings()}
  end
end
~~~

The `assign_products_with_average_ratings/1` reducer function is implemented to call on our `Catalog.products_with_average_ratings/0` function and add the query results to socket assigns under the `:products_with_average_ratings` key.

{:language="elixir"}
~~~
# lib/pento_web/live/survey_results_live.ex
defp assign_products_with_average_ratings(socket) do
  socket
  |> assign(
    :products_with_average_ratings,
    Catalog.products_with_average_ratings())
  )
end
~~~

Now that we have the data we need to populate our bar chart, we're ready to render it.

## Rendering SVG Charts with Contex

While there quite a few JavaScript charting libraries to choose from, we're after a _server-side rendering_ solution. LiveView manages state on the server. State changes trigger  a re-render of the HTML, push that HTML to the client, which then efficiently updates the UI. So, we don't want to bring in a library that renders charts with lots of complex JavaScript on the client. We need to be able to draw our charts on the server and send that chart HTML down to the client.

We'll use the [Contex charting library](https://github.com/mindok/contex) to handle our server-side SVG chart rendering. The Contex library has us build out charts in two steps. First, we'll initialize the chart's dataset, then we build and render the SVG chart with that dataset.

We'll begin with the first step.

### Initializing the `Dataset`

The first step of building a Contex chart is to initialize the data set with the `Contex.Dataset` module. [The `DataSet` module](https://hexdocs.pm/contex/Contex.Dataset.html) wraps your dataset for plotting charts. It provides a set of convenience functions that subsequent chart plotting modules will leverage to operate on and chart your data. `Dataset` handles several different data structures by marshalling them into a consistent form for consumption by the chart plotting functions. The data structures it can handle are: a list of maps, list of lists or a list of tuples. Recall that we ensured that our query for products with average ratings returns a list of tuples.

We'll begin by adding a new reducer function to the pipeline in `update/2` that initializes a new `Dataset` with the query results, our list of products and average rating tuples, from socket assigns. Our reducer should add the new dataset to socket assigns.

{:language="elixir"}
~~~
# lib/pento_web/live/survey_results_live.ex
defmodule PentoWeb.SurveyResultsLive do
  use PentoWeb, :live_component
  alias Pento.Catalog

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_products_with_average_ratings()
     |> assign_dataset()}
  end

  ...

  defp assign_dataset(
        %{assigns: %{products_with_average_ratings: products_with_average_ratings}} = socket
      ) do
    socket
    |> assign(:dataset, make_bar_chart_dataset(products_with_average_ratings))
  end

  defp make_bar_chart_dataset(data) do
    Contex.Dataset.new(products_with_average_ratings)
  end
end
~~~

If we take a look at the output of our call to `Contex.Dataet.new/1`, we'll see the following struct:

{:language="elixir"}
~~~
%Contex.Dataset{
  data: [
    {"Tic-Tac-Toe", 3.4285714285714284},
    {"Ping Pong", 2.5714285714285716},
    {"Pictionary", 2.625}
  ],
  headers: nil,
  title: nil
}
~~~

The `Dataset` considers the first element of a given tuple in the list to be the "category column" and the second element to be the "value column". The category column is used to label the bar chart category (in our case the product name), and the value column is used to populate the value of that category.

### Initializing the `BarChart`
Now that we have our dataset, we can use it to initialize our `BarChart`. We'll make this the responsibility of another reducer that we'll add to the `update/2` pipeline, `assign_chart/1`.

{:language="elixir"}
~~~
# lib/pento_web/live/survey_results_live.ex
defmodule PentoWeb.SurveyResultsLive do
  use PentoWeb, :live_component
  alias Pento.Catalog

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_products_with_average_ratings()
     |> assign_dataset()
     |> assign_chart()}
  end

  ...

  defp assign_chart(%{
        assigns: %{dataset: dataset}
      } = socket) do
    socket
    |> assign(:chart, make_bar_chart(dataset))
  end

  defp make_bar_chart(dataset) do
    BarChart.new(dataset)
  end
end
~~~

The call to `BarChart.new/1` will create a `BarChart` struct that describes how to plot the bar chart. The `BarChart` module provides a number of configurable options with defaults, all of which are listed in the documentation [here](https://hexdocs.pm/contex/Contex.BarChart.html#summary). For example, we can set the orientation (which defaults to vertical), the colors, the padding and more.

It's important to note again that the first column of the dataset is used as the category column (i.e. the bar), and the second column is used as the value column (i.e. the bar height). This is managed through the `:column_map` attribute. We can see our `BarChart` struct has the following `:column_map` value:

{:language="elixir"}
~~~
column_map: %{category_col: 0, value_cols: [1]}
~~~

The values of `0` and `[1]` refer to the indices of elements in the tuples in our `DataSet`. The element at the `0` index will be considered the "category" and the element and the `1` index will be considered the "value". Our tuples have the product name at the zero index and the average rating at the `1` index, so our product names will be treated at the category and their average ratings the value.

### Transforming the Chart to SVG
The final step of building our server-side-rendered SVG bar chart is just that--rendering it as SVG markup on the server. We'll do this with the help of the `Contex.Plot` module. We'll do this with the help of another reducer added to our `update/2` pipeline, `assign_chart_svg/1`.

In this reducer, we'll take our `BarChart` struct and use it to initialize the `Contex.Plot`. The `Plot` module manages the layout of the chart plot--the chart title, axis labels, legend, etc. We initialize our `Plot` with the plot width and height, and the chart struct:

{:language="elixir"}
~~~
# lib/pento_web/live/survey_results_live.ex
defmodule PentoWeb.SurveyResultsLive do
  use PentoWeb, :live_component
  alias Pento.Catalog

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_products_with_average_ratings()
     |> assign_dataset()
     |> assign_chart()
     |> assign_chart_svg()}
  end

  ...

  defp assign_chart_svg(%{
        assigns: %{chart: chart}
      } = socket) do
    socket
    |> assign(:chart_svg, render_bar_chart(chart))
  end

  defp render_bar_chart(chart) do
    Plot.new(500, 400, chart)
  end
~~~

We'll customize our plot with a chart table and some labels for the x- and y-axis:

{:language="elixir"}
~~~
# lib/pento_web/live/survey_results_live.ex
defp assign_chart_svg(%{
        assigns: %{chart: chart}
      } = socket) do
  socket
  |> assign(:chart_svg, render_bar_chart(chart))
end

defp render_bar_chart(chart) do
  Plot.new(500, 400, chart)
  |> Plot.titles(title(), subtitle())
  |> Plot.axis_labels(x_axis(), y_axis())
end

defp title do
  "Product Ratings"
end

defp subtitle do
  "average star ratings per product"
end

defp x_axis do
  "products"
end

defp y_axis do
  "stars"
end
~~~

This will (you guessed it), apply the title, subtitles and axis labels to our chart.

Now we're ready to transform our plot into an SVG with the help of the `Plot` module's `to_svg/1` function and add that SVG markup to socket assigns:

{:language="elixir"}
~~~
# lib/pento_web/live/survey_results_live.ex
defp render_bar_chart(chart) do
  Plot.new(500, 400, chart)
  |> Plot.titles(title(), subtitle())
  |> Plot.axis_labels(x_axis(), y_axis())
  |> Plot.to_svg()
end
~~~

Now we're ready to render this chart SVG on our template. Let's take a look at the template now

### Rendering the Chart in the Template
Our `SurveyRatingsLive` template is still pretty simple, it will render the SVG stored in the `@chart_svg` assignment:

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web/live/survey_results_live.html.leex"
part="interactive_dashboard.survey_results_live.template.chart_svg" />

Now, we should see the following chart rendered when we navigate to `/admin-dashbaord`:

<imagedata fileref="images/interactive_dashboard/survey-results-chart-simple.png" width="65%"/>

Now that our chart is rendering beautifully, let's leverage LiveView to make it responsive. We'll add some filters that allow users to filter product ratings by demographic information.

## Filtering the Survey Results Chart
We'll add the ability for our users to filter the chart demographic info. We'll walk-through building out a "filter by age group" feature, and leave it up to you to review the code for the "filter by gender" feature.

## Filter By Age Group
We'll support the following age group filters:

* all
* 18 and under
* 18 to 25
* 25 to 35
* 35 and up

Here's what we're going for:

<imagedata fileref="images/interactive_dashboard/survey-results-form-age-filter.png" width="65%"/>

Note that the filter defaults to "all" and the chart should render _all_ results, un-filtered by age group, when the page loads.

### Building Age Group Query Filters
We'll begin by building a set of query functions that will allow us to filter for products with average ratings where those ratings belong to a demographic in the given age group.

Let's take a look at our query builder functions.

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento/catalog/product/query.ex"
part="interactive_dashboard.products.query_builder.filter_by_age_group" />

First off, we've implemented two public reducer functions that enact our joins statements. We'll use these in our `Catalog` context's `products_with_average_rating/1` function (more on that in a moment) to build a query with the joins required for us to filter on age group. This brings us to our age group filtering reducer. We've implemented another public function, `filter_by_age_group/2` which reduces over our query further, filtering on the products' ratings' demographic info. It does so with the help of the private `apply_age_group_filter/2` function which we will implement to apply the correct filtering logic based on the age group. Let's take a look now.

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento/catalog/product/query.ex"
part="interactive_dashboard.products.query_builder.apply_age_group_filter" />

We can use the public functions in our Catalog context to further reduce the `products_with_average_ratings` query before executing it. Let's update the signature of our `Catalog.products_with_average_ratings/0` function to:

* Take in an argument of the age group filter
* Apply the user join reducer
* Apply the demographic join reducer
* Apply the age group filter reducer

{:language="elixir"}
~~~
# lib/pento/catalog.ex
def products_with_average_ratings(%{
      age_group_filter: age_group_filter
    }) do
  Product.Query.with_average_ratings()
  |> Product.Query.join_users()
  |> Product.Query.join_demographics()
  |> Product.Query.filter_by_age_group(age_group_filter)
  |> Repo.all()
end
~~~

### Adding the Age Group Filter to Component State

Now that we are able to query and filter by age group, let's update our `SurveyResultsLive` component to:

* Set an initial age group filter in socket assigns to `"all"`
* Call the updated version of our `Catalog.products_with_average_ratings/1` function with the age group filter from socket assigns
* Display a drop-down menu with age group filters in the template

Then we'll be ready to add some event handling to the age group drop-down menu.

First up, we'll add `:age_group_filter` to socket state and default it to `"all"` when we set initial state in our component's `update/2` callback. We'll do this with the help of a new reducer function, `assign_age_group_filter/1`

{:language="elixir"}
~~~
# lib/pento_web/live/survey_results_live.ex
defmodule PentoWeb.SurveyResultsLive do
  use PentoWeb, :live_component
  alias Pento.Catalog

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_age_group_filter()
     |> assign_products_with_average_ratings()
     |> assign_dataset()
     |> assign_chart()
     |> assign_chart_svg()}
  end

  def assign_age_group_filter(socket) do
    socket
    |> assign(:age_group_filter, "all")
  end
~~~

We'll also update the `assign_products_with_average_ratings/1` function to use the age group filter from socket assigns to execute the newly updated `Catalog.products_with_average_ratings/1` function:

{:language="elixir"}
~~~
# lib/pento_web/live/survey_results_live.ex
defp assign_products_with_average_ratings(
      %{assigns: %{age_group_filter: age_group_filter}} =
      socket) do
  assign(
    socket,
    :products_with_average_ratings,
    Catalog.products_with_average_ratings(%{age_group_filter: age_group_filter})
  )
end
~~~

### Age Group Filter Events

Now we'll add the drop-down menu to our component's template and default the selected value to the `@age_group_filter` assignment.

We'll render a drop-down menu in a form with a Phoenix DOM element binding for the form change event. We'll also be sure to add the `phx-target` attribute, pointing to the `@myself` value, which is the unique identifier for the current component that is added to socket assigns for us, for free. This will ensure that the form change event will target the `SurveyResultsLive` component when it fired.

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web/survey_results_live.html.leex"
part="interactive_dashboard.survey_results_live.template.age_group_filter" />

We're ready to add an event handler to our component that will pattern match to handle this `"age_group_filter"` event.

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web/survey_results_live.ex"
part="interactive_dashboard.survey_results_live.handle_event.age_group_filter" />

Our event handler responds by updating the age group filter in socket assigns and then re-invoking the rest of our reducer pipeline so that it will operate on the new age group filter in socket assigns to fetch an updated list of products with average ratings before re-rendering with this new state.

Let's break this down step by step.

First, we update socket assigns `:age_group_filter` with the new age group filter from the event. We do this by implementing a new version of our `assign_age_group_filter` function with an arity of 2.

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web/survey_results_live.ex"
part="interactive_dashboard.survey_results_live.handle_event.assign_age_group_filter" />

Then, we update socket assigns `:products_with_average_ratings`, setting it to a re-fetched set of products. We do this by once again invoking our `assign_products_with_average_ratings` reducer, this time it will operate on the updated `:age_group_filter` from socket assigns.

Lastly, we update socket assigns `:dataset`, `:chart`, and `:chart_svg`, where the dataset will be constructed with our newly fetched product data. This will cause the component to re-render the chart SVG with the updated data from socket assigns.
Now, if we visit `/admin-dashboard` and select an age group filter from the drop down menu, we should see the chart render again with appropriately filtered data:

<imagedata fileref="images/interactive_dashboard/survey-results-live-chart-age-group-filtered.png" width="65%"/>

One edge case we need to account for. What happens when there are no results that meet our age group filtering conditions? Let's select an option from the drop down for which there are no product ratings. If we do this, we'll see the LiveView crash with the following error in the server logs:

{:language="elixir"}
~~~
[error] GenServer #PID<0.3270.0> terminating
** (FunctionClauseError) no function clause matching in MapSet.new_from_list/2
    (elixir 1.10.3) lib/map_set.ex:119: MapSet.new_from_list(nil, [nil: []])
    (elixir 1.10.3) lib/map_set.ex:95: MapSet.new/1
    (contex 0.3.0) lib/chart/mapping.ex:180: Contex.Mapping.missing_columns/2
    (contex 0.3.0) lib/chart/mapping.ex:166: Contex.Mapping.confirm_columns_in_dataset!/2
    (contex 0.3.0) lib/chart/mapping.ex:139: Contex.Mapping.validate_mappings/3
    (contex 0.3.0) lib/chart/mapping.ex:57: Contex.Mapping.new/3
    (contex 0.3.0) lib/chart/barchart.ex:73: Contex.BarChart.new/2
~~~

As you can see, we _can't_ initialize a Contex bar chart with an empty dataset! There are a few ways we could solve this problem, but we'll opt for the following solution. If we get an empty results set back from our `Catalog.products_with_average_ratings/1` query, then we should query for and return a list of product tuples where the first element is the product name and the second element is `0`. This will allow us to render our chart with a list of products displayed on the x-axis and no values populated on the y-axis.

Assuming we have the following query:

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento/catalog/product/query.ex"
part="interactive_dashboard.products.query_builder.with_zero_ratings" />

And context function:

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento/catalog.ex"
part="interactive_dashboard.catalog.products_with_zero_ratings" />

We can update our LiveView to implement the necessary logic:

{:language="elixir"}
~~~
# lib/pento_web/live/survey_results_live.ex
defp assign_products_with_average_ratings(
      %{assigns: %{age_group_filter: age_group_filter}} =
      socket) do
  assign(
    socket,
    :products_with_average_ratings,
    get_products_with_average_ratings(%{age_group_filter: age_group_filter})
  )
end

defp get_products_with_average_ratings(filter) do
  case Catalog.products_with_average_ratings(filter) do
    [] ->
      Catalog.products_with_zero_ratings()

    products ->
      products
  end
end
~~~

Now, if we select an age group filter for which there are no results, we should see a nicely formatted empty chart:

<imagedata fileref="images/interactive_dashboard/survey-results-live-chart-no-results.png" width="65%"/>


## Filter By Gender
The "filter by gender" code is present in the codebase. Take some time to walk-through the code, starting in the query builder and context functions in the core and boundary, and making your way up to the LiveView.

<author>Bruce, depending on how long you think this chapter is getting, I'd wondering if we should cut the following section? Although I think it is the right way to structure the code, its not an essential part of learning how to build complex interactive LiveViews.</author>

## Refactoring Chart Code with Macros
Our `SurveyResultsLive` component implements a fair bit of chart building and rendering logic in addition to handling the responsibility of managing the state of the chart that is rendered on the page. Charting logic and configuration seems out of scope for the `SurveyResultsLive` component. Furthermore, we could easily imagine wanting to re-use our bar chart drawing functionality in other components/LiveViews. Let's refactor our chart building and rendering code into a macro that we will mix into the `PentoWeb` module. We want to be able to import our bar chart rendering code into the `SurveyResultsLive` module via the call to something like `use PentoWeb, :chart_live`

First, we'll define a module `PentoWeb.BarChart` that wraps up our chart rendering logic:

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web/bar_chart.ex"
part="interactive_dashboard.barchart" />

Next up, we'll define a function, `chart_helpers/0` in the `PentoWeb` module that imports our new module:

{:language="elixir"}
~~~
defp chart_helpers do
  quote do
    # Import custom chart functionality
    import PentoWeb.BarChart
  end
end
~~~

Then, we'll implement the public function that the `PentoWeb`'s `__using__` macro definition will apply via the call to `use PentoWeb, :chart_live`.

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web.ex"
part="interactive_dashboard.pento_web.chart_live" />

You can see the `__using__` macro definition here:

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web.ex"
part="interactive_dashboard.pento_web.using" />

Now, we can add the following line to our `SurveyResultsLive` component in order to give it access to all of the functions we defined in `PentoWeb.BarChart`.

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web/live/survey_results_live.ex"
part="interactive_dashboard.survey_results_live.use_chart_live" />

And we can remove all of the chart-specific function definitions from the component module--`make_bar_chart_dataset/1`, `make_bar_chart/2` and `render_bar_chart/5`--resulting in a much cleaner component module. We just need to update our call to the `render_bar_chart/5` function to pass in to the required arguments:

<embed language="elixir"
file="code/interactive_dashboard/pento/lib/pento_web/live/survey_results_live.ex"
part="interactive_dashboard.survey_results_live.assign_chart_svg" />

Now, all of the re-usable code related to generic bar chart rendering lives in `PentoWeb.BarChart`, while the code specific to how to render the bar chart _for the survey results component_ remains in `SurveyResultsLive`. We could easily imagine our bar chart logic and configuration growing more complex--say, to accommodate custom color configuration, padding, orientation and more. Now, should we want to accommodate that increased complexity, it has a logical home here in our chart module.

Now we're ready to move on to our next features in the following chapter.

## Conclusion/Your Turn
