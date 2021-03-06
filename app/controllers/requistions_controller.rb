class RequistionsController < ApplicationController
	before_action :signed_in_user, except: [:count, :count_all]
	before_action :admin_user, only: [:index, :edit, :update]
	before_action :client_user, only: [ :mark]

	autocomplete :building, :arrival_address, :full => true

	def count
		render text: Requistion.fresh.count.to_s
	end

	def count_all
		render :json => { :count => Requistion.fresh.count.to_s}
	end

	def show
		@requistion = Requistion.find(params[:id])
	end

	def to_take_in_work
		@requistion = Requistion.find(params[:id])
		if @requistion.update_attributes(
			status: "adopted_in_work", time_adopted_in_work: Time.zone.now.to_s, who_adopted: current_user.id)
			flash[:success] = "Заявка принята в разработку"
			redirect_to @requistion
		end
	end

	def close
		@requistion = Requistion.find(params[:id])
		if @requistion.update_attributes(
			status: "completed", time_completed: Time.zone.now.to_s, who_comleted: current_user.id)
			flash[:success] = "Заявка завершена"
			redirect_to @requistion
		end
	end

	def done
		@requistion = Requistion.find(params[:id])
		if @requistion.update_attributes(
			status: "done", time_done: Time.zone.now.to_s, who_done: current_user.id)
			flash[:success] = "Заявка закончена"
			redirect_to @requistion
		end
	end

	def cancel
		@requistion = Requistion.find(params[:id])
		render "cancel"

	end

	def canceldone
		r = Requistion.find(params[:id])
		r.cancel(current_user.id, params[:subject])
	end


	def mark
		@requistion = Requistion.find(params[:id])
		@requistion.update_attribute( :raiting, params[:mark])
		flash[:success] = "Оценка поставлена"
		redirect_to requistion_path(@requistion)
	end

	def change_status
		@requistion = Requistion.find(params[:id])
		@requistion.update_attribute( :status, params[:status])
		case params[:status]
			when "fresh"
				@requistion.update_attributes(
					created_at: Time.zone.now.to_s, who_created: current_user.id)
			when "assigned"
				@requistion.update_attributes(
					time_assgned: Time.zone.now.to_s, who_assigned: current_user.id)
			when "adopted_in_work"
				@requistion.update_attributes(
					time_adopted_in_work: Time.zone.now.to_s, who_adopted: current_user.id)
			when "running"
				@requistion.update_attributes(
					time_running: Time.zone.now.to_s, who_running: current_user.id)
			when "done"
				@requistion.update_attributes(
					time_done: Time.zone.now.to_s, who_done: current_user.id )
			when "completed"
				@requistion.update_attributes(
					time_completed: Time.zone.now.to_s, who_comleted: current_user.id)
			when "canceled"
				@requistion.update_attributes(
					time_canceled: Time.zone.now.to_s, who_cancel: current_user.id)
			end
		flash[:success] = "Статус изменен"
		redirect_to requistion_path(@requistion)
	end

	def view_change_time

		def tostr(time)
			if time
				Russian::strftime(time, " %e %B %Y %H:%M")
			else
				""
			end
		end
		r = Requistion.find(params[:id])
		if r.who_cancel
			link_cancel = "<a href='#{user_path(r.who_cancel)}'>"+User.find(r.who_cancel).name+"</a>"
		end
		if r.who_running
			link_running = "<a href='#{user_path(r.who_running)}'>"+User.find(r.who_running).name+"</a>"
		end
		if r.who_created
			link_created = "<a href='#{user_path(r.who_created)}'>"+User.find(r.who_created).name+"</a>"
		end
		if r.who_assigned
			link_assigned = "<a href='#{user_path(r.who_assigned)}'>"+User.find(r.who_assigned).name+"</a>"
		end
		if r.who_done
			link_done = "<a href='#{user_path(r.who_done)}'>"+User.find(r.who_done).name+"</a>"
		end
		if r.who_comleted
			link_comleted = "<a href='#{user_path(r.who_comleted)}'>"+User.find(r.who_comleted).name+"</a>"
		end
		if r.who_adopted
			link_adopted = "<a href='#{user_path(r.who_adopted)}'>"+User.find(r.who_adopted).name+"</a>"
		end

		render :json => {
			time:{
				:created   => tostr(r.created_at),
				:assigned  => tostr(r.time_assgned),
				:adopted   => tostr(r.time_adopted_in_work),
				:running   => tostr(r.time_running),
				:done      => tostr(r.time_done),
				:completed => tostr(r.time_completed),
				:deadline  => tostr(r.time_deadline),
				:canceled  => tostr(r.time_canceled)
			},
			user:{
				:canceled  => link_cancel,
				:running => link_running,
				:created  => link_created,
				:assigned => link_assigned,
				:done  => link_done,
				:comleted => link_comleted,
				:adopted => link_adopted
			}
		}
	end

	def create
		@requistion = Requistion.new(requistions_params)
		@requistion.who_created = current_user.id
		if @requistion.save
			if current_user.admin?

				pairs = @requistion.pairs
				all_workers_id = Array(params[:workers])
				unless all_workers_id.empty?
					@requistion.update_attribute :status, 'assigned'
				end
				all_workers_id.each do |worker|
					pairs.find_or_create_by(user_id: worker)
				end
			end

			flash[:success] = "#{params[:worker]}"
			current_user.pairs.create!(requistion_id: @requistion.id)
			#if (current_user.phone != "")
				# message = MainsmsApi::Message.new(sender: '3B-online',
				# 	message: 'Ваша заявка №'+@requistion.id.to_s+' принята',
				# 	recipients: [current_user.phone])
				# response = message.deliver
			#end
			#UserMailer.new_reqistion(current_user).deliver
			#UserMailer.welcome_email(@requistion).deliver
			redirect_to @requistion
		else
			flash[:warning] = "Вы ошиблись при заполнении формы"
			redirect_to "/requistions/new"
		end
	end

	def destroy
		Requistion.find(params[:id]).destroy
		flash[:success] = "Заявка удалена"
		render 'index'
	end

	def index
		@name = "Все заявки"
		@requistions = Requistion.all.order(:created_at)
		@pos = params[:position]
		@value = params[:value]
		case @pos
			when '2'
				@object = Building.find(@value).arrival_address
			when '12'
				@object = User.find(@value).name
		end
	end

	def all_new
		@name = "Новые заявки"
		@requistions = Requistion.fresh
		render "index"
	end

	def edit
		@requistion = Requistion.find(params[:id])
