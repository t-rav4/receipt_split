from fastapi import FastAPI, File, HTTPException, UploadFile, Depends
from sqlalchemy.orm import Session
import re
import uuid
import pdfplumber
from io import BytesIO
from pydantic import BaseModel
from models.models import User
from database import get_db

app = FastAPI()


def extract_items_from_text(text: str):
    """Extracts items from the receipt text using regex."""
    item_pattern = re.compile(r"(?P<name>[\w\s\-%\*]+)\s+(?P<price>\d+\.\d{2})")
    matches = item_pattern.findall(text)

    items = []
    for match in matches:
        name = match[0].strip()
        price = float(match[1])
        items.append({"name": name, "price": price})

    return items


@app.post("/extract-receipt/")
async def extract_receipt(file: UploadFile = File(...)):
    """API endpoint to extract receipt data from a PDF."""
    try:
        pdf_bytes = await file.read()
        pdf = pdfplumber.open(BytesIO(pdf_bytes))

        full_text = "\n".join(
            page.extract_text() for page in pdf.pages if page.extract_text()
        )
        pdf.close()

        items = extract_items_from_text(full_text)
        return {"items": items}

    except Exception as e:
        return {"error": str(e)}


@app.get("/users/")
def get_users(db: Session = Depends(get_db)):
    return db.query(User).all()


class CreateOrUpdateUser(BaseModel):
    name: str
    colour: str


@app.post("/users/")
def create_user(user: CreateOrUpdateUser, db: Session = Depends(get_db)):
    new_user = User(id=uuid.uuid4(), name=user.name, colour=user.colour)

    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@app.put("/users/{user_id}")
def update_user(user_id: str, user: CreateOrUpdateUser, db: Session = Depends(get_db)):
    # Find the existing user by ID
    existing_user = db.query(User).filter(User.id == user_id).first()

    if not existing_user:
        raise HTTPException(status_code=404, detail="User not found")

    existing_user.name = user.name
    existing_user.colour = user.colour

    db.commit()
    db.refresh(existing_user)
    return existing_user


@app.delete("/users/{id}")
def delete_user(id: str, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.id == id).first()

    if not existing_user:
        raise HTTPException(status_code=404, detail="User not found")

    db.delete(existing_user)
    db.commit()
