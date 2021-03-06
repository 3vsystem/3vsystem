class BuildingsController < ApplicationController
	before_action :signed_in_user
	before_action :admin_user, only: [:index]
	before_action :client_admin_user, only: [:create, :new,]
	before_action :worker_user, only: [:check_in, :check_out]

	respond_to :html, :json

	def search
		name = "%#{params[:name]}%"
		@buildings = Building.all.where("arrival_address ILIKE ? AND name LIKE ?", "%#{params[:q]}%", name)

		@bjson = @buildings.to_json(:only => [ :id, :name, :arrival_address ])
		render json: @bjson
	end

	def get_name
		render text: Building.find(params[:id]).name.to_s
	end

	def create
		@building = Building.new (building_params)
		if @building.save
			flash[:success] = "Здание создано"
			redirect_to @building
		else
			render 'new'
		end
	end

	def new
		@building = Building.new
	end

	def edit
		@building = Building.find(params[:id])
		render 'new'
	end

	def show
		@building = Building.find(params[:id])
		if current_user.worker?
			@list_requistion = Requistion.where(
			"id in (SELECT requistion_id FROM pairs WHERE user_id = ?) and building_id = ?",
			current_user[:id], params[:id])
		else
			@list_requistion = @building.requistions
		end

	end

	def index
		@buildings = Building.includes(:contracts);
	end

	def check
		@building = Building.find(params[:id])
	end

	def check_in
		requistion_for_buidings = current_user.requistions.where('status <= 3 and building_id=?', params[:id])
		# pairs = Pair.where(
		# 	"user_id = ? and requistion_id in (SELECT id FROM requistions WHERE building_id = ?)",
		# 	 current_user[:id], params[:id])
		# last = current_user.arrivals.where(check_type: 0).order(:date).last();
		# date = Time.zone.now.strftime("%Y-%m-%d")
		arrival = Arrival.create(
			user_id: current_user[:id],
			check_type: "check_in",
			building_id: params[:id],
			date: Time.now.to_s)

	#   	if current_user.arrivals.where("date between date('now') AND date('now')").count==0
		# 	arrival.update_attributes(begin_or_end: 0)
		# end
		if requistion_for_buidings.size != 0
			requistion_for_buidings.each do |f|
				f.update_attributes(status: "running", time_running: Time.now.to_s, who_running: current_user.id)
			end
			flash[:success] = "Ваше прибытие отмечено!"
			redirect_to requistion_for_buidings.first
		else
			building = Building.find(params[:id])
			if building.requistions.size == 0
				flash[:warning] = 'По данному адресу нет заявок'
			else
				flash[:warning] = "По данному адресу есть заявки доступные только исполнителю"
			end
			redirect_to :action => "requistions", :id => params[:id]
		end

	end

	def check_out
		pairs = Pair.where(
			"user_id = ? and requistion_id in (SELECT id FROM requistions WHERE building_id = ?)",
			current_user[:id], params[:id])
		arrival = Arrival.create(
			user_id: current_user[:id],
			check_type: "check_out",
			building_id: params[:id],
			date: Time.now.to_s)
			if Time.zone.now.strftime("%H").to_i<=7 and Time.zone.now.strftime("%H").to_i>=5
			arrival.update_attributes(begin_or_end: 1)
		end
#		pairs.each do |pair|
#			pair.requistion.update_attributes(status: "worker_gone")
#		end
		flash[:success] = "Ваше отбытие отмечено!"
		redirect_to req_path(current_user)
	end

	def requistions
		building = Building.find(params[:id])
		@list_requistions = building.requistions
	end

	def update
		@building = Building.find(params[:id])
		@a = params[:building][:arrival_address]
		if @a and @a!=@building.arrival_address
			if Building.where("arrival_address = ? ", @a).empty?
				if @building.update_attributes(arrival_address: @a)
					respond_with @building
				else
					flash[:success] = "Что-то пошло не так"
					redirect_to current_user
				end
			else
				building_new = Building.where("arrival_address = ? ", @a).first
				for requistion in @building.requistions
					requistion.update_attributes(building_id: building_new.id)
				end
				for arrival in @building.arrivals
					arrival.update_attributes(building_id: building_new.id)
				end
				for contract in @building.contracts
					if Buildingscontract.where("building_id = ? and contract_id = ?", building_new.id, contract.id).empty?
								Buildingscontract.create(building_id: building_new.id, contract_id: contract.id)
							end
						end
						@building.contracts.destroy_all
						@building.destroy
					respond_with @building
			end
		else
			redirect_to @building
		end

	end

	private
		def building_params
			params.require(:building).permit(:name ,:arrival_address, :contact_phone, :contact_name)
		end

end
