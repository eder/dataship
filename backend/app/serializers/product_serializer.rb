class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :price, :expiration, :exchangeRates

  def exchangeRates
    object.exchange_rates
  end
end

