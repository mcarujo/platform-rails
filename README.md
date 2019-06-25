## Ruby on Rails 5

- Para criação desta API foi utilizado o Ruby on Rails na versão 5.
- O banco de dados para desenvolvimento é o `sqlite3` porém em caso de colocar a API para produção recomenda-se um banco de dados como `MySQL` ou `Postgres` para colocar em produção.

## Instalação

- Partindo do pressuposto que você já tem um `ruby` instalado na sua máquina e tudo mais, você só precisará instalar todas as dependências do projeto com o comando `bundle install`. Além disso você precisa ter o banco de dados `sqlite3` instalado no servidor, você pode acessar informações para este procedimento nesse [link](https://www.sqlite.org/download.html).
- Ao finalizar a instalação das dependências, você deve subir o banco de dados pelo _migrate_, para isso você pode digitar o comando `rails db:migrate` dentro do diretório do projeto. Após isso você pode subir dados fictícios para melhor visualização com o comando `rails db:seed`.

## Entidades

- Toda a estrutura de banco de dados foi feita realizado com o `migrations` do ruby on rails.

### Ordem

- Para a entidade `order` foi feita a seguinte estrutura no `migrations`. Uma observação que deve ser feita é que a coluna 'lineItems' é um campo `text` o qual guarda um `JSON` e é tratado pela API da mesma forma.

  ```ruby
    class CreateOrders < ActiveRecord::Migration[5.2]
      def change
        create_table :orders do |t|
          t.string :reference, null: false
          t.string :purchaseChannel, null: false
          t.string :clientName, null: false
          t.string :address, null: false
          t.string :deliveryService, null: false
          t.float :totalValue, null: false
          t.text :lineItems, null: false
          t.string :status, null: false

          t.timestamps
        end
      end
    end
  ```

### Batch

- Para a entidade `batch` foi feita uma estrutura bem semelhante a anterior. Um detalhe importante é que o campo _orders_ ("A group of orders") também é um campo `text` no banco de dados o qual guarda um `JSON` e é tratado como um `JSON` por toda a API.

  ```ruby
    class CreateBatches < ActiveRecord::Migration[5.2]
    def change
        create_table :batches do |t|
        t.string :reference, null: false # Reference (e.g. 201803-54)
        t.string :purchaseChannel, null: false # Purchase Channel(e.g. Site BR)
        t.text :orders, null: false # A group of orders.

        t.timestamps
        end
    end
    end
  ```

### Um pouco mais detalhes (A few more details)

- Sobre o primeiro ponto destacado, em nenhum momento da API criará alguma `batch` com `orders` de diferentes `Purchase Channel`, Nem na rota de criação e nem do `faker`, para mais detalhes convido a análise do método `create` presente no controller [orders_controller.rb](https://github.com/mcarujo/RailsHelloWorld/blob/master/helloworld/app/controllers/orders_controller.rb) e do arquivo [seeds.rb](https://github.com/mcarujo/RailsHelloWorld/blob/master/helloworld/db/seeds.rb).

- Apenas as tabelas `orders` e `batches` foram criadas e utilizadas.

## Ações (Actions)

### Create a new Order

- Para criar uma ordem, precisamos enviar uma requisição `POST` para a rota `/order` com os campos 'purchaseChannel', 'clientName', 'address', 'deliveryService', 'totalValue', 'lineItems' e 'status' válidos, isto é não sendo nulo. Ao receber essas informações, é gerado o campo 'reference' com a chamada do método 'helper' 'definePKOrders'. Caso tenha sucesso na gravação da nova order, retornamos a informação ao usuário, caso contrário retornamos uma mensagem de erro.

```ruby
    def create # Create a new Order
        postFields = params.permit(:purchaseChannel, :clientName, :address, :deliveryService, :totalValue, :lineItems, :status)
        order = Order.new postFields
        order.reference = definePKOrders()
        if order.save
            json = {message:'Order created', data: order.reference}
        else
            json = {message: order.errors.full_messages, data: false}
        end
        render json: json, status: :ok
    end
```

### Get the status of an Order

- Para buscar informações com o nome do cliente, precisamos enviar uma requisição com o verbo `GET`para a rota `/order/search/status/name` com o campo 'name' presente. Caso todos os dados forem devidamente recebidos, retornamos todas as ordens do cliente que não estiverem com o 'status' igual a 'sent', isto é enviado e portanto uma ordem já finalizada.

  ```ruby
      def showStatusByName # Get the status of an Order
          if !params.include?(:name) # Validation for name
              return render json: {message: "No field name", data: false},status: :ok
          end
          orders = Order.where(clientName: params[:name]).where.not(status: "sent")
          orders = cutInformationByStatus(orders) # clean the return
          render json: {message: 'Orders status by name', data: orders},status: :ok
      end

  ```

### List the Orders of a Purchase Channel

- Para buscar informações de um _Purchase Channel_ com um determinado _Status_ precisamos enviar estes dois dados para a rota `/order/search/purchasechannel` com o verbo `GET`.
  Caso seja enviado todos os campos corretamente, será retorno o resultado da pesquisa, se não será retornado uma mensagem de erro com o campos de retorno com valor _false_.

  ```ruby
         def showListByPurchaseChannel # List the Orders of a Purchase Channel
        if !params.include?(:purchaseChannel) # Validation for Purchase Channel
            json = {message: "No field purchaseChannel", data: false}
        elsif !params.include?(:status) # Validation Status
            json = {message: "No field status", data: false}
        else
            orders = Order.where(purchaseChannel: params[:purchaseChannel], status: params[:status])
            json = {message: "Orders status by purchase channel and status", data: orders}
        end
        render json: json, status: :ok
    end

  ```

### Create a Batch

- Para criar um novo Batch, precisamos receber uma requisição com o verbo `POST` na rota `/batch` com o campo 'purchaseChannel'. Ao receber a requisição,
  verificamos se o campo está presente e após isso buscamos todas as _orders_ presentes com este 'purchaseChannel' que estão com o 'status' igual a 'ready' isto é, o pedido ou melhor a
  _order_ está recém criada e pronta para ser produzida. Caso nenhuma _order_ seja encontrada, retornamos essa informação para o usuário, caso contrário geramos uma
  'reference' para o novo _batch_ com o método do 'helper' chamado 'definePKBatches', marcamos todas as _orders_ encontradas como 'production' e salvamos estas em um array de `json` no campo 'orders'.

  ```ruby
     def create # Create a Batch
        if !params.include?(:purchaseChannel) # Validation for name
            return render json: {message: "No field purchaseChannel", data: false},status: :ok
        end

        purchaseChannel = params[:purchaseChannel]
        orders = Order.where(purchaseChannel: purchaseChannel, status: 'ready')

        if orders.size == 0
            return render json: {message:"Has no order to create a batch for '#{purchaseChannel}''", data: false}, status: :ok
        end

        batch = Batch.new
        batch.reference = definePKBatches()
        batch.purchaseChannel = purchaseChannel

        ordersReferences = []
        orders.each do |order|
            order.status = 'production'
            ordersReferences << order.reference
            order.save
        end

        batch.orders = ordersReferences.to_json
        if batch.save
            json = {message:'Batch created', data: {reference: batch.reference, numOrders: orders.size}}
        else
            json = {message: batch.errors.full_messages, data: false}
        end
        render json: json, status: :ok
    end

  ```

### Produce a Batch

- Para produzir um _Batch_ precisamos receber a 'reference' do mesmo, ai iremos verificar se alguém ordem presente no _Batch_ está disponível para transitar do estado de 'production' para o de 'closing'.

```ruby
    def produce # Produce a Batch
        if !params.include?(:reference) # Validation
            return render json: {message:'No field reference', data: false}, status: :ok
        end
        batch = Batch.find_by(reference: params[:reference])
        if batch == nil # did I found something?
            return render json: {message:'No batch found', data: false}, status: :ok
        end
        orders = JSON.parse(batch.orders.to_s)
        order_references = []
        orders.each do |reference|
            order = Order.find_by(reference: reference)
            if order.status == 'production' # if was printed...
                order.status = 'closing' # set already produced (closing)
                order.save
                order_references << order.reference
            end
        end
        render json: {message:'Batch produced and returned orders references', data: order_references}, status: :ok
    end

```

### Close part of a Batch for a Delivery Service

- Para fechar um _Batch_ precisamos receber além da 'reference' o campo 'deliveryService', aí iremos verificar se alguma ordem presente no _Batch_ está disponível para transitar do estado de 'closing' para o de 'sent' além de ter o mesmo 'deliveryService' do informado pelo usuário. Isto significa que a ordem foi entregue pelo serviço de entrega.

```ruby
 def close # Close part of a Batch for a Delivery Service
        if !params.include?(:reference) # Validation
            return render json: {message:'No field reference', data: false}, status: :ok
        elsif !params.include?(:deliveryService)
            return render json: {message:'No field deliveryService', data: false}, status: :ok
        end
        devileryService = params[:deliveryService]
        batch = Batch.find_by(reference: params[:reference])
        if batch == nil # did I found something?
            return render json: {message:'No batch found', data: false}, status: :ok
        end
        orders = JSON.parse(batch.orders.to_s)
        order_references = []
        orders.each do |reference|
            order = Order.find_by(reference: reference)
            if order.deliveryService == devileryService && order.status == 'closing'
                order.status = 'sent'
                order.save
                order_references << order.reference
            end
        end
        render json: {message:'Batch closed and returned orders references', data: order_references}, status: :ok
    end
```

### A simple financial report

- O relatório financeiro é simplesmente um somatório de todas as ordens em aberto por canal de venda (Purchase Channel).

```ruby
    def financialReport # A simple financial report
        report = Order.select("purchaseChannel, count(reference) as quantity, sum(totalValue) as total").where.not(status: 'sent').group('purchaseChannel')
        render json: {message:'Financial Report', data: report}, status: :ok
    end
```

## Melhorias (Additional Stuff)

- A camada de segurança pode ser realizada através de uma verificação de usuário, um padrão de autorização muito eficiente é o JWT, em que basicamente consiste em o usuário fazer o login, e receber um token em caso de sucesso de login e em cada requisição feita na API deve-se informar este mesmo token. Para mais informações acessar o [site](https://jwt.io/). O fluxo de funcionamento é exibido na imagem abaixo, onde primeiramente é feito o login pelo usuário, este por sua vez recebe o JWT, e armazena o mesmo para quando for enviar uma requisição para a API este JWT seja verificado e em caso de sucesso é retornado o dado requerido pelo usuário. Dessa forma ninguém sem um acesso válido que este seria liberado por nós, conseguiria ter acesso a API. Lembrando que para a implantação deste padrão de autenticação e navegação deve-se criar toda uma estrutura na API e no banco de dados.

- Já uma camada de permissões por usuários, o nosso problema deve ser resolvido de maneira mais simples se a proposta da camada de segurança já estiver implantada, pois ao informar o token(JWT) podemos saber qual usuário de fato está fazendo a requisição. Podemos referenciar cada 'order' e 'batch' ao usuário que a criou ou um grupo de usuários, e sendo assim qualquer modificação só pode ser feita pelo mesmo usuário ou grupo. Porém essa regra pode ter uma exceção, onde um usuário chamado de 'Admin' poderia editar qualquer 'order' e 'batch' independente de quem a tenha criado. Para que isso tudo funcione precisamos de uma modificação da estrutura do banco de dados e da API.

- Para alterar uma ordem que já está em produção, devemos ter muito cuidado para não permitir que qualquer usuário possa mudar/alterar uma 'order' em produção, acredito que o ideal deve apenas permitir usuários com poderes 'administradores' ou algo semelhante a 'supervisores' possam realizar essa mudança. Do ponto de vista estrutural, a coluna no banco de dados onde guarda as informações dos objetos poderia ser mudado de tipo 'text' para uma coluna do tipo [json](https://www.postgresql.org/docs/9.4/datatype-json.html), o qual daria um suporte melhor para alterações de informações presente no array de json de maneira mais simples. Além disso terá que ser visto com a equipe de logística se uma ordem com status 'production' for alterada, para qual estado essa ordem deve ficar, continuar 'production' ou voltar para o estado 'ready'.

- Sobre uma web UI, ou melhor uma interface web para visualização, acredito que a solução mais rápida seria a utilização da camada de visualização disponível no próprio Rails, porém a longo prazo não acho que seria a melhor opção. Tendo em conhecimento que temos diversos frameworks web para criação de interface que mostram serem mais flexíveis/portáveis para funcionamento, como por exemplo o [React](https://pt-br.reactjs.org/) onde você é capaz de fazer uma interface Web, e reaproveitar parcialmente o código para uma futuro projeto de criação de um aplicativo mobile para utilizar essa mesma API.
