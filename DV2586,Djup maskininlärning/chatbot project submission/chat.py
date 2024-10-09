from tensorflow.keras.models import load_model
import pickle
import numpy as np
from predict import model_prediction


model = load_model('model_embedding_512.h5')
with open('tokenizer_1.pickle', 'rb') as handle:
    tokenizer = pickle.load(handle)


chatbot_model = model_prediction(model, tokenizer)


encoder_model = chatbot_model.encoder_model(model)
decoder_model = chatbot_model.decoder_model(model)


print("Chatbot is ready! Type 'quit' to end the conversation.")

while True:
    user_input = input("You: ")

    if user_input.lower() == 'quit':
        break
    
    
    input_seq = chatbot_model.preprocess_input(user_input, tokenizer, max_seq_length=137)
    
    
    conversation_states = encoder_model.predict(input_seq, verbose=0)

    target_seq = np.zeros((1, 1))
    target_seq[0, 0] = tokenizer.word_index['sos']
    
    stop_condition = False
    decoded_sentence = ''

    while not stop_condition:
        
        output_tokens, h, c = decoder_model.predict([target_seq] + conversation_states, verbose=0)

        
        sampled_token_index = np.argmax(output_tokens[0, -1, :])
        sampled_word = tokenizer.index_word.get(sampled_token_index, '')

        
        if not sampled_word:
            print("Warning: Empty or invalid token generated.")
            stop_condition = True
        elif sampled_word == 'eos' or len(decoded_sentence.split()) > 137:
            stop_condition = True
        else:
            decoded_sentence += ' ' + sampled_word

            
            target_seq = np.zeros((1, 1))
            target_seq[0, 0] = sampled_token_index

            
            conversation_states = [h, c]

    
    print("Bot:", decoded_sentence.strip())


