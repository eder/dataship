class ProductFilter
  def initialize(params, scope = Product.all)
    @params = params
    @scope  = scope
  end

  def call
    scope
      .yield_self { |rel| params[:name].present?          ? rel.by_name(params[:name])         : rel }
      .yield_self { |rel| params[:min_price].present?     ? rel.min_price(params[:min_price])  : rel }
      .yield_self { |rel| params[:max_price].present?     ? rel.max_price(params[:max_price])  : rel }
      .yield_self { |rel| params[:expiration_from].present? ? rel.where("expiration >= ?", params[:expiration_from]) : rel }
      .yield_self { |rel| params[:expiration_to].present?   ? rel.where("expiration <= ?", params[:expiration_to])   : rel }
      .yield_self { |rel| params[:sort].present?          ? rel.sorted(params[:sort], order)   : rel }
  end

  private

  attr_reader :params, :scope

  def order
    params[:order] == "desc" ? :desc : :asc
  end
end
