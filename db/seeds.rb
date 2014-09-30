# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


## To re-create and re-seed database (including test fixtures)
# bundle exec rake db:drop; bundle exec rake db:create; bundle exec rake db:migrate; bundle exec rake db:fixtures:load RAILS_ENV=development; bundle exec rake db:seed;

unless Rails.env == "test"



  # Initialize Piotr and Sean User Accounts

  if !(user = User.find_by_email("piotr.mankowski@gmail.com"))
    user = User.new(email: "piotr.mankowski@gmail.com", password: "12345678")
    user.validic_id = "54293ab084626b96a4000047"
    user.validic_access_token = "qxmyhv-tcgzgtZEWVsfJ"
    user.oodt_id = "urn:uuid:39fc580b-8a1a-56a8-931d-42f908fc9ea8"
    user.save
    user.add_role :admin
    user.add_role :owner
  end

  if !(user = User.find_by_email("seanahrens@gmail.com"))
    user = User.new(email: "seanahrens@gmail.com", password: "password")
    user.validic_id = "542a6e4784626b85f10000c3"
    user.validic_access_token = "vznvLEEa_pvCamSHecMT"
    user.oodt_id = "urn:uuid:d363b4d5-db42-5434-ad0e-63a2495c9f4c"
    user.save
    user.add_role :admin
    user.add_role :owner
  end


  lorem = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\nLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."


  # Research Topics
  ResearchTopic.create(user: User.first, text: "How many people with this condition have mothers who have over thyroidism?", description: lorem)
  ResearchTopic.create(user: User.second, text: "How many seed questions does it take for this to look like an active app?", description: lorem)

  # Blog Posts
  Post.create(user: User.first, title: "This is a Blog Post", body: lorem, state: "accepted", post_type: "blog")
  Post.create(user: User.second, title: "This is a Blog Post", body: lorem, state: "accepted", post_type: "blog")

  # Notifications
  Post.create(user: User.second, title: "Short Notification", body: "This is an example of a short notification.", state: "accepted", post_type: "notification")
  Post.create(user: User.first, title: "Longer Notification Title This Is", body: "This is an example of a slightly longer notification that might be a little bigger that a short one.", state: "accepted", post_type: "notification")



  # Forum
  if Forem::Category.count == 0

    Forem.decorate_user_class!

    Forem::Category.create(:name => 'General')

    #user = Forem.user_class.first

    unless user.nil?
      forum = Forem::Forum.find_or_create_by(:category_id => Forem::Category.first.id,
                                             :name => "Introductions",
                                             :description => "Are you new to the site? Stop in and say hi!")

      post = Forem::Post.find_or_initialize_by(text: "OpenPPRN is all about you—the patients and caregivers and what is most important to you. We want to hear from you, we want you to share your thoughts about how you would like to interact with one another as well as with researchers and health care providers within this space. Thank you for helping to build a better MyApnea.Org!")
      post.user = user

      topic = Forem::Topic.find_or_initialize_by(subject: "We want to hear from you! What do you want this space to offer?")
      topic.forum = forum
      topic.user = user
      topic.posts = [ post ]

      topic.save!
    end
  end






  # Question Generation

  if Question.count == 0

    # Drop Survey Tables
    to_keep = [ "users", "schema_migrations"]
    tables = [
        "answer_edges",
        "answer_options",
        "answer_options_answer_templates",
        "answer_sessions",
        "answer_templates",
        "answer_templates_questions",
        "answer_values",
        "answers",
        "comments",
        "display_types",
        "groups",
        "posts",
        "question_edges",
        "question_flows",
        "question_help_messages",
        "questions",
        "units",
        "votes"
    ]

    tables.each do |table|
      ActiveRecord::Base.connection.execute("TRUNCATE #{table}")
      ActiveRecord::Base.connection.execute("SELECT SETVAL('#{table}_id_seq', 100000000)")
    end


    files = [
        ["units.yml", Unit],
        ["groups.yml", Group],
        ["display_types.yml", DisplayType],
        ["answer_options.yml", AnswerOption],
        ["answer_templates.yml", AnswerTemplate],
        ["question_help_messages.yml", QuestionHelpMessage],
        ["questions.yml", Question],
        ["question_flows.yml", QuestionFlow]
    ]

    files.each do |file_name, model_class|
      file_path = Rails.root.join('lib', 'data', 'surveys', file_name)

      puts(file_path)

      yaml_data = YAML.load_file(file_path)

      yaml_data.each do |object_attrs|
        puts object_attrs
        model_class.create(object_attrs)
      end
    end

    qe_path = Rails.root.join('lib', 'data', 'surveys', 'question_edges.yml')
    puts(qe_path)

    yaml_data = YAML.load_file(qe_path)

    yaml_data.each_with_index do |attrs, i|

      q1 = Question.find(attrs['parent_question_id'])
      q2 = Question.find(attrs['child_question_id'])

      qe = QuestionEdge.build_edge(q1, q2, attrs['condition'], attrs['question_flow_id'])

      puts("Creating edge #{i} of #{yaml_data.length} between #{q1.id} and #{q2.id}")
      raise StandardError, qe.errors.full_messages unless qe.save
    end

    QuestionFlow.all.each {|qf| qf.reset_paths }

  end


end
