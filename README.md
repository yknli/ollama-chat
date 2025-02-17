# Ollama Chat
A playground to chat with Ollama models.

## Prerequisites

- Ollama
- RVM

To run Ollama, you can simply use Docker Compose:

```sh
docker compose up -d
```

To install LLM models using the Ollama Docker container:

```sh
docker exec -it ollama ollama run llama3.2-vision:11b
```

To install RVM, follow the instructions on the [official site](https://rvm.io/).

## Installation

To install Ruby 3.3.1 using RVM:

```sh
rvm install 3.3.1
rvm use 3.3.1 --default
```

To install dependencies using Bundler:

```sh
bundle install
```

To install JavaScript dependencies using Yarn (for compiling assets):

```sh
yarn install
```

To setup database schema:

```
bin/rails db:create db:migrate
```

To fetch credentials from AWS SSM Parameter Store:

```
. ./script/master_key.sh
```

To setup pre-commit checks:

```
# install pre-commit command
gem install pre-commit

# setup custom pre-commit hooks
. ./script/install_hooks.sh
```

Now `pre-commit` checks should be executed for checking following issues when you commit changes:
- pry
- merge_conflict
- rubocup
- rspec

## Running the Application

To start the application, you can use one of the following commands:

```sh
bin/dev
```
**Note: `bin/dev` will compile assets automatically before starting the server.**

or

```sh
rails server
```

After running the application, you should see the service page in your browser, which looks like the image below:

![Service Page](doc/images/screenshot.png)
