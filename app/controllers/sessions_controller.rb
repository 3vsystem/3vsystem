class SessionsController < ApplicationController


	def new
	end

	def create
		user = User.find_by(email: params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
			not_remeber = (params[:session][:not_remember_me] == '1')
			sign_in user, not_remeber
			if not_remeber
				flash[:info] = "Не запоминать"
			end
			redirect_back_or root_path
		else
		flash.now[:danger] = 'Неправильная комбинация пароля и почты'
		render 'new'
		end
	end

	def destroy
	    sign_out
	    redirect_to root_url
 	end
end

