![CI](https://github.com/adnir-andrade/restaurant-api/actions/workflows/ci.yml/badge.svg)
![Ruby](https://img.shields.io/badge/Ruby-3.4.2-red)
![Rails](https://img.shields.io/badge/Rails-8.0.2-red)

# Restaurant API

A Rails API for managing restaurant menus and menu items, as part of a coding challenge.

## Features

- [x] Level 1
    - Manage restaurant menus and their items
    - CRUD endpoints for `Menu` and `MenuItem`
    - Assign a menu item to a specific menu
    - Validations for required attributes
    - Structured JSON responses using serializers
    - Comprehensive test coverage with RSpec


- [x] Level 2
    - Register restaurants and assign multiple menus to each restaurant
    - Create `MenuItems` and associate them with multiple menus as needed
    - CRUD endpoints for `Restaurant`, `Menu` and `MenuItems`
    - List all `Restaurants`, `Menus`, and `MenuItems`
    - List all menus of a specific `Restaurant`
    - List all menu items of a specific `Menu`
    - List all menus a specific `MenuItem` belongs to
    - Validations for unique `MenuItem` names and `Menu` names within a given `Restaurant`
    - Even more tests to verify functionalities

___

## Getting Started

1. Clone the repo:
   ```bash
   git clone git@github.com:adnir-andrade/restaurant-api.git

2. Install dependencies:
   ```bash
   bundle install

3. Initiate container containing a postgres DB
   ```bash
   docker compose up -d
   ```

4. Setup the database
   ```bash
   rails db:create db:migrate
   ```

___

## Commands

### Lint

To run the linter, simply use:

   ```bash
   bundle exec rubocop
   ```

### Tests

To run the test suite, use:

   ```bash
   bundle exec rspec
   ```

___

## Endpoints

### Restaurants

| Method | Path             | Description                                 |
|--------|------------------|---------------------------------------------|
| GET    | /restaurants     | List all restaurants and the menus they own |
| GET    | /restaurants/:id | Show a single restaurant and its menus      |
| POST   | /restaurants     | Create a new restaurant                     |
| PATCH  | /restaurants/:id | Update a restaurant                         |
| DELETE | /restaurants/:id | Delete a restaurant                         |

### Menus

| Method | Path             | Description              |
|--------|------------------|--------------------------|
| GET    | /menus           | List all menus           |
| GET    | /menus/:id       | Show a single menu       |
| GET    | /menus/:id/items | List all items in a menu |
| POST   | /menus           | Create a new menu        |
| PATCH  | /menus/:id       | Update a menu            |
| DELETE | /menus/:id       | Delete a menu            |

### MenuItems

| Method | Path                                    | Description                                         |
|--------|-----------------------------------------|-----------------------------------------------------|
| GET    | /menu_items                             | List all menu items and the menus they belong to    |
| GET    | /menu_items/:id                         | Show a single menu item and the menus it belongs to |
| POST   | /menu_items                             | Create a new menu item                              |
| POST   | /menu_items/:id/assign_to_menu/:menu_id | Assign a menu item to a specific menu               |
| PATCH  | /menu_items/:id                         | Update a menu item                                  |
| DELETE | /menu_items/:id                         | Delete a menu item                                  |