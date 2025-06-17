class ReportFormatter
  def call(data, original_input)
    raise NotImplementedError, "Child classes must implement call method"
  end

  protected

  def format_timestamp
    Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end
end 