# Keystone 6 on Railway

A simple example project showing how one might develop and deploy a [KeystoneJS 6](https://keystonejs.com)
backend using [Railway](https://railway.app?referralCode=keystonejs).

![keystone-railway 5x](https://user-images.githubusercontent.com/6447754/133543067-78333e71-a2d4-4311-9d3d-5466d5457140.png)

## Introduction

[Railway](https://railway.app?referralCode=keystonejs) is an interesting new hosting provider.
They offer Heroku-style deployments (Docker-based with "plugins" for various data stores), preview deploys, GitHub and Vercel integrations.
Unlike most hosting providers, their tooling encourages a kind of service injection that allows code run locally to use services hosted in the cloud.

The app code in this project is based heavily on the
[`with-auth` example project](https://github.com/keystonejs/keystone/tree/master/examples/with-auth) from the main
[Keystone repo](https://github.com/keystonejs/keystone).
It demonstrates some of the powerful APIs and tools Keystone provides and the gratifying developer experience it enables.

If you haven't heard about [Keystone](https://keystonejs.com), it's a powerful GraphQL-based headless CMS, written in TypeScript
It has some terrific features out of the box, is easy to extend, and a joy to use.
There's [documentation](https://keystonejs.com/docs) covering all the
[APIs](https://keystonejs.com/docs/apis) and
[field types](https://keystonejs.com/docs/apis/fields) used in this project, as well as
[guides](https://keystonejs.com/docs/guides) to take you further.

If you get stuck, hit us up on the [KeystoneJS Slack](https://community.keystonejs.com) and search (or post) under the
[`[keystonejs]` tag](https://stackoverflow.com/questions/tagged/keystonejs) on Stack Overflow.

## Railway's Different

Most hosting providers concern themselves only with how your app is run once deployed on their servers.
If the app is dependant on other services – like a database server and maybe a session store – developers need to maintain or substitute these locally when developing.
This can lead to differences in configuration and software versions which introduces hard-to-find bugs.

It's possible develop in this way and still host your app on Railway but the Railway CLI gives you another option.
The `railway run` command makes it trivial to execute your app code _locally_ while utilising services hosted _remotely_.
This is achieved by injecting the same environment variables used when your app in that online environment,
partially simulating a production deployment from the comfort of your local machine.

The workflow this facilitates has a some benefits.
In many cases it simplifies the setup of dev environments and prevents some of the version mismatch issues described above.
It also allows developers to share a common set of services (eg. a database) which can be useful for testing and reproducing each others errors.

There are, however, also downsides.
The approach does introduce latency – your local app is now communicating with remotely hosted services so things like DB queries take a much longer round trip.
Sharing a database with the other developers on your team isn't always a plus and, since these are hosted services, they do cost money to run.

Regardless, the Railway tooling works well with this pattern so we'll use it in the instructions below.

## Deploying to Railway

By the end of this process you'll have a complete dev and deployment workflow up and running, including:

* A copy of this repo in your own GitHub account and cloned to your local machine (with your GitHub repo as the origin)
* A Railway account hosting a deployment of this app
* The ability to make and test changes locally
* The ability to deploy changes by pushing to GitHub

Thanks to some behind-the-scenes magic it only takes a few clicks and commands to set this all this up!

### 1. The Button

This button kicks off a process that automatically creates many of the resources we'll need.
You don't need an existing Railway account or a credit card, all you need is a GitHub account.

It's best to <kbd>Cmd⌘</kbd>-click the button so it opens in a new tab so.
That'll let you easily refer back to this guide as you progress.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template?template=https%3A%2F%2Fgithub.com%2Fkeystonejs%2Fkeystone-6-railway-example&plugins=postgresql&envs=SESSION_SECRET&optionalEnvs=SESSION_SECRET&SESSION_SECRETDesc=A+secret+key+for+verifying+the+integrity+of+signed+cookies&referralCode=keystonejs)

First, you'll be prompted to authenticate on Railway using your GitHub account and authorise Railway to access your GitHub repos.
This lets Railway create a new repo in your GitHub account with a copy of this example code.
Railway then takes the app code (from your new repo), builds and deploys it, along with the a Postgres plugin for the database.

Next, you'll be prompted to enter a name for your new repo and set a value for the `SESSION_SECRET` environment variable.
Strickly speaking the `SESSION_SECRET` is optional but, if no value is set, a random value will be generated on each app start which resets existing sessions.

When the build and deploy process is finished, open the public URL shown.
Don't be fooled by `⭐️ Server Ready on http://localhost:6067` line in the deploy log, that's internal.
The domain you're looking for will be in the format `${PROJECT_ID}.up.railway.app`.
As the database is empty, when Keystone loads, you'll be prompted to set a username and password for the initial admin user account.

And thats it – you've deployed a Keystone backend to Railway! ✨

If all you want to do is see Admin UI and play with items you can stop here.
Railway offers [$5 of monthly usage for free](https://railway.app/pricing?referralCode=keystonejs) giving you plenty of time to poke around.
If the $5 amount is exceeded the project goes into an "idle" state until the next calendar month.

Otherwise, continue to see how local dev and redeployments work.

### 2. Prerequisites

Ensure you have the following tools installed:

* [git](https://git-scm.com/downloads)
* [NodeJS](https://nodejs.org/en/download) (v14.13 or higher)
* [Yarn](https://classic.yarnpkg.com/en/docs/install) (or `npm` will also work)
* [Railway CLI](https://docs.railway.app/develop/cli)

If you're on MacOS and use [Homebrew](https://brew.sh), you can install all these at once:

```sh
# Install the prerequisite tools
brew install git node yarn railwayapp/railway/railway
```

If you're on a different platform, click though the links above and follow the relevant instructions.

### 3. Local Development

Once the prerequisites are installed we need to download the app code.
Early in step 1, Railway copied the code for this app to a new repo in your _own_ GitHub account.
It's important we use that new repo in this step (not the original in the `keystonejs` org) as the new repo has the hooks you'll use to trigger redeployments later on.

Open the new GitHub repo in your browser, then clone it to your local machine and switch your working directory to the project root.
Assuming you've [added an SSH key](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
to your GitHub account, the commands you'll need will looks something like this:

```sh
# Replace "molomby" and "my-keystone6-railway-app" with your GitHub username and the repo name you entered earlier
git clone git@github.com:molomby/my-keystone6-railway-app.git
cd my-keystone6-railway-app
```

Next, install the node modules:

```sh
# We prefer yarn but `npm install` should also work
yarn
```

At this point, you'd _usually_ run `yarn dev` to start Keystone in [dev mode](https://keystonejs.com/docs/guides/cli#dev).
If you have a PostgreSQL installed and running locally this will still work but instead, this guide will use the Railway CLI to start the app in a more idiomatic way.

### 4. Link to Railway

Unless you've used the Railway CLI before, you'll need to authenticate it against your Railway account:

```sh
# This will open a browser window to authenticate you
railway login
```

Next, link your local codebase to the existing Railway project:

```sh
# Replace "my-keystone6-railway-app" with your Railway project ID
railway link my-keystone6-railway-app
```

### 5. Start The App

You can now use the [`railway run` command](https://docs.railway.app/develop/cli#run) to run your local code inside your default Railway environment.
Let's use it to start the app:

```sh
# Runs your local code (in dev mode) against a Railway-hosted database
railway run yarn dev
```

The output should look something like this...

```
yarn run v1.22.10
$ keystone-next dev
✨ Starting Keystone
⭐️ Dev Server Ready on http://localhost:3000
✨ Generating GraphQL and Prisma schemas
✨ Your database is up to date, no migrations need to be created or applied
✨ Connecting to the database
✨ Generating Admin UI code
✨ Creating server
✨ Preparing GraphQL Server
✨ Preparing Admin UI Next.js app
info  - Using webpack 4. Reason: custom webpack configuration in next.config.js https://nextjs.org/docs/messages/webpack5
event - compiled successfully
👋 Admin UI and GraphQL API ready
```

Point your browser to [localhost:3000](http://localhost:3000) and you'll be greeted by the Keystone Admin UI sign in screen.
If you've followed this guild from the start, you should be able to sign in using the email address and password you created earlier when you first accessed your deployment on Railway.

### 6. Multiple Environments

It's ok for an example project like this but, generally, you wouldn't want to develop and test against your live database.
Railway addresses this by letting you create and switch between multiple [environments](https://docs.railway.app/develop/environments)
in the same project using the CLI:

```sh
# Create a new environment called "development" and switch the CLI to it
railway environment development
```

Remember though, resource and plugins are duplicated for each environment so do contribute to your monthly spend.

## Extending This App

This app is extremely simple –
it has only a two lists and intentionally avoids the more advanced Keystone functionality (like
[hooks](https://keystonejs.com/docs/guides/hooks), the
[document field](https://keystonejs.com/docs/guides/document-fields),
[access control](https://keystonejs.com/docs/guides/access-control), etc.).
This has let us organised most of the Keystone code into two files:

* `schema.ts` defines the [Keystone schema](https://keystonejs.com/docs/apis/schema) –
the set of lists, fields and relationships on which your Keystone app operates.
* `keystone.ts` controls the [system configuration](https://keystonejs.com/docs/apis/config) –
how Keystone runs and connects to other services, as well as authentication and sessions.

You'll need to restart the Keystone process before changes made to the source code are reflected in the app.
To do so simply stop the process (<kbd>Ctrl</kbd> + <kbd>c</kbd>) and re-run `railway run yarn dev` (or `yarn dev` if you're using a local DB).

### Redeployments

The repo Railway created in your GitHub account has been configured with hooks that trigger a deployment anytime changes are pushed.
Just commit and push your changes as normal then see the Railway dashboard for your project for deploy logs.

You can manage this behaviour (to, for example, deploy from a different branch) from the Railway dashboard under "Deployments" > "Triggers".

## Migrations

If you're developing an app, sooner or later, you're going to need to change the database structure.

When your app first ran on Railway in step 1, Keystone created the initial DB structure by applying the SQL in the `/migrations/20210825070616_initial_schema` directory.
This migration was generated by Keystone based on the contents of `schema.ts`.
You can leverage this same functionality to create your own migrations.

For example, lets open `schema.ts` and add a `phone` field to the Person list, like this:

```js
Person: list({
  fields: {
    name: text({ isRequired: true }),
    phone: text(),  // <- New!

    // Existing fields ...
  },
});
```

Re-running `railway run yarn dev` (or `yarn dev`) will prompt us to create and apply a migration representing this change:

```
✨ There has been a change to your Keystone schema that requires a migration
✔ Name of migration … adding phone numbers
✨ A migration has been created at migrations/20210825230709_adding_phone_numbers
✔ Would you like to apply this migration? … yes
✅ The migration has been applied
```

Behind the scenes, this magic is being performed by
[Prisma](https://www.prisma.io) and [Prisma Migrate](https://www.prisma.io/docs/concepts/components/prisma-migrate).
The resultant SQL (in `/migrations`) can be committed to git like any other file.
Once it's applied, your database, GraphQL schema and Admin UI will all reflect the updated list schema.

This codebase is setup to automatically applied outstanding migrations as part of the build process executed by Railway.
You can see this in `package.json` – the `build` script is `keystone-next build && keystone-next prisma migrate deploy`.

In practise this means database changes are run against your Railway database a short time before the new version of the application is rolled out.
As such, you should ensure your database changes are backwards compatible with the previous release of your app (or risk runtime errors while the deployments are occurring).
It also means you should be very careful if ever want to run `railway run yarn build` as this will attempt to apply any outstanding migrations to whichever Railway environment you're currently using.

There are many strategies for deploying and coordinating app updates and migrations.
The approach we've taken here is simple and works sufficiently well for this infrastructure setup but your app may have different needs.
See the [CLI docs](https://keystonejs.com/docs/guides/cli) for the underlying commands used.

## Next Steps

For ideas on what's possible with Keystone,
see the [guides](https://keystonejs.com/docs/guides) section of the website,
checkout the [roadmap](https://keystonejs.com/updates/roadmap) and
stay tuned to the project [updates](https://keystonejs.com/updates).
