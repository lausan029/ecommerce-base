Crear las variables de entorno en mi ambiante local
vim ./bash_profiles
export PAYPAL_CLIENT_ID=AbZGse2D7d-NCzvsUfWBapbRTGN2dkPRFncetQEfnLu2vc44zAu0RrDdnljZxq2kvUDXTEo12MqFQXrc
export PAYPAL_SECRET_ID=EIPey_jDWyhe8X_muhd0vHDbhAxvR2QgK4Qkfy9kReDyzf2Db_aF2vFXkZlV1qg0LRdNZcyS5Hh8o-ej

source bash_profiles

Crear las variables de entorno en heroku
heroku create
git push heroku master
heroku run rake db:migrate
heroku config:set PAYPAL_CLIENT_ID=AbZGse2D7d-NCzvsUfWBapbRTGN2dkPRFncetQEfnLu2vc44zAu0RrDdnljZxq2kvUDXTEo12MqFQXrc
heroku config:set PAYPAL_SECRET_ID=EIPey_jDWyhe8X_muhd0vHDbhAxvR2QgK4Qkfy9kReDyzf2Db_aF2vFXkZlV1qg0LRdNZcyS5Hh8o-ej



creando el modelo billings
rails g model Billing code payment_method amount:decimal{5-2} currency user:references
rake db:migrate

creando relacion billing orders
rails g migration addBillingToOrder billing:references
rake db:migrate

add model order 
class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :billing, optional: true
end



creando diagrama erd 
https://github.com/voormedia/rails-erd

add gema
gem 'rails-erd', require: false, group: :development

brew install graphviz
bundle
bundle exec erd
deberia generar un pdf


creandocontroller billings
rails g controller billings

class BillingsController < ApplicationController
	def pre_pay
  end
end

modificando las rutas
  resources :billings, only: [] do
   collection do
    get 'pre_pay'
   end
  end

add boton de pago
<%= link_to 'Confirmar compra', pre_pay_billings_path, class: 'btn btn-success float-right' %>


add gemfile

gem 'paypal-sdk-rest'
bundle
rails g paypal:sdk:install

modificar el billing controller modificar todo el metodo pre_pay



cuando le des a comprar hay que inciar con la cuenta sanbox personal

modificar el billing controller crear nuevo metodo execute
y agregar la ruta     get 'execute'



listamos los pagos realizados 
modificar la ruta y agregar el index
  resources :billings, only: [:index] do

agregar el metodo al controller
	def index
		@billings = current_user.billings
	end

modificar el modelo
user
  has_many :billings

billings
  has_many :orders

creamos la vista index en view billing


refactoor


SCOPE CART
modificar el modelo 
class Order < ApplicationRecord
 belongs_to :user
 belongs_to :product
 belongs_to :billing, optional: true
 scope :cart, (-> {where(payed: false)})
 def self.get_total
 where(nil).pluck("price * quantity").sum()
 end
end


utilizar la modificaciones
def index
 @orders = current_user.orders.cart
 @total = @orders.get_total
end



MÉTODO PARA CREAR
ARRAY DE HASHES CON ITEMS
class Order < ApplicationRecord
 #...
 def self.to_paypal_items
 where(nil).map do |order|
 item = {}
 item[:name] = order.product.name
 item[:sku] = order.id.to_s
 item[:price] = order.price.to_s
 item[:currency] = 'USD'
 item[:quantity] = order.quantity
 item
 end
 end
end
def pre_pay
 orders = current_user.orders.cart
 total = orders.get_total
 items = orders.to_paypal_items
 #...

end


para que las rutas de execute sirva en produccion
modificar el billing controller
		 return_url: "http://localhost:3000/billings/execute",
 por 		 return_url: execute_billings_url,
