# Ladle
Ladle is a high performance tool for generating collaborative grocery lists.

## Goals
- Learn Go
- Learn SvelteKit
- Learn Postgres
- Learn Docker
- Learn Terraform
- Learn CI/CD
- Build a personal project that employers will be highly impressed with. I want this project to be an enterprise grade solution and for it to include most things I would encounter on a real job
- Make ordering groceries simple and efficient for my family
- Make the app extremely performant and fast with small bundles and blazingly fast interactions

## Technolgies chosen
- Go (go1.24.2 darwin/arm64)
- SvelteKit
- Postgres
- Docker
- Terraform
- Github

## Features
- Category creation
- Meal creation
- Associate categories with meals
- Associate ingredients with meals
- Associate recipes with meals
- Generate a grocery list based on a set of selected meals
- Invite users to collaborate
- Real time updates when meals are added, created, etc.

## Onboarding flow
- User signs up with their Google account
- User is prompted to add family members or other users to collaborate with
- User is prompted to enter meals
- When entering a meal, users may associate it with categories, ingredients, and a recipe

## Main user flow
- Open app
- Select the meals for their next grocery order
- Generate a grocery list

## Things that are unacceptable or out of scope
- Storing user credentials
- Payment system
- Using any tech that could cost a variable amount of money. Billing should be a fixed, predictable amount

## Unknowns
- Should ingredients be created in a centralized place or created per meal? I need to be sure that I can reconcile them when a grocery list is generated. For instance, if Meal A requires 1 onion and Meal B requires 1 onion, the generated list should output 2 onions
- What options should users have when entering ingredient amounts when associating them with meals? How can I calulate this when generating the list
- Will I just use OpenID Connect or would I use OAuth?
- How will I associate users so they can collaborate? Will I create a concept of a "Family" or something similar? Is there another way or a better way?
- Where should I host my app

## Things to accomplish in order (I'm willing to change this)
1. Setup a very basic "Hello World" app that I can run in local Docker containers with Docker compose (just the client and server, the db can come later)
2. Setup automated CI/CD pipelines to deploy the app to a production environment
3. Setup the database and deploy it to production
4. Setup authentication and authorization
5. Build the rest of the features, both UI and endpoints

## Current project structure
The current project structure is as follows, although I'd like feedback on whether this is a good way to organize the project or if I should change something. This is the general direction I have in mind but I want to learn best practices:

* client (Root of SvelteKit)
* server
    * cmd
        * ladle
            * main.go
    * internal
    * go.mod
    * go.sum
    * .air.toml
* infrastructure
    * cicd
    * docker
        * server.Dockerfile
        * client.Dockerfile
        * compose.yaml
    * terraform
* docs
* tests
* .gitignore
* README.md
