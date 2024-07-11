from flask import Flask, jsonify
import mysql.connector as mysql
from urllib.request import urlopen
import json


servico = Flask("produtos")

SERVIDOR_BANCO = "banco"
USUARIO_BANCO = "root"
SENHA_BANCO = "admin"
NOME_BANCO = "marcas"


def get_conexao_db():
    conexao = mysql.connect(host=MYSQL_SERVER, user=MYSQL_USER, password=MYSQL_PASS, database=MYSQL_BANCO)
    return conexao

@servico.get("/info")
def get_info():
    return jsonify(
        descricao = "serviço de produtos do Melhores Marcas",
        autor = "Davi",
        versao = "1.0"
    )

@servico.get("/produtos/<int:id_produto>/<int:tamanho_pagina>")
def get_produtos(id_produto, tamanho_pagina):
    produtos = []

    conexao = get_conexao_db()
    cursor = conexao.cursor(dictionary=True)
    cursor.execute(

        "SELECT feeds.id as produto_id, DATE_FORMAT(feeds.data, '%Y-%m-%d %H:%i') as data, " +
            "empresas.id as empresa_id, empresas.nome as nome_empresa, empresas.avatar, produtos.nome as nome_produto, produtos.descricao, FORMAT(produtos.preco, 2) as preco, " + 
            "produtos.url, produtos.imagem1, IFNULL(produtos.imagem2, '') as imagem2, IFNULL(produtos.imagem3, '') as imagem3 " +
        "FROM feeds, produtos, empresas " +
        "WHERE produtos.id = feeds.produto " +
        "AND empresas.id = produtos.empresa " +
        "AND feeds.id > " + str(id_produto) + 
        "ORDER BY produto_id ASC, data DESC " +
        "LIMIT " + str(tamanho_pagina)

    )

    produtos = cursor.fetchall()
    conexao.close()

    return jsonify(produtos)

if __name__ == "__main__":
    servico.run("0.0.0.0", debug=True)