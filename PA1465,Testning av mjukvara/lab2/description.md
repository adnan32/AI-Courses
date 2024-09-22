# Assigment 2: Fuzzing


The random_data_generator() function generates random data of various types and from different writing systems, languages and character sets.

In terms of design decisions, the function includes a variety of data types, such as integers, floats, boolean values, and lists of integers. The function generates random characters from different languages and writing systems, including Arabic, Ukrainian, Chinese, Japanese, Korean, Hindi, and several European languages. Also, random characters from Unicode's Basic Multilingual Plane (BMP) and Supplementary Multilingual Plane (SMP), including Hangul Syllable and Latin Extended Additional characters.

In each iteration of the while loop, a new empty dictionary named random_dic is created. The variable num_elements is assigned a random integer between 1 and the length of the input dictionary dic. This variable determines the number of items that the random_dic will have.

The next loop iterates num_elements times, and in each iteration, a random key is selected from dic. The random.choices function selects a random sample of keys from the list of keys of dic, with the length of the sample being a random integer between 1 and the length of dic. The random.choice function then selects a random key from the sampled keys, and its corresponding value is retrieved from dic. The selected key-value pair is then added to random_dic.To add more complexity to the test cases, there's a 50% chance that another dictionary dubbel_dic is created, with a random number of elements, and added to the random_dic as a nested dictionary. This nested dictionary also contains a tuple with a single value.
