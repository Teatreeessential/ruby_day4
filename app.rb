require 'sinatra'
require 'sinatra/reloader'
require 'rest-client'
require 'nokogiri'
require 'json'
require 'csv'
require 'uri'

get '/boards/new' do
    erb :form
end

post '/boards/create' do
    #사용자가 입력한 정보를 받아서 
    #csv 파일 가장 마지막에 등록 
    # =>이 글의 글번호도 같이 저장해야하는데
    # 기존의 글 갯수를 파악해서
    # 글개수 + 1해서 저장
    title = params[:title]
    contents = params[:contents]
    id = CSV.read('./boards.csv').count + 1
    CSV.open('./boards.csv','a+') do |row|
        row << [id,title,contents]
    end
    redirect '/boards'
end

get '/boards' do
    #파일을 열고 
    #각 줄 마다 순회하면서
    #@가 붙어있는 변수에 넣어줌
    @boards = []
    CSV.open('./boards.csv','r+').each do |row|
        @boards << row
    end
    erb:boards
end

get '/board/:id' do
    #CSV 파일에서 params[:id] 로 넘어온 친구와 같은 글번호를 가진 row를 선택
    #=>csv 파일을 전체 순회 합니다. 
    #=>순회 하다가 첫번째 column이 id와 같은 값을 만나면 순회를 정지하고 값을 변수에 담아 줍니다.
    @board = []
    CSV.read('./boards.csv').each do |row|
        if row[0]==params[:id]
            @board = row
            break
        end
    end
    erb:board
end




get '/user/new' do
    erb:new_user
end

post '/user/create' do
    id = params[:id]
    password = params[:password]
    password_confirm = params[:password_confirm]
    
    users_id = []
    
    CSV.open('./user.csv','r+').each do |row|
        users_id << row[0]
    end    
        
    unless users_id.include?(id)    
        if(password==password_confirm)
            CSV.open('./user.csv','a+') do |row|
                row << [id,password]
            end
            redirect '/users'
        else
            @msg="비밀번호를 다시 확인해주세요!"
            erb:err
        end
    else
        @msg="동일한 아이디가 존재합니다."
        erb:err
    end
        
    
end

get '/users' do
    
    @users = []
        CSV.open('./user.csv','r+').each do |row|
            @users << row 
        end
    erb:users
end

get '/users/:id' do
    
    @id =nil
    
    CSV.open('./user.csv','r+').each do |row|
        if(row[0]==params[:id])
           @id = row[0]
           break
        end
    end
    
    if(@id!=nil) 
        erb:user
    else
        @msg="해당 유저는 존재하지 않습니다."
        erb:err
    end
end