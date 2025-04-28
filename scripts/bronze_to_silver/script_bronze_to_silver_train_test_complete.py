import os
import psycopg2
from psycopg2 import sql
from tqdm import tqdm
import getpass

# Perguntar as credenciais
db_user = input("Digite o usuário do banco de dados: ")
db_name = input("Digite o nome do banco de dados: ")
db_password = getpass.getpass(f"Digite a senha para o usuário {db_user}: ")

# Conectar ao banco
try:
    conn = psycopg2.connect(
        dbname=db_name,
        user=db_user,
        password=db_password,
        host="localhost",
        port=5432
    )
    conn.autocommit = True
    cur = conn.cursor()
except Exception as e:
    print(f"Erro ao conectar no banco: {e}")
    exit(1)

# Caminho da pasta onde estão os scripts
scripts_path = "./"  # ajuste se precisar

# Listar todos os arquivos .sql, ignorando o específico
scripts = []
for root, dirs, files in os.walk(scripts_path):
    for file in files:
        if file.endswith(".sql") and file != "calculo_qtde_clientes_treino_teste.sql":
            scripts.append(os.path.join(root, file))

scripts.sort()  # garantir ordem alfabética

# Executar com barra de progresso
for script in tqdm(scripts, desc="Executando scripts", unit="script"):
    print(f"\n📄 Executando: {os.path.basename(script)}")

    with open(script, "r", encoding="utf-8") as f:
        sql_commands = f.read()

    try:
        cur.execute(sql.SQL(sql_commands))
    except Exception as e:
        print(f"❌ Erro ao executar {script}:\n{e}\n")
        conn.rollback()
        # Você pode descomentar a linha abaixo para parar o programa no erro
        # break

# Fechar conexões
cur.close()
conn.close()

print("\n✅ Execução concluída!")
