Feature: Basic Svelte Slabs
  As a user of Jekyll and Svelte
  I want to be able to pass data to my svelte components
  Using liquid tags
  So that I don't have to think about the data pipeline

  Background:
    Given the file tree:
      """
      site/
        Gemfile from starters/jekyll/Gemfile
        Gemfile.lock from starters/jekyll/Gemfile.lock
      """

  Scenario: Default Svelte Slabs Handling
    Given a site/_config.yml file containing:
      """
      title: "Svelte Slabs Default"
      """
    Given a site/index.html file containing:
      """
      ---
      hero: "Hello World"
      ---
      {% svelte hero title=page.hero %}
        <p>Pre-rendered content</p>
      {% endsvelte %}
      """
    When I run "bundle exec jekyll build" in the site directory
    Then stderr should be empty
    And stdout should not be empty
    And site/_site/index.html should leniently contain each row:
      | text |
      | <p>Pre-rendered content</p> |
      | window.svelteSlabs["200286e523d72d7933038f6e4943c92e"] = { "title" : "Hello World" }; |
      | data-svelte-slab="hero" |
      | data-svelte-slab-props="window:200286e523d72d7933038f6e4943c92e" |

  Scenario: Svelte Slabs Bind Property
    Given a site/_config.yml file containing:
      """
      title: "Svelte Slabs Default"
      """
    Given a site/index.html file containing:
      """
      ---
      obj:
        a: 1
        b: 2
      ---
      {% svelte card bind=page.obj %}
        <p>Pre-rendered content</p>
      {% endsvelte %}
      """
    When I run "bundle exec jekyll build" in the site directory
    Then stderr should be empty
    And stdout should not be empty
    And site/_site/index.html should leniently contain each row:
      | text |
      | { "a" : 1 , "b" : 2 }; |

  Scenario: Base64 Svelte Slabs Handling
    Given a site/_config.yml file containing:
      """
      title: "Svelte Slabs Default"
      svelte_slabs:
        method: window_b
      """
    Given a site/index.html file containing:
      """
      ---
      hero: "Hello World"
      ---
      {% svelte hero title=page.hero %}
        <p>Pre-rendered content</p>
      {% endsvelte %}
      """
    When I run "bundle exec jekyll build" in the site directory
    Then stderr should be empty
    And stdout should not be empty
    And site/_site/index.html should leniently contain each row:
      | text |
      | window.svelteSlabs["9e8eb8da4fb88c99f26db20de7c563d2"] = "eyJ0aXRsZSI6IkhlbGxvIFdvcmxkIn0=" |
      | data-svelte-slab="hero" |
      | data-svelte-slab-props="window_b:9e8eb8da4fb88c99f26db20de7c563d2" |

  Scenario: Escaped Svelte Slabs Handling
    Given a site/_config.yml file containing:
      """
      title: "Svelte Slabs Default"
      svelte_slabs:
        method: window_e
      """
    Given a site/index.html file containing:
      """
      ---
      embed: "<script>console.log('inner');</script>"
      ---
      {% svelte embed embed=page.embed %}
        <p>Pre-rendered content</p>
      {% endsvelte %}
      """
    When I run "bundle exec jekyll build" in the site directory
    Then stderr should be empty
    And stdout should not be empty
    And site/_site/index.html should leniently contain each row:
      | text |
      | window.svelteSlabs["4741ab40159c574e5fe4e2f57f1033ff"] = `{"embed":"&rawlt;script>console.log('inner');&rawlt;/script>"}`; |
      | data-svelte-slab="embed" |
      | data-svelte-slab-props="window_e:4741ab40159c574e5fe4e2f57f1033ff" |

  Scenario: Endpoint Svelte Slabs Handling
    Given a site/_config.yml file containing:
      """
      title: "Svelte Slabs Default"
      svelte_slabs:
        method: endpoint
      """
    Given a site/index.html file containing:
      """
      ---
      hero: "Hello World"
      ---
      {% svelte hero title=page.hero %}
        <p>Pre-rendered content</p>
      {% endsvelte %}
      """
    When I run "bundle exec jekyll build" in the site directory
    Then stderr should be empty
    And stdout should not be empty
    And site/_site/index.html should not contain the text "Hello World"
    And site/_site/index.html should leniently contain each row:
      | text |
      | data-svelte-slab="hero" |
      | data-svelte-slab-props="endpoint:200286e523d72d7933038f6e4943c92e" |
    And site/_site/_slabs/200286e523d72d7933038f6e4943c92e.json should leniently contain each row:
      | text |
      | { "title" : "Hello World" } |
