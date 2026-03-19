# == Schema Information
#
# Table name: reports
#
#  id         :bigint           not null, primary key
#  content    :text
#  prompt     :string           not null
#  status     :string           default(NULL), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer          not null
#
# Indexes
#
#  index_reports_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
class Report < ApplicationRecord
  enum :status, { pending: 0, completed: 1, failed: 2 }

  belongs_to :company

  validates :prompt, presence: true
  validates :content, presence: true
  validates :status, presence: true

  def generate
    ai_service = Ai::Google.new(user: user)
    response = ai_service.generate_text(prompt: prompt)

    self.content = response
    self.status = "completed"
    self.save!
  end

  def self.generate_sales_report!(company)
    three_months_ago = 3.months.ago

    clients = company.clients.includes(:orders, :addresses)
    recent_orders = company.orders.includes(:client, :order_products, :products, :payment_methods, :payments)
                           .where(created_at: three_months_ago..Time.current)
                           .where(status: :paid)

    sellers = recent_orders.joins(payments: :user).group("users.id, orders.id").select(
      "users.id as user_id",
      "users.name as user_name",
      "orders.*",
      "SUM(payments.value_expected_cents) as value_expected_cents",
      "SUM(payments.value_received_cents) as value_received_cents"
    ).order("value_expected_cents DESC")

    sellers_data = sellers.map do |seller|
      {
        id: seller.user_id,
        name: seller.user_name,
        valueExpected: {
          value: seller.value_expected_cents,
          currency: "BRL",
          formatted: Money.new(seller.value_expected_cents, "BRL").format
        }
      }
    end

    sellers_by_month = sellers.index_by { |seller| seller.user_id }
                              .group_by { |seller| seller.last.created_at.strftime("%B/%Y") }
                              .transform_values { |sellers| sellers.sum { |seller| seller.last.value_expected_cents } }

    clients_data = clients.map do |client|
      client_orders = client.orders.where(created_at: three_months_ago..Time.current, status: :paid)
      next if client_orders.empty?

      {
        name: client.name,
        age: client.age,
        gender: client.gender,
        instagram: client.instagram_profile,
        phone: client.phone,
        email: client.email,
        total_orders: client_orders.count,
        total_spent: client_orders.sum { |o| o.total_value.to_f },
        last_order_date: client_orders.maximum(:created_at)&.strftime("%d/%m/%Y"),
        days_since_last_order: client_orders.maximum(:created_at) ? (Time.current - client_orders.maximum(:created_at)).to_i / 86400 : nil,
        orders_details: client_orders.order(created_at: :desc).map do |order|
          {
            date: order.created_at.strftime("%d/%m/%Y"),
            value: order.total_value.to_f,
            products: order.products.pluck(:name).join(", "),
            payments: order.internal_payments.map do |payment|
              {
                user_id: payment.user_id,
                user_name: payment.user.name,
                value_expected: payment.value_expected.to_f,
                value_received: payment.value_received.to_f,
                payment_method: payment.payment_method&.name
              }
            end
          }
        end
      }
    end.compact

    top_products = recent_orders.flat_map(&:products)
                                .group_by(&:name)
                                .transform_values(&:count)
                                .sort_by { |_, count| -count }
                                .first(10)
                                .to_h

    orders_summary = {
      total_orders: recent_orders.count,
      total_revenue: recent_orders.sum { |o| o.total_value.to_f },
      average_ticket: recent_orders.count > 0 ? (recent_orders.sum { |o| o.total_value.to_f } / recent_orders.count).round(2) : 0,
      orders_by_month: recent_orders.group_by { |order| order.created_at.strftime("%B/%Y") }
                                    .transform_values(&:count),
      revenue_by_month: recent_orders.group_by { |order| order.created_at.strftime("%B/%Y") }
                                     .transform_values { |orders| orders.sum { |o| o.total_value.to_f }.round(2) },
      top_products: top_products
    }

    sellers_performance = sellers_data.map do |seller|
      seller_by_month = sellers_by_month[seller[:id]] || {}

      recent_orders_by_seller = recent_orders.select { |o| o.internal_payments.any? { |p| p.user_id == seller[:id] } }

      {
        name: seller[:name],
        total_revenue: seller[:valueExpected][:value],
        revenue_by_month: seller_by_month.transform_values { |v| v.round(2) },
        orders_count: recent_orders_by_seller.count,
        average_per_order: recent_orders_by_seller.count > 0 ? (seller[:valueExpected][:value] / recent_orders_by_seller.count).round(2) : 0,
        percentage_of_total: recent_orders_by_seller.sum { |o| o.total_value.to_f } > 0 ? ((seller[:valueExpected][:value] / recent_orders.sum { |o| o.total_value.to_f }) * 100).round(2) : 0
      }
    end

    sales_prompt = "#{report_prompt(company)}

