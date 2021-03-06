require 'mechanize'
require 'pp'

module PoemPoster
  def post_poem(poem)
    return if poem.empty?
    new_post_form = post_new_page.forms.first
    new_post_form.field_with(name: 'post[content]').value = poem

    new_post_form.submit
  end

  def post_new_page
    pplog_home_page = pplog_home_page
    pplog_home_page.link_with(href: '/my/posts/new').click
  end

  def user_name
    YAML.load_file('login.yml')['user_name']
  end

  def password
    YAML.load_file('login.yml')['password']
  end

  def pplog_zapped_page
    url = zapping_url
    @a ||= Mechanize.new
    @a.get(url)
  end

  def zapping_url
    'https://www.pplog.net/zapping'
  end

  def pplog_home_page # 1 -> access_twitter_page
    # Run authorize
    access_twitter_page
    login_to_twitter
    pass_confirmation

    @pplog_home_page
  end

  def access_twitter_page # 2 -> login_to_twitter
    a = Mechanize.new
    # request login page
    url = 'https://www.pplog.net/users/auth/twitter'
    @twitter_page = a.get(url)
  end

  def login_to_twitter # 3 -> pass_confirmation
    # submitting login info
    auth_form = fillup_auth_form
    submit_auth_form(fillup_auth_form)
    auth_form
  end

  def fillup_auth_form
    auth_form = @twitter_page.forms.first
    user_name = user_name
    password  = password
    auth_form.field_with(name: 'session[username_or_email]').value = user_name
    auth_form.field_with(name: 'session[password]').value = password
    auth_form
  end

  def submit_auth_form(auth_form)
    submit_button = auth_form.buttons.first
    @auth_confirm_page = auth_form.submit(submit_button)
  end

  def pass_confirmation # 4 -> return pplog_page
    # allow authorize
    expression = { text: 'click here to continue' }
    pplog_page = @auth_confirm_page.link_with(expression).click
    fail 'Login Failed' if pplog_page.nil?

    @pplog_home_page = pplog_page
  end
end
