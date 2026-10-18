#person1

# Arman Test modern programming

from dataclasses import dataclass


@dataclass
class Product:
    sku: str
    name: str
    unit_price: int  # minor units (cents)
    is_active: bool = True
    id: int | None = None
    created_at: str | None = None
