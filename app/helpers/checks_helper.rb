module ChecksHelper
  def active(key:, value: "")
    "active" if params[key].to_s == value.to_s
  end

  def filter_params
    params.permit(:p, :d).to_h
  end
end
