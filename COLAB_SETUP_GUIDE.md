# Running the Notebook on Google Colab - SIMPLIFIED

## Quick Summary (5 Minute Setup)

1. ✅ Go to https://colab.research.google.com/
2. ✅ Upload `train_usl_model.ipynb` 
3. ✅ Enable GPU (Runtime → Change runtime type → T4 GPU)
4. ✅ Add dataset folder to your Drive (click the link below)
5. ✅ Run cells one by one (Shift + Enter)
6. ✅ Wait 2-4 hours for training
7. ✅ Download the model files

---

## The Easiest Way (Recommended)

### Step 1: Upload Notebook to Google Colab

1. **Open Google Colab in your browser:**
   - Go to: https://colab.research.google.com/

2. **Upload the notebook:**
   - Click **File** (top left)
   - Click **Upload notebook**
   - Click **Browse** button
   - Find and select: `train_usl_model.ipynb` from your Desktop\usl folder
   - Click **Open**

   OR
   
   - Just **drag and drop** `train_usl_model.ipynb` into the Colab window

3. **You're in!** The notebook will open in your browser

### Step 2: Enable GPU (IMPORTANT!)

1. **In Colab, click the top menu:** Runtime
2. **Click:** Change runtime type
3. **A popup appears:**
   - Find "Hardware accelerator"
   - Click the dropdown
   - Select **T4 GPU**
4. **Click:** Save

✅ You should see "Connected" with a green checkmark (top right)

### Step 3: Add Dataset to Your Google Drive

1. **Click this link:**
   https://drive.google.com/drive/folders/1cbhsVjLaycEFk4rcC0tE8yJrPCnh1mnn

2. **You'll see a folder with videos**
   - At the top, there's a folder icon with a small "+" sign
   - Click it (it says "Add shortcut to Drive" when you hover)

3. **A popup asks "Add shortcut to Drive":**
   - It should show "My Drive" already selected
   - Click **ADD SHORTCUT**

4. **Done!** The folder is now accessible in your Google Drive

