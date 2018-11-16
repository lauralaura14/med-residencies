require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
		set :session_secret, "password_security"
  end

  get '/' do
    erb :index
  end

  helpers do
    def current_applicant
      Applicant.find(session[:applicant_id])
    end

    def logged_in?
      !!session[:applicant_id]
    end
  end



  get '/entries/new' do
    if logged_in?
      erb :'/entries/create_entry'
    else
      redirect to "/login"
    end
  end

  get '/entries' do
    if logged_in?
      @entries = Entry.all
      erb :'/entries/entries'
    else
      redirect to "/login"
    end
  end

  get '/entries/:id' do
    if logged_in?
      @entry = Entry.find_by_id(params[:id])
      erb :'/entries/show_entry'
    else
      redirect to "/login"
    end
  end

  get '/entries/:id/edit' do
    if logged_in?
      @entry = Entry.find_by_id(params[:id])
      if @entry && @entry.applicant_id == current_applicant.id
        erb :'entries/edit_entry'
      else
        redirect to "/entries"
      end
    else
      redirect to "/login"
    end
  end

  post '/entries' do
    if logged_in? && params[:name] != "" && params[:field] != "" && params[:content] != ""
      @entry = Entry.create(:name => params[:name], :field => params[:field], :content => params[:content], :applicant_id => session[:applicant_id])
      redirect to "/entries/#{@entry.id}"
    else
      redirect to "/entries/new"
    end
  end

  patch '/entries/:id' do
    if logged_in?
      if params[:name] == "" || params[:name] == nil || params[:field] == "" || params[:field] == nil || params[:content] == "" || params[:content] == nil
        redirect to "/entries/#{params[:id]}/edit"
      else
        @entry = Entry.find_by_id(params[:id])
        if @entry && @entry.applicant_id == current_applicant.id
          if @entry.update(:name => params[:name], :field => params[:field], :content => params[:content], :applicant_id => session[:applicant_id])
            redirect to "/entries/#{@entry.id}"
          else
            redirect to "/entries/#{@entry.id}/edit"
          end
        else
          redirect to "/entries"
        end
      end
    else
      redirect to "/login"
    end
  end

  delete '/entries/:id/delete' do
    if logged_in?
      @entry = Entry.find_by_id(params[:id])
      if @entry && @entry.applicant_id == current_applicant.id
        @entry.delete
      end
      redirect to "/entries"
    else
      redirect to "/login"
    end
  end



  get '/signup' do
    if logged_in?
      redirect to "/entries"
    else
      erb :'/applicants/create_applicant'
    end
  end

  get '/login' do
    if logged_in?
      redirect to "/entries"
    else
      erb :'/applicants/login'
    end
  end

  post '/signup' do
    if params[:username] == "" || params[:email] == "" || params[:password] == ""
      redirect to "/signup"
    else
      @applicant = Applicant.create(:username => params[:username], :email => params[:email], :password => params[:password])
      @applicant.save
      session[:applicant_id] = @applicant.id
      redirect to "/entries"
    end
  end

  post '/login' do
    @applicant = Applicant.find_by(:username => params[:username])
    if @applicant && @applicant.authenticate(params[:password])
      session[:applicant_id] = @applicant.id
      redirect to "/entries"
    else
      redirect to "/login"
    end
  end

  get '/logout' do
    applicant = Applicant.find_by(:username => params[:username])
    if logged_in?
      session.clear
      redirect to "login"
    else
      redirect to "/"
    end
  end

  get '/applicants/:slug' do
     @applicant = Applicant.find_by_slug(params[:slug])
     erb :'/applicants/show'
  end

end
