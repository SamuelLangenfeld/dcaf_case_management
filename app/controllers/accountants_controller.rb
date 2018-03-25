# Controller pertaining to accountant functions, usually fulfillments.
class AccountantsController < ApplicationController
  before_action :confirm_admin_user, only: [:index, :edit]
  before_action :confirm_admin_user_async, only: [:search]
  before_action :find_patient, only: [:edit]

  def index
    fulfilled_pts = Patient.where(pledge_sent: true,
                                  :initial_call_date.gte => 6.months.ago)
                           .order('pledge_sent_at desc')
    @patients = Kaminari.paginate_array(fulfilled_pts)
                        .page(params[:page]).per(25)
  end

  def search
    # We're doing it janky because we implemented search to return an array,
    # not an activerecord object. some room for improvement.
    @results = if params[:search].blank?
                 Patient.search(params[:search])
                        .select(&:pledge_sent?)
                        .sort(&:pledge_sent_at).reverse
               else
                 Patient.where(pledge_sent: true)
                        .order('pledge_sent_at desc')
               end

    @paginated_results = Kaminari.paginate_array(@results)
                                 .page(params[:page])
                                 .per(25)
    respond_to { |format| format.js }
  end

  def edit
    # This is a cheater method that populates the fulfillment partial into a
    # modal via ajax.
    respond_to { |format| format.js }
  end

  private

  def find_patient
    @patient = Patient.find params[:id]
  end
end
