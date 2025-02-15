from database import Base, engine
from models.models import User # Import the users model/table so that it's included in create call

Base.metadata.create_all(engine)
