require 'sinatra'
require 'paypal-sdk-rest'
require 'awesome_print'

include PayPal::SDK::REST

  enable :sessions

  get '/' do

    payment = Payment.new({
      :intent => "sale",
      :payer => {
        :payment_method => "paypal",
      },
      redirect_urls: {
        return_url: "#{request.url}/completed",
        cancel_url: "#{request.url}/cancelled"
      },
      :transactions => [{
        :amount => {
          :total => "100",
          :currency => "JPY" },
        :description => "A new cardboard box for Maru"
      }]
    })

    if payment.create

      session[:payment_id] = payment.id

      @redirect = payment.links.find {|link| link.method == "REDIRECT" }.href
      erb :index
    else
      payment.error
    end

  end

  get "/cancelled" do
    "The user has cancelled the payment"
  end

  get "/completed" do

  payment = Payment.find(session[:payment_id])

    if payment.execute(payer_id: params["PayerID"])
      erb :complete
    else
      "Handle payment execution failure"
    end
  end