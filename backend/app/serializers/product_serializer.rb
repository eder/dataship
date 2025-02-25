class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :price, :currency, :expiration, :exchange_rates

  def currency
    ENV.fetch("BASE_CURRENCY", "USD").to_s
  end

  def exchangeRates
    object.exchange_rates
  end
end