#		if @requistion.status=="completed"
#			redirect_to @requistion
#		end
		@list_worker = User.worker.order(:name)
		@list_contract = @requistion.building.contracts
		@list_company = Contract.all
		@list_boss = Boss.all
	end

	def update_contracts
		@list_company =  Contract.where("company = '#{params[:company]}'")
		render :partial => "versions", :object => @list_company
	end

	def update_date
 		@contract = Contract.find(params[:contract])
		render :json => { :contract_id => @contract.contract_id,
						  :description => @contract.description,
						  :name_contract => @contract.name_contract,
						  :time =>  "С "+Russian::strftime(@contract.begin_time, "%e %B %Y")+" до "+Russian::strftime(@contract.end_time, "%e %B %Y")}
	end

	def update_objects_name
		@building = Building.find_by arrival_address: params[:address]
		render :json => @building.name
	end

	def get_contracts_by_address
		flash[:success] = params[:address]
		building = Building.find(params[:address])
		@list_contract = building.contracts
		render :partial => "table_contract", :object => @list_contract
	end

	def update
		#Необходимо добавить проверку корректности данных
		@requistion = Requistion.find(params[:id])
		if @requistion.update_attributes(requistion_update_attributes)

			client = @requistion.users.client.first

			all_workers_id = Array(params[:workers])
			pairs = @requistion.pairs
			old_workers_id = @requistion.users.where({ status: "worker"}).collect{|p| p.id  }
			pairs.where(user_id: old_workers_id).destroy_all

			all_workers_id.each do |worker|
				pairs.find_or_create_by(user_id: worker)
			end

			if all_workers_id.empty?
				@requistion.update_attribute :status, 'fresh'
			else
				@requistion.update_attribute :status, 'assigned'
			end

			# flash[:success] = "Заявка успешно изменена"
			# text = 'По вашей заявке №' + @requistion.id.to_s + ' выслан(ы) '
			# all_workers.each { |id| text += ' ' + User.find(id).name}
			# text += "."
			# flash[:info] = text
			if client && client.phone
				message = MainsmsApi::Message.new(
					sender: '3B-online',
					message: text,
					recipients: [client.phone])
				response = message.deliver
			end

			redirect_to @requistion
		else
			render 'edit'
		end
	end

	def new
		@list_worker = User.worker.order(:name)
		@requistion = Requistion.new
		@list_contract = current_user.contracts
		if current_user.client?
			@list = Building.where(
				"id in (SELECT building_id FROM buildingscontracts
				WHERE contract_id in
				(SELECT id FROM contracts t WHERE user_id = ?))", current_user[:id])
		else
			@list = Building.order("lower(name)").all
		end
	end


	private
		def requistions_params
			params.require(:requistion).permit(:contact_name, :category, :contact_phone, :deputy,
				:type_requistion, :subtype_requistion, :building_id, :requistion_comment,
				:time_deadline)
		end

		def requistion_update_attributes
			params.require(:requistion).permit(:time_deadline, :requistion_comment, :contact_phone, :contact_name)
		end

		def send_to_boss(worker_id)
			user = User.find(worker_id)
			boss = user.boss
			if (boss.phone != "")
				message = MainsmsApi::Message.new(
					sender: '3B-online',
					message: "Проконтролируйте #{user.name}",
					recipients: [boss.phone])
				response = message.deliver
			end
		end
end
