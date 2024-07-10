from flask import Flask, jsonify

servico = Flask("likes")

@servico.get("/info")
def get_info():
    return jsonify(
        descricao = "serviço de likes do Melhores Marcas",
        autor = "Davi",
        versao = "1.0"
    )

if __name__ == "__main__":
    servico.run("0.0.0.0", debug=True)