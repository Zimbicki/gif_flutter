giphy Random App ✨
📖 Sobre o Projeto
O Giphy Random App é um cliente móvel, moderno e performático para a API do Giphy, construído com Flutter. Ele permite que os usuários explorem o universo divertido dos GIFs de forma simples e intuitiva.

Além de ser uma ferramenta de entretenimento, este projeto serve como um exemplo prático e robusto de desenvolvimento com Flutter 3.x, demonstrando boas práticas de arquitetura de software, gerenciamento de estado e consumo de APIs RESTful.

🚀 Key Features
🔍 Busca de GIFs: Pesquise GIFs por palavra-chave e veja os resultados em uma grade dinâmica e responsiva.

📈 GIFs em Alta: Explore os GIFs mais populares do momento (trending) diretamente na tela inicial.

🌗 Tema Claro e Escuro: Alterne entre os temas para uma experiência visual mais confortável em qualquer ambiente.

💾 Persistência de Dados: Suas preferências de tema são salvas localmente com shared_preferences, garantindo uma experiência consistente entre sessões.

🏗️ Arquitetura Limpa: O código é organizado com base em features, promovendo escalabilidade e manutenibilidade.

🛠️ Decisões Técnicas
A arquitetura e as escolhas técnicas deste projeto foram pensadas para garantir um código limpo, escalável e de fácil manutenção.

Arquitetura Limpa (Baseada em Features): O projeto é estruturado em features (como home, settings) e uma camada core (para serviços, modelos). Isso isola as responsabilidades, facilitando a adição de novas funcionalidades e a manutenção do código existente.

Gerenciamento da API Key: Para proteger a chave da API do Giphy, ela é injetada em tempo de compilação através de variáveis de ambiente do Dart (--dart-define). Isso evita que a chave seja exposta no controle de versão, uma prática essencial de segurança.

Inicialização Assíncrona: O método main() é assíncrono para garantir que serviços essenciais, como o carregamento das preferências do usuário (shared_preferences), sejam concluídos antes da renderização da UI. Isso previne mudanças de estado inesperadas na inicialização.

Tratamento de Erros: O serviço de comunicação com a API (GiphyService) possui um tratamento de erros robusto, capturando falhas de rede e respostas inválidas da API. Isso permite que a UI exiba feedbacks claros ao usuário, como mensagens de erro ou estados de carregamento.

📸 Screenshots
Tema Claro

Tema Escuro





Tela principal com GIFs em alta.

A mesma tela no modo escuro.

(Observação: substitua os links docs/screens/*.png pelos caminhos reais das suas imagens.)

🚀 Getting Started
Para executar este projeto localmente, siga os passos abaixo.

Pré-requisitos
Flutter SDK: Versão 3.x ou superior.

Dart SDK: Versão 3.x ou superior.

Um emulador (Android/iOS) ou um dispositivo físico.

Instalação
Clone o repositório:

git clone [https://github.com/SEU-USUARIO/giphy-random-app.git](https://github.com/SEU-USUARIO/giphy-random-app.git)
cd giphy-random-app

Instale as dependências:

flutter pub get

Configuração da API Key
Este projeto requer uma chave de API do Giphy. Obtenha a sua no Giphy Developers Portal.

Para executar o app, injete a sua chave usando o comando --dart-define:

flutter run --dart-define=GIPHY_API_KEY=SUA_CHAVE_AQUI

Substitua SUA_CHAVE_AQUI pela sua chave da API.

▶️ Usage
Após a instalação, o aplicativo será iniciado no seu dispositivo ou emulador.

Na tela inicial, você verá uma grade com os GIFs que estão em alta no momento.

Use a barra de pesquisa no topo para buscar GIFs por qualquer termo.

Acesse a página de configurações para alternar entre o tema claro e escuro. Sua escolha será salva para a próxima vez que você abrir o app.

🤝 Contribuindo
Contribuições são o que tornam a comunidade open-source um lugar incrível para aprender, inspirar e criar. Qualquer contribuição que você fizer será muito bem-vinda.

Faça um Fork do projeto.

Crie uma Branch para sua feature (git checkout -b feature/AmazingFeature).

Faça um Commit com suas mudanças (git commit -m 'Add some AmazingFeature').

Faça um Push para a Branch (git push origin feature/AmazingFeature).

Abra um Pull Request.