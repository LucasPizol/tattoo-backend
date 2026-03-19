MoneyRails.configure do |config|
  config.default_currency = :brl
end

Money.locale_backend = :currency