5. **Remember the folder name** (you'll need it in the next step)

### Step 4: Update the Notebook with Your Folder Name

In the Colab notebook:

1. **Find the second code cell** (the one that starts with `from google.colab import drive`)

2. **Look for this line:**
   ```python
   DATASET_FOLDER_NAME = 'USL_Dataset'  # Change to your folder name!
   ```

3. **Change it to match your folder name:**
   - If the folder is called "USL_Dataset", leave it as is
   - If it's called something else (like "sign_language_data"), change it:
   ```python
   DATASET_FOLDER_NAME = 'sign_language_data'
   ```

### Step 5: Run the Notebook

**How to run cells in Colab:**

1. **Click on the first code cell** (the one that starts with `!pip install`)

2. **Press Shift + Enter** (or click the ▶️ play button on the left of the cell)

3. **Wait for it to finish** 
   - You'll see output appear below the cell
   - A spinning circle means it's running
   - A green checkmark ✓ means it's done

4. **Move to the next cell and repeat**
   - Click the cell
   - Press Shift + Enter
   - Wait for completion
   - Move to next

5. **Keep doing this for ALL cells from top to bottom**

**Important cells to watch:**

- **Cell 2 (Mount Drive):** 
  - Will ask permission to access Drive
  - Click "Connect to Google Drive"
  - Choose your account
  - Click "Allow"
  
- **Cell 6 (Load videos):**
  - Takes 10-30 minutes
  - Shows a progress bar
  - Don't close the browser!

- **Cell 10 (Train model):**
  - Takes 1-3 hours
  - Shows progress for each epoch
  - You can minimize the browser but keep it open

### Step 6: Download Your Trained Model

When training finishes:

1. **Find the last cell** (Section 16)

2. **Run it** (Shift + Enter)

3. **Two files will download:**
   - `usl_model.tflite` - Your model
   - `labels.json` - Class names

4. **Save them!** You'll need these for your Flutter app

---

## 🆘 Getting Help with Errors

### If You Get an Error While Running:

**What to do:**

1. **Don't panic!** Errors are normal and fixable

2. **Copy the error message:**
   - Click and drag to select the red error text
   - Right-click → Copy
   - Or press Ctrl + C

3. **Share it with me here in VS Code:**
   - Come back to this chat
   - Paste the error message
   - Tell me which cell number it happened in (e.g., "Cell 6")

4. **I'll help you fix it!**
   - I'll analyze the error
   - Give you the exact fix
   - Update the code if needed

### Common Errors I Can Help With:

**❌ "Dataset not found"**
- Share the error → I'll help you find the correct path

**❌ "Out of memory"**
- Share the error → I'll reduce batch size for you

**❌ "Module not found"**
- Share the error → I'll fix the imports

**❌ "Video loading failed"**
- Share the error → I'll debug the video processing

**❌ "Shape mismatch"**
- Share the error → I'll fix the model architecture

**❌ Training stuck / not improving**
- Share the training output → I'll adjust hyperparameters

### How to Share Errors with Me:

**Example 1: Copy the error**
```
Just paste the red error text here, like:

ValueError: could not broadcast input array from shape (224,224,3) into shape (30,224,224,3)
```

**Example 2: Take a screenshot**
- Press `Windows + Shift + S`
- Select the error area
- Paste in this chat (Ctrl + V)

**Example 3: Share cell number**
```
"Cell 10 is giving an error about tensor shapes"
```

### What Information Helps Me:

✅ **Good:** "Cell 6 says 'FileNotFoundError: No such file or directory: /content/drive/MyDrive/USL_Dataset'"

✅ **Good:** "Training accuracy is stuck at 30% after 10 epochs"

✅ **Good:** [Screenshot showing the error]

❌ **Less helpful:** "It's not working"

❌ **Less helpful:** "There's an error"

### I'm Here to Help!

- I can debug errors in real-time
- I can modify the code for you
- I can explain what went wrong
- I can suggest alternative approaches

**Just share the error and I'll guide you through fixing it!** 🚀

| Section | What it does | Estimated Time |
|---------|-------------|----------------|
| 1 | Install packages | 2-3 min |
| 2 | Mount Drive & verify dataset | 1 min |
| 3-4 | Load & explore data | 1 min |
| 5-6 | Preprocess videos | 10-30 min |
| 7 | Split dataset | 1 min |
| 8-10 | Build & train model | 1-3 hours |
| 11-12 | Evaluate results | 2 min |
| 13-14 | Convert to TFLite | 2 min |
| 15-16 | Save & download | 2 min |

**Total time: ~2-4 hours** (mostly training)

### 6. Monitoring Training

Watch these metrics during training:
- **Training accuracy** should increase (target: >90%)
- **Validation accuracy** should track training (within 10%)
- **Loss** should decrease steadily
- **Early stopping** will halt if no improvement

Good signs:
- ✅ Accuracy increasing each epoch
- ✅ Val accuracy close to train accuracy
- ✅ Loss decreasing smoothly

Bad signs:
- ❌ Val accuracy much lower than train (overfitting)
- ❌ Accuracy not improving (learning rate issue)
- ❌ Loss not decreasing (data/model issue)

### 7. Troubleshooting

#### "No module named 'google.colab'"
- You're not running on Colab
- Upload notebook to Colab: https://colab.research.google.com/
- Or follow Option B above

#### "Dataset not found"
- Mount Drive cell must run successfully first
- Check the shared folder is added to your Drive
- Verify folder name matches `DATASET_FOLDER_NAME`
- Try: `!ls /content/drive/MyDrive/` to see available folders

#### "Out of memory" during training
Solution 1: Reduce batch size
```python
CONFIG['BATCH_SIZE'] = 8  # or even 4
```

Solution 2: Reduce image size
```python
CONFIG['IMG_SIZE'] = 160  # instead of 224
```

Solution 3: Reduce sequence length
```python
CONFIG['SEQUENCE_LENGTH'] = 20  # instead of 30
```

#### "Runtime disconnected"
- Colab free tier has time limits
- Save your model checkpoints regularly
- Consider Colab Pro if needed
- Reconnect and continue from checkpoint

### 8. After Training Completes

The notebook will produce:

1. **usl_model.tflite** - Your trained model (download this!)
2. **labels.json** - Label mapping (download this!)
3. **best_usl_model.h5** - Full model (for retraining)
4. **training_curves.png** - Training visualization
5. **training_log.csv** - Detailed metrics

Files are saved in:
- Colab: `/content/` and `/content/drive/MyDrive/USL_Models/`
- Downloads folder (if you run the download cell)

### 9. Next Steps

After downloading the model:

```bash
# In your project directory (VSCode terminal)
# Create models folder
mkdir assets\models

# Copy downloaded files
# Move usl_model.tflite to assets/models/
# Move labels.json to assets/data/
```

Then integrate into your Flutter app (let me know when ready!).

### 10. Tips for Best Results

**Before training:**
- ✅ Verify all videos load correctly
- ✅ Check class distribution (balanced is best)
- ✅ Ensure GPU is enabled
- ✅ Have at least 50-100 videos per sign class

**During training:**
- ✅ Monitor validation accuracy (should be >70%)
- ✅ Let early stopping work (don't stop manually)
- ✅ Save checkpoints to Drive

**After training:**
- ✅ Test on videos not in training set
- ✅ Check confusion matrix for problem classes
- ✅ Iterate if accuracy is low (<70%)

## Need Help?

Common questions:

**Q: How long will training take?**
A: 2-4 hours with GPU, depends on dataset size

**Q: Can I close my laptop?**
A: No! Keep browser/VSCode open. Colab needs connection.

**Q: What if accuracy is low?**
A: Need more data, better quality videos, or tune hyperparameters

**Q: Can I pause and resume?**
A: Use checkpoints. Model is saved automatically in `best_usl_model.h5`

Ready to start? Open the notebook and run cells in order! 🚀
