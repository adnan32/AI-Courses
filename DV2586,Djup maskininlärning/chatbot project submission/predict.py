import numpy as np
from tensorflow.keras.preprocessing.sequence import pad_sequences
from tensorflow.keras.layers import Input
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input
import nltk
from sklearn.metrics.pairwise import cosine_similarity
from nltk.translate.bleu_score import sentence_bleu, SmoothingFunction

class model_prediction():
    def __init__(self, model,tokenizer):
        self.model = model
        self.tokenizer = tokenizer
    
    def encoder_model(self,model):
        layers_indices = []
        layer_names=[]
        for index, layer in enumerate(model.layers):
            layers_indices.append(index)
            layer_names.append(layer.name)
        
        encoder_inputs = model.get_layer(layer_names[0]).input  # Encoder input layer
        encoder_embedding = model.get_layer(layer_names[2])(encoder_inputs)  # Embedding for encoder input
        encoder_outputs, state_h, state_c = model.get_layer(layer_names[4])(encoder_embedding)  # LSTM output and states
        encoder_states = [state_h, state_c]

        # Create the encoder model
        encoder_model_= Model(encoder_inputs, encoder_states)
        return encoder_model_
    
    def decoder_model(self,model):
        layers_indices = []
        layer_names=[]
        for index, layer in enumerate(model.layers):
            layers_indices.append(index)
            layer_names.append(layer.name)

        # Decoder input
        decoder_inputs = model.get_layer(layer_names[1]).input  # Decoder input layer
        decoder_embedding = model.get_layer(layer_names[3])(decoder_inputs)  # Embedding for decoder input

        # Placeholder for the encoder's hidden and cell states
        decoder_state_input_h = Input(shape=(512,), name='decoder_input_h')
        decoder_state_input_c = Input(shape=(512,), name='decoder_input_c')
        decoder_states_inputs = [decoder_state_input_h, decoder_state_input_c]

        # Pass inputs through the LSTM layer
        decoder_lstm = model.get_layer(layer_names[5])
        decoder_outputs, state_h_dec, state_c_dec = decoder_lstm(
            decoder_embedding, initial_state=decoder_states_inputs
        )
        decoder_states = [state_h_dec, state_c_dec]

        # Pass the decoder LSTM outputs to the Dense layer to generate the final predictions
        decoder_dense = model.get_layer(layer_names[6])
        decoder_outputs = decoder_dense(decoder_outputs)

        # Create the decoder model
        decoder_model_ = Model(
            [decoder_inputs] + decoder_states_inputs,
            [decoder_outputs] + decoder_states
        )
        return decoder_model_
    
    def decode_sequence(self,input_seq, encoder_model, decoder_model, tokenizer, max_decoder_seq_length):
        # Encode the input sequence to get the hidden states
        encoder_states = encoder_model.predict(input_seq,verbose=0)

        # Create an empty target sequence with only the start token
        target_seq = np.zeros((1, 1))
        target_seq[0, 0] = tokenizer.word_index['sos']

        stop_condition = False
        decoded_sentence = ''

        while not stop_condition:
            # Predict the next token and the decoder states
            output_tokens, h, c = decoder_model.predict([target_seq] + encoder_states,verbose=0)

            # Sample the token with the highest probability
            sampled_token_index = np.argmax(output_tokens[0, -1, :])
            sampled_word = tokenizer.index_word.get(sampled_token_index, '')

            # Stop if we hit the end token or reach the maximum sequence length
            if sampled_word == 'eos' or len(decoded_sentence.split()) > max_decoder_seq_length:
                stop_condition = True
            else:
                decoded_sentence += ' ' + sampled_word

                # Update the target sequence for the next token
                target_seq = np.zeros((1, 1))
                target_seq[0, 0] = sampled_token_index

                # Update the decoder hidden states
                encoder_states = [h, c]

        return decoded_sentence.strip()
    
    def preprocess_input(self,input_text, tokenizer, max_seq_length):
        """Preprocess user input for the chatbot."""
        input_seq = tokenizer.texts_to_sequences([input_text])
        input_seq = pad_sequences(input_seq, maxlen=max_seq_length, padding='post')
        return input_seq
    
    def predict(self,input_text, encoder_model, decoder_model, tokenizer, max_seq_length=137, max_decoder_seq_length=137):
        """Function to chat with the bot."""
        input_seq = self.preprocess_input(input_text, tokenizer, max_seq_length)
        response = self.decode_sequence(input_seq, encoder_model, decoder_model, tokenizer, max_decoder_seq_length)
        return response
    
    def calculate_bleu_score(self,input_text,target_text,encoder_model, decoder_model, tokenizer, max_seq_length=137, max_decoder_seq_length=137):
        predicted_sequense= self.predict(input_text, encoder_model, decoder_model, tokenizer, max_seq_length, max_decoder_seq_length)
        target_text = target_text
        bleu_score = smooth_fn = SmoothingFunction().method1  # Smoothing to handle zero counts
        bleu_score = sentence_bleu(target_text, predicted_sequense, smoothing_function=smooth_fn)
        return bleu_score
    
    def calculate_cosine_similarity(self, input_text, target_text, encoder_model, decoder_model, tokenizer, max_seq_length=137, max_decoder_seq_length=137):
        predicted_sequence = self.predict(input_text, encoder_model, decoder_model, tokenizer, max_seq_length, max_decoder_seq_length)
        
        # Convert both predicted and target texts into vectors using the same tokenizer
        predicted_vector, target_vector = self.text_to_vector(predicted_sequence, target_text)

        # Calculate cosine similarity
        cosine_sim = cosine_similarity([predicted_vector], [target_vector])[0][0]
        return cosine_sim

    def text_to_vector(self, predicted_text, target_text):
        """Convert predicted and target texts into vectors using the same tokenizer."""
        
        # Tokenize both the predicted and target texts
        predicted_seq = self.tokenizer.texts_to_sequences([predicted_text])
        target_seq = self.tokenizer.texts_to_sequences([target_text])

        # Convert token sequences to padded arrays of the same length
        max_len = max(len(predicted_seq[0]), len(target_seq[0]))  # Get the max length for padding
        predicted_vector = pad_sequences(predicted_seq, maxlen=max_len, padding='post')[0]
        target_vector = pad_sequences(target_seq, maxlen=max_len, padding='post')[0]

        return predicted_vector, target_vector