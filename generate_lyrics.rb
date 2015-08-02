require 'marky_markov'
markov = MarkyMarkov::TemporaryDictionary.new
markov.parse_file "lyrics.txt"
markov.generate_10_sentences.split(" ").each_slice(5) do |line|
  puts "#{line.join(" ")}\n"
end
markov.clear! # Clear the temporary dictionary.
