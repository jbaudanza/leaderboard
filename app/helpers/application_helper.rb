module ApplicationHelper
  def bitcoin_balance(satoshis)
    if satoshis
      number_with_precision(0.00000001 * satoshis, :precision => 5)
    else
      '?'
    end
  end
end
