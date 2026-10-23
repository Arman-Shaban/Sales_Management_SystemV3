#person1
# Arman
from dataclasses import dataclass


@dataclass
class Customer:
    name: str
    email: str
    phone: str = ""
    address: str = ""
    id: int | None = None
    created_at: str | None = None
