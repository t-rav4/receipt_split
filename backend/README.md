# Receipt-Split API

⚡ A FastAPI-based backend that extracts structured item data from receipt PDFs.  
It processes uploaded PDFs, extracts text using `pdfplumber`, and applies regex to parse item names and prices into JSON format.  

## 🛠 Tools & Technologies Used
- **FastAPI** - Lightweight, high-performance web framework  
- **Supabase** - PostgreSQL-based database service with authentication & storage
- **pdfplumber** - PDF text extraction library  
- **Regex (`re` module)** - For parsing receipt text  
- **Python 3.8+** - Required to run the server  

## 🚀 How to Run Locally

1️⃣ Create an `.env` file in the root of this project, and add the following variables with their respective values:
- `user`, `password`, `host`, `port`, `dbname`

2️⃣ Create a Virtual Environment (Optional but Recommended)

`python -m venv venv`
`source venv/bin/activate`  # On macOS/Linux
`venv\Scripts\activate`     # On Windows

3️⃣ Install Dependencies

`pip install -r requirements.txt`


4️⃣ Create Tables in Database:

`python -c "from database import Base, engine; Base.metadata.create_all(engine)"`


5️⃣ Run the Server

`uvicorn server:app --host 0.0.0.0 --port 8000 --reload`


6️⃣ Test the API

Once running, open your browser and go to:
📄 Swagger UI: http://127.0.0.1:8000/docs




🌍 Deployment (To Be Filled Later)

Hosting platform (e.g., Railway, Render, Fly.io, AWS) and add deployment instructions soon.

