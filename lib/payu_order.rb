class PayuOrder
  include Rails.application.routes.url_helpers

  def self.params(order, ip, order_url, notify_url, continue_url)
    products = order.line_items.map do |li|
      {
        name: li.product.name,
        unit_price: (li.price * 100).to_i,
        quantity: li.quantity
      }
    end

    shipping_rates = order.shipments.last.shipping_rates.where(selected: true)
    shipping_methods = shipping_rates.map do |sr|
      {
        name: sr.shipping_method.name,
        price: (sr.cost * 100).to_i,
        country: order.shipping_address.country.iso
      } 
    end

    description = I18n.t('order_description',
      name: Spree::Config.site_name)
    description = I18n.transliterate(description)

    {
      merchant_pos_id: OpenPayU::Configuration.merchant_pos_id,
      customer_ip: ip,
      ext_order_id: order.id,
      description: description,
      currency_code: 'PLN',
      total_amount: (order.total * 100).to_i,
      order_url: order_url,
      notify_url: notify_url,
      continue_url: continue_url,
      buyer: {
        email: order.email,
        phone: order.bill_address.phone,
        first_name: order.bill_address.firstname,
        last_name: order.bill_address.lastname,
        language: 'PL',
        delivery: {
          street: order.shipping_address.address1,
          postal_code: order.shipping_address.zipcode,
          city: order.shipping_address.city,
          country_code: order.bill_address.country.iso
        }
      },
      products: products,
      shipping_methods: shipping_methods
    }
  end
end
