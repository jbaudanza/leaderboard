require 'barby/outputter/png_outputter'
require 'barby/barcode/qr_code'

class QrCodesController < ApplicationController
  def show
    if Bitcoin::valid_address?(params[:id])
      qr_code = Barby::QrCode.new('bitcoin:' + params[:id])
      outputter = Barby::PngOutputter.new(qr_code)
      outputter.xdim = 5

      expires_in 1.day, :public => true
      render :content_type => 'image/png', :text => outputter.to_png
    else
      render :status => 400, :text => "Not valid bitcoin address"
    end
  end
end
