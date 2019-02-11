module ChecksHelper
  def percentile_active(value: "")
    "active" if params[:p].to_s == value.to_s
  end
end
