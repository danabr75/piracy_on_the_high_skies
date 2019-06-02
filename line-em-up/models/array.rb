class Array
  def * array2
    max_length = self.length
    new_array = Array.new(max_length) { Array.new(max_length) { nil } }

    # for (c = 0; c < m; c++) {
    (0..max_length - 1).each do |c|
      # for (d = 0; d < q; d++) {
      (0..max_length - 1).each do |d|
        # for (k = 0; k < p; k++) {
        sum = 0
        (0..max_length - 1).each do |k|
          sum += self[c][k] * array2[k][d];
        end
 
        new_array[c][d] = sum;
        sum = 0;
      end
    end

    return new_array
  end


# Ay=⎡⎣⎢⎢⎢147258369⎤⎦⎥⎥⎥⎡⎣⎢⎢⎢213⎤⎦⎥⎥⎥

# First, multiply Row 1 of the matrix by Column 1 of the vector.

# [123]⎡⎣⎢⎢⎢213⎤⎦⎥⎥⎥=[1⋅2+2⋅1+3⋅3]=13

# test1 = [
#   [1, 2, 3],
#   [4, 5, 6],
#   [7, 8, 9]
# ]
# vector1 = [2, 1, 3]

# should equal
# [13, 31, 49]

  def vector_mult vector_mult
    puts "SELF"
    self.matrix_to_s
    max_length = self.length
    puts "SELF>LENGTH: #{self.length}"
    new_array = Array.new(max_length) { Array.new(max_length) { nil } }

    (0..max_length - 1).each do |c|
      sum = 0
      (0..vector_mult.length - 1).each do |k|
        puts "C and K here: #{c} x #{k}"
        sum += self[c][k] * vector_mult[k];
      end

      new_array[c] = sum;
      sum = 0;
    end
    return new_array
  end

  def matrix_to_s
    self.each do |i|
      output = "|"
      i.each do |k|
        output << "#{k}|"
      end
      puts output
    end
  end

end
