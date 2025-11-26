#! mix run

defmodule Token do
  @test_token "PiQFJ0AJBzliWD0-VwsjDjcoIlMmFwc-UARQwzSL7mvXnfoEujRjdcsg"
  # raw-unmasked-token: keWv7sTuU5Kf9mLKBBp9BttY

  @doc """
  此段代码证明用户看到的用于csrf的token，可以解析出session中保存的原始token，18字节随机字节；
  也表明两token是等价的，不能泄露到第三方； 但per-host的是经过签名的，更安全一些
  """
  def parse_csrf(raw_token \\ @test_token) do
    # mask = generate_token()
    # Base.url_encode64(Plug.Crypto.mask(token, mask)) <> mask
    <<user_token::32-binary, mask::24-binary>> = raw_token
    mask |> IO.inspect(label: "mask token")

    masked =
      Base.url_decode64!(user_token, padding: false)
      |> IO.inspect(label: "masked-token")

    Plug.Crypto.mask(masked, mask)
    |> IO.inspect(label: "restore unmasked csrf-token")
  end
end

Token.parse_csrf()