📊 DADOS DOS CLIENTES DOS ÚLTIMOS 3 MESES (#{clients_data.count} clientes):
#{JSON.pretty_generate(clients_data)}

💰 RESUMO GERAL DAS VENDAS:
#{JSON.pretty_generate(orders_summary)}

#{sellers_performance.map { |seller| "👤 PERFORMANCE INDIVIDUAL - #{seller[:name]}: \n#{JSON.pretty_generate(seller)}" }.join("\n\n")}

Analise profundamente estes dados e gere o relatório completo conforme solicitado, com insights valiosos e acionáveis."

    report = Report.new(
      company: company,
      prompt: sales_prompt,
      status: :pending
    )

    # report.generate
    report
  end

  private

  def self.report_prompt(company)
    professionals = company.users
    names = professionals.map { it.name.split(" ").first.capitalize }.join(", ")

    "Você é um consultor especializado em análise de vendas, marketing e gestão de pessoas para negócios de beleza e perfurações corporais.

    ## 💎 CONTEXTO DO ESTÚDIO GLAMOUR

    **Nome:** Estúdio Glamour
    **Equipe:** #{professionals.size} profissionais (#{names}) - **IMPORTANTE:** Elas são PARCEIRAS DE TRABALHO que colaboram juntas para o sucesso do estúdio. NÃO são concorrentes ou competitivas entre si. Trabalham em EQUIPE para o crescimento do negócio.
    **Instagram:** ~5.000 seguidores
    **Porte:** Pequeno/médio porte - foque em sugestões práticas, realistas e de baixo custo
    **Período Analisado:** Últimos 3 meses

    ## 📋 DADOS DISPONÍVEIS

    Você receberá dados estruturados contendo:
    - **Clientes:** Nome, idade, gênero, Instagram, telefone, email, histórico de compras, dias desde última compra
    - **Vendas Gerais:** Total de pedidos, faturamento, ticket médio, evolução mensal, produtos mais vendidos
    - **Performance Individual:** Faturamento de #{names} separadamente, incluindo evolução mensal e participação no faturamento total
    - **Produtos:** Itens mais vendidos e frequência de compra

    ## 🎯 SUA MISSÃO

    Gere um relatório estratégico COMPLETO e PROFUNDO em português brasileiro, formatado em markdown, com insights acionáveis e personalizados. O relatório deve ser estruturado assim:

    ---

    # 📊 RELATÓRIO DE VENDAS - ESTÚDIO GLAMOUR
    ## Análise dos Últimos 3 Meses

    ### 🎯 1. RESUMO EXECUTIVO
    - **Faturamento Total** (em R$)
    - **Total de Atendimentos/Vendas**
    - **Ticket Médio** por cliente
    - **Tendência** (crescimento ou queda mês a mês)
    - **3 Principais Insights** identificados
    - **Pontos Fortes** do estúdio
    - **Pontos de Atenção** que precisam de melhoria

    ### 👥 2. PERFIL DOS CLIENTES
    - **Faixa Etária Predominante** (percentuais)
    - **Distribuição por Gênero**
    - **Top 5 Clientes Mais Frequentes** (com valores gastos)
    - **Padrões de Comportamento:**
      - Frequência média de retorno
      - Sazonalidade (quais meses compraram mais)
      - Métodos de pagamento preferidos
    - **Segmentação:** Clientes VIP, clientes recorrentes, clientes inativos (há mais de 60 dias)

    ### 💅 3. ANÁLISE DE PRODUTOS E SERVIÇOS
    - **Top 10 Produtos/Serviços Mais Vendidos** (com quantidades)
    - **Análise de Sazonalidade** (quais produtos vendem mais em quais períodos)
    - **Oportunidades de Upsell/Cross-sell** identificadas
    - **Produtos com Baixa Performance** (que podem ser repensados ou descontinuados)
    - **Sugestões de Novos Serviços** baseadas nas tendências de mercado

    ### 🌟 4. CLIENTES COM MAIOR POTENCIAL DE COMPRA
    Liste **5-10 clientes** com maior probabilidade de comprar novamente, incluindo:
    - Nome do cliente
    - Idade e perfil
    - Histórico de compras (valores e frequência)
    - Dias desde a última compra
    - **Justificativa:** Por que este cliente tem alto potencial?
    - **Estratégia de Abordagem:** Como e quando contactar (WhatsApp, DM, ligação)
    - **Oferta Sugerida:** Qual produto/serviço oferecer especificamente para este cliente

    ### 💼 5. PERFORMANCES INDIVIDUAIS

    **Análise Detalhada:**
    - **Faturamento Total** nos 3 meses (R$)
    - **Evolução Mensal** (mês a mês em R$)
    - **Participação no Faturamento Total** (%)
    - **Número de Atendimentos**
    - **Ticket Médio** por atendimento

    **🎖️ Pontos Fortes:**
    - Liste 3-5 pontos fortes baseados nos dados
    - Comportamentos/estratégias que estão funcionando bem

    **📈 Oportunidades de Melhoria:**
    - Liste 3-5 áreas específicas onde devem melhorar
    - Seja construtivo, específico e acionável
    - Incluir sugestões de:
      - Como aumentar ticket médio
      - Como conquistar mais clientes
      - Como melhorar retenção
      - Técnicas de venda e abordagem
      - Produtos/serviços que pode focar mais

    **🎯 Plano de Ação para os próximos 30 dias:**
    - 3-5 ações específicas e práticas que devem implementar
    - Metas mensuráveis (ex: aumentar ticket médio em 15%)

    ### 🤝 7. SINERGIA DA EQUIPE - #{names}
    - **Análise dos Números da Equipe:** Visão integrada e colaborativa (NÃO competitiva)
    - **Perfis de Trabalho:** Identificar especialidades e talentos únicos de cada uma
    - **Forças Complementares:** Como as habilidades de uma potencializam a outra
    - **Oportunidades de Colaboração:** Estratégias para trabalharem ainda mais integradas
    - **Equilíbrio de Carga:** A distribuição de trabalho está saudável e justa para ambas?
    - **Crescimento em Conjunto:** Como o sucesso de uma impulsiona o sucesso da outra e do estúdio

    ### 🚀 8. ESTRATÉGIAS DE CRESCIMENTO PARA O ESTÚDIO

    **Para os Próximos 30 Dias:**
    - 5 ações imediatas e práticas
    - Campanhas de reativação de clientes inativos
    - Estratégias para aumentar ticket médio
    - Programa de indicação/fidelidade

    **Para os Próximos 90 Dias:**
    - Estratégias de médio prazo
    - Parcerias locais possíveis
    - Eventos ou promoções sazonais
    - Expansão de serviços

    ### 📱 9. ESTRATÉGIA DE MARKETING DIGITAL (5K SEGUIDORES)

    **Conteúdo para Instagram:**
    - 10 ideias específicas de posts/reels (com temas)
    - Frequência ideal de postagem
    - Melhores horários baseados no público-alvo
    - Stories: que tipo de conteúdo criar
    - Hashtags estratégicas locais

    **Engajamento:**
    - Como aumentar interação com os seguidores
    - Estratégias de DM para conversão
    - Enquetes e interações criativas
    - Colaborações com micro-influencers locais (baixo custo)

    **Conversão:**
    - Call-to-actions efetivos
    - Como transformar seguidores em clientes
    - Estratégia de agendamento online
    - Depoimentos e prova social

    ### 💡 10. RECOMENDAÇÕES ESPECÍFICAS E ACIONÁVEIS

    **Atendimento ao Cliente:**
    - Melhorias no processo de atendimento
    - Scripts de WhatsApp para diferentes situações
    - Follow-up pós-atendimento

    **Precificação:**
    - Análise se os preços estão adequados
    - Oportunidades de criar pacotes/combos
    - Estratégia de descontos inteligentes

    **Gestão Financeira:**
    - Como otimizar o faturamento
    - Controle de custos
    - Metas realistas para próximos meses

    **Experiência do Cliente:**
    - Como criar um atendimento memorável
    - Programa de fidelidade simples e efetivo
    - Brindes e mimos estratégicos

    ### ⚠️ 11. ALERTAS E RISCOS
    - Clientes em risco de abandono (há mais de 60 dias sem comprar)
    - Tendências negativas identificadas
    - Ações urgentes necessárias

    ### 🎊 12. CONCLUSÃO E PRÓXIMOS PASSOS
    - Resumo dos principais pontos
    - Prioridades para as próximas semanas
    - Motivação e palavras de encorajamento para #{names}

    ---

    ## 📝 DIRETRIZES IMPORTANTES

    1. **Use DADOS REAIS** fornecidos - cite números específicos sempre
    2. **Seja ESPECÍFICO** - evite generalidades, dê exemplos concretos
    3. **Seja CONSTRUTIVO** - críticas devem vir acompanhadas de soluções
    4. **Seja REALISTA** - considere o tamanho do negócio (5k seguidores)
    5. **Seja MOTIVADOR** - mantenha tom positivo e encorajador
    6. **Seja PRÁTICO** - toda sugestão deve ser implementável com baixo custo
    7. **Use EMOJIS** estrategicamente para facilitar leitura
    8. **Formate BEM** - use negrito, listas, tabelas quando apropriado
    9. **Personalize SEMPRE** - use os nomes #{names}, fale diretamente com elas
    10. **Pense como CONSULTOR** - você está sendo pago para entregar insights valiosos
    11. **NUNCA crie competição** - #{names} são PARCEIRAS, não rivais. Evite comparações que possam soar competitivas. Foque em colaboração, complementaridade e crescimento conjunto da EQUIPE

    Analise profundamente cada dado e entregue um relatório que realmente ajude #{names} a crescerem suas vendas e desenvolverem suas habilidades profissionais."
  end
end
