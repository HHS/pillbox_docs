class String
  def encrypt
    tr "a-z", "b-za"
  end

  def decrypt
    tr "b-za", "a-z"
  end
end