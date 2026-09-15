import json
import os
import glob

def load_all_styles():
    """Lê dinamicamente todos os arquivos JSON de estilo na pasta styles/"""
    base_dir = os.path.join(os.path.dirname(__file__), "styles")
    
    catalog = {"techniques": {}}
    
    # Se a pasta não existir, cria vazia para evitar erros
    if not os.path.exists(base_dir):
        os.makedirs(base_dir)
        return catalog
        
    search_pattern = os.path.join(base_dir, "*.json")
    
    for filepath in glob.glob(search_pattern):
        with open(filepath, "r", encoding="utf-8") as f:
            data = json.load(f)
            # Adiciona as técnicas deste arquivo ao catálogo mestre
            catalog["techniques"].update(data)
            
    return catalog

def export_catalog(output_path: str = "repertoire.json"):
    """Exporta o catálogo mestre combinando todos os estilos na raiz do projeto Khairo."""
    master_catalog = load_all_styles()
    
    # O script está em backend/catalog, então subimos duas pastas para salvar na raiz do projeto
    project_root = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    final_output = os.path.join(project_root, output_path)
    
    with open(final_output, "w", encoding="utf-8") as f:
        json.dump(master_catalog, f, ensure_ascii=False, indent=4)
        
    print(f"Catálogo mestre dinâmico (com {len(master_catalog['techniques'])} técnicas) exportado para: {final_output}")

if __name__ == "__main__":
    export_catalog()
