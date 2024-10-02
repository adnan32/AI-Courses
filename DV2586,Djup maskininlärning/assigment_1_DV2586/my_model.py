# To disable oneDNN optimizations
import os
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'

# importing libraries
from tensorflow.keras import layers, models, backend
from tensorflow.keras.utils import get_source_inputs 
import tensorflow as tf

class My_model:

    def __init__(self, include_top=True, weights=None, input_tensor=None, input_shape=(32, 32, 3), pooling=None, classes=10):
        # Determine proper input shape and create the input layer
        if input_tensor is None:
            img_input = layers.Input(shape=input_shape)
        else:
            if not backend.is_keras_tensor(input_tensor):
                img_input = layers.Input(tensor=input_tensor, shape=input_shape)
            else:
                img_input = input_tensor

        # Build the VGG19 architecture
        x = self._create_vgg_architecture(img_input, include_top, pooling, classes)

        # Ensure that the model takes into account any potential predecessors of `input_tensor`.
        if input_tensor is not None:
            inputs = get_source_inputs(input_tensor)
        else:
            inputs = img_input

        # Create the model
        self.model = models.Model(inputs, x, name='mymodel')

        # Load weights if specified
        if weights is not None:
            self.model.load_weights(weights)

    
    def _create_vgg_architecture(self, img_input, include_top, pooling, classes):
        # Block 0
        x = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block0_conv1')(img_input)
        x = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block0_conv2')(x)
        x = layers.MaxPooling2D((2, 2), strides=(2, 2), name='block0_pool')(x)

        # Block 1
        x1 = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block1_conv1')(x)
        y = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block1_conv2')(x)
        concatenated = layers.Concatenate(axis=-1)([x1, y])
        b= layers.BatchNormalization()(concatenated)
        t = layers.AveragePooling2D((2, 2), strides=(2, 2), name='block1_pool')(b)

        # Block 2
        x = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block2_conv1')(t)
        y = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block2_conv2')(t)
        x = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block2_conv3')(x)
        y = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block2_conv4')(y)
        concatenated = layers.Concatenate(axis=-1)([x, y])
        b= layers.BatchNormalization()(concatenated)
        t = layers.AveragePooling2D((2, 2), strides=(2, 2), name='block2_pool')(b)

        # Block 3
        x = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block3_conv1')(t)
        y = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block3_conv2')(t)
        z = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block3_conv3')(t)
        x = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block3_conv4x')(x)
        y = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block3_conv4y')(y)
        z = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block3_conv4z')(z)
        concatenated = layers.Concatenate(axis=-1)([x, y, z])
        b= layers.BatchNormalization()(concatenated)
        t = layers.AveragePooling2D((2, 2), strides=(2, 2), name='block3_pool')(b)

        # Block 4
        x = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block5_conv1')(t)
        y = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block5_conv2')(t)
        z = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block5_conv3')(t)
        d = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block5_conv4')(t)
        x = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block5_conv1x')(x)
        y = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block5_conv2y')(y)
        z = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block5_conv3z')(z)
        d = layers.Conv2D(32, (3, 3), activation="relu", padding='same', name='block5_conv4d')(d)
        concatenated = layers.Concatenate(axis=-1)([x, y, z, d])
        b= layers.BatchNormalization()(concatenated)
        t = layers.MaxPooling2D((2, 2), strides=(2, 2), name='block4_pool')(b)

        if include_top:
            # Classification block
            x = layers.Flatten(name='flatten')(t)
            x = layers.Dense(4096, activation="relu", name='fc1')(x)
            x = layers.Dropout(0.5)(x)  # Adding Dropout
            x = layers.Dense(4096, activation="relu", name='fc2')(x)
            x = layers.Dropout(0.5)(x)  # Adding Dropout
            x = layers.Dense(classes, activation='softmax', name='predictions')(x)
        else:
            if pooling == 'avg':
                x = layers.GlobalAveragePooling2D()(x)
            elif pooling == 'max':
                x = layers.GlobalMaxPooling2D()(x)

        return x