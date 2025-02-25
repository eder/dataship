class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :price, :currency, :expiration, :comparisons

  def price
    object.price.to_f
  end

  def currency
    ENV.fetch("BASE_CURRENCY", "USD").to_s
  end

  def comparisons
    base_price = object.price.to_f
    # Assuming object.exchange_rates is a hash of the form:
    # { "BRL" => 5.70298466, "CNY" => 7.2547192, "INR" => 86.56929129, "RUB" => 88.67787942, "USD" => 1, "ZAR" => 18.36229567 }
    object.exchange_rates.each_with_object({}) do |(curr, rate), hash|
      hash[curr] = {
        exchangeRate: rate,
        price: rate ? (base_price * rate).round(8) : nil
      }
    end
  end
end

