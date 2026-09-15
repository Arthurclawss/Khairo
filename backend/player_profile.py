import json
import os
from datetime import datetime

# Classe que simula o Modelo de Dados do jogador para um Backend (ex: Supabase, Firebase, ou Local Save)
class PlayerProfile:
    def __init__(self, player_id: str, name: str):
        self.player_id = player_id
        self.name = name
        self.level = 1
        self.experience = 0
        self.techniques_unlocked = ["direto_de_ruptura", "cruzado_curto", "teep_de_contencao"]
        self.techniques_equipped = ["direto_de_ruptura", "cruzado_curto"] # Máximo de 3 espaços segundo o GDC
        self.last_updated = datetime.now().isoformat()

    def gain_experience(self, amount: int):
        self.experience += amount
        # Lógica super simples de level up mockada
        if self.experience >= self.level * 100:
            self.experience -= self.level * 100
            self.level += 1
            print(f"Level UP! Nível atual: {self.level}")
        self.update_timestamp()

    def equip_technique(self, technique_id: str, slot_index: int):
        if technique_id not in self.techniques_unlocked:
            print("Técnica não desbloqueada!")
            return False
            
        if slot_index < 0 or slot_index >= 3:
            print("Slot inválido! O lutador só tem 3 espaços de técnicas na campanha.")
            return False

        # Preenche com None se a lista for menor que 3
        while len(self.techniques_equipped) <= slot_index:
            self.techniques_equipped.append(None)
            
        self.techniques_equipped[slot_index] = technique_id
        self.update_timestamp()
        return True

    def unlock_technique(self, technique_id: str):
        if technique_id not in self.techniques_unlocked:
            self.techniques_unlocked.append(technique_id)
            self.update_timestamp()

    def update_timestamp(self):
        self.last_updated = datetime.now().isoformat()

    def to_dict(self):
        return {
            "player_id": self.player_id,
            "name": self.name,
            "level": self.level,
            "experience": self.experience,
            "techniques_unlocked": self.techniques_unlocked,
            "techniques_equipped": self.techniques_equipped,
            "last_updated": self.last_updated
        }

    def save_to_file(self, filename="save_data.json"):
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(self.to_dict(), f, ensure_ascii=False, indent=4)
        print(f"Progresso salvo em {filename}")

if __name__ == "__main__":
    # Testando o script isoladamente
    player = PlayerProfile("user_123", "Khairo")
    player.gain_experience(150)
    player.equip_technique("teep_de_contencao", 2)
    player.save_to_file()
