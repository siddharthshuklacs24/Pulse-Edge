# ================================================================
# PulseEdge — Model Training & TFLite Conversion
# Member 1 runs this. Output goes to mobile_app/assets/models/
# ================================================================

# ── CELL 1: Imports ─────────────────────────────────────────────
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report
import tensorflow as tf
from tensorflow import keras
import os

print("TensorFlow version:", tf.__version__)

# ── CELL 2: Load Dataset ─────────────────────────────────────────
df = pd.read_csv('../data/heart.csv')
print("Dataset shape:", df.shape)
print(df.head())
print("\nClass distribution:")
print(df['HeartDisease'].value_counts())

# ── CELL 3: Encode Categorical Columns ───────────────────────────
# These mappings MUST match the dropdowns in Member 2's assessment_form.dart
df['Sex']            = df['Sex'].map({'M': 1.0, 'F': 0.0})
df['ChestPainType']  = df['ChestPainType'].map({'ATA': 0.0, 'NAP': 1.0, 'ASY': 2.0, 'TA': 3.0})
df['RestingECG']     = df['RestingECG'].map({'Normal': 0.0, 'ST': 1.0, 'LVH': 2.0})
df['ExerciseAngina'] = df['ExerciseAngina'].map({'N': 0.0, 'Y': 1.0})
df['ST_Slope']       = df['ST_Slope'].map({'Up': 0.0, 'Flat': 1.0, 'Down': 2.0})

# ── CELL 4: Prepare Features ─────────────────────────────────────
# Column ORDER matters — must match Member 4's ml_service.dart exactly
FEATURE_COLUMNS = [
    'Age',           # index 0
    'Sex',           # index 1
    'ChestPainType', # index 2
    'RestingBP',     # index 3
    'Cholesterol',   # index 4
    'FastingBS',     # index 5
    'RestingECG',    # index 6
    'MaxHR',         # index 7
    'ExerciseAngina',# index 8
    'Oldpeak',       # index 9
    'ST_Slope'       # index 10
]

X = df[FEATURE_COLUMNS].values.astype(np.float32)
y = df['HeartDisease'].values.astype(np.float32)

# ── CELL 5: Print Min/Max Values for Member 4 ────────────────────
# Member 4 needs these to normalize user inputs in ml_service.dart
CONTINUOUS_COLS = {
    'Age':        (0, 3),     # (column_name, index_in_X)
    'RestingBP':  (3, 3),
    'Cholesterol':(4, 4),
    'MaxHR':      (7, 7),
    'Oldpeak':    (9, 9),
}
print("\n=== SEND THESE TO MEMBER 4 ===")
for col in ['Age', 'RestingBP', 'Cholesterol', 'MaxHR', 'Oldpeak']:
    col_data = df[col].values
    print(f"{col}: min={col_data.min():.1f}, max={col_data.max():.1f}")
print("==============================\n")

# ── CELL 6: Normalize Continuous Columns ─────────────────────────
def normalize_column(data, col_min, col_max):
    return (data - col_min) / (col_max - col_min)

X_norm = X.copy()
X_norm[:, 0] = normalize_column(X[:, 0], df['Age'].min(),         df['Age'].max())
X_norm[:, 3] = normalize_column(X[:, 3], df['RestingBP'].min(),   df['RestingBP'].max())
X_norm[:, 4] = normalize_column(X[:, 4], df['Cholesterol'].min(), df['Cholesterol'].max())
X_norm[:, 7] = normalize_column(X[:, 7], df['MaxHR'].min(),       df['MaxHR'].max())
X_norm[:, 9] = normalize_column(X[:, 9], df['Oldpeak'].min(),     df['Oldpeak'].max())

# ── CELL 7: Train/Test Split ──────────────────────────────────────
X_train, X_test, y_train, y_test = train_test_split(
    X_norm, y, test_size=0.2, random_state=42, stratify=y
)
print(f"Training samples: {len(X_train)}, Test samples: {len(X_test)}")

# ── CELL 8: Build Neural Network ─────────────────────────────────
model = keras.Sequential([
    keras.layers.Input(shape=(11,)),          # 11 input features
    keras.layers.Dense(64, activation='relu'),
    keras.layers.Dropout(0.3),
    keras.layers.Dense(32, activation='relu'),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(16, activation='relu'),
    keras.layers.Dense(1, activation='sigmoid')  # Output: 0.0 to 1.0
], name='heart_risk_model')

model.summary()

model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=0.001),
    loss='binary_crossentropy',
    metrics=['accuracy']
)

# ── CELL 9: Train ─────────────────────────────────────────────────
history = model.fit(
    X_train, y_train,
    epochs=100,
    batch_size=32,
    validation_split=0.15,
    callbacks=[
        keras.callbacks.EarlyStopping(patience=10, restore_best_weights=True)
    ],
    verbose=1
)

# ── CELL 10: Evaluate ─────────────────────────────────────────────
y_pred_prob = model.predict(X_test)
y_pred      = (y_pred_prob > 0.5).astype(int).flatten()

print("\n=== MODEL PERFORMANCE ===")
print(f"Test Accuracy: {accuracy_score(y_test, y_pred):.4f}")
print(classification_report(y_test, y_pred, target_names=['No Disease', 'Heart Disease']))

# ── CELL 11: Convert to TFLite ────────────────────────────────────
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]   # Quantize for smaller file size
tflite_model = converter.convert()

# Save directly into Flutter assets folder
output_dir  = '../../mobile_app/assets/models/'
output_path = os.path.join(output_dir, 'heart_risk.tflite')

os.makedirs(output_dir, exist_ok=True)

with open(output_path, 'wb') as f:
    f.write(tflite_model)

print(f"\n✅ Model saved to: {output_path}")
print(f"   File size: {len(tflite_model) / 1024:.1f} KB")
print(f"\n=== HAND THIS TO MEMBER 4 ===")
print(f"Input tensor shape:  [1, 11]  (float32)")
print(f"Output tensor shape: [1, 1]   (float32, value between 0.0 and 1.0)")
print(f"=============================")

# ── CELL 12: Verify the TFLite file works ────────────────────────
interpreter = tf.lite.Interpreter(model_path=output_path)
interpreter.allocate_tensors()

input_details  = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print(f"\n✅ TFLite Verification:")
print(f"   Input shape:  {input_details[0]['shape']}")
print(f"   Output shape: {output_details[0]['shape']}")

# Test with one sample
test_input = X_test[0:1]
interpreter.set_tensor(input_details[0]['index'], test_input)
interpreter.invoke()
tflite_output = interpreter.get_tensor(output_details[0]['index'])
keras_output  = model.predict(test_input, verbose=0)

print(f"\n   Keras  output: {keras_output[0][0]:.4f}")
print(f"   TFLite output: {tflite_output[0][0]:.4f}")
print(f"   ✅ Match: {abs(keras_output[0][0] - tflite_output[0][0]) < 0.01}")
