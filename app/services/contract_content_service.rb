module ContractContentService
  CURRENT_VERSION = 1

  def self.generate(user:, commission_percentage:)
    <<~MARKDOWN
      # Contrato de Prestação de Serviços e Repasse de Comissão

      **Data de emissão:** #{Date.current.strftime("%d/%m/%Y")}
      **Versão:** #{CURRENT_VERSION}

      ---

      ## Partes

      **CONTRATANTE:** Estúdio Glamour, pessoa jurídica de direito privado, doravante denominada simplesmente **ESTÚDIO**.

      **CONTRATADO(A):** #{user.name}, cadastrado(a) na plataforma com o usuário `#{user.username}`, doravante denominado(a) simplesmente **COLABORADOR(A)**.

      ---

      ## Cláusula 1 — Objeto

      O presente contrato tem por objeto regular as condições de prestação de serviços do(a) **COLABORADOR(A)** ao **ESTÚDIO**, especialmente no que diz respeito ao repasse de comissão sobre os pedidos realizados ou intermediados pelo(a) **COLABORADOR(A)** através da plataforma interna de gestão.

      ---

      ## Cláusula 2 — Comissão

      2.1. O(A) **COLABORADOR(A)** compromete-se a repassar ao **ESTÚDIO** o percentual de **#{commission_percentage}%** (#{commission_percentage_extenso(commission_percentage)} por cento) sobre o valor bruto de cada pedido por ele(a) realizado ou registrado na plataforma.

      2.2. O repasse deverá ser realizado até o 5º (quinto) dia útil do mês subsequente ao mês de competência dos pedidos.

      2.3. O não cumprimento do prazo estipulado na cláusula 2.2 poderá acarretar em suspensão temporária do acesso à plataforma, a critério do **ESTÚDIO**.

      ---

      ## Cláusula 3 — Obrigações do(a) Colaborador(a)

      O(A) **COLABORADOR(A)** se compromete a:

      - Utilizar a plataforma de gestão de forma ética e responsável;
      - Registrar todos os pedidos realizados, sem omissão de informações;
      - Manter sigilo sobre dados de clientes, estratégias comerciais e informações internas do **ESTÚDIO**;
      - Não compartilhar suas credenciais de acesso com terceiros;
      - Informar imediatamente ao **ESTÚDIO** qualquer irregularidade identificada na plataforma;
      - Cumprir as políticas internas de atendimento e conduta do **ESTÚDIO**.

      ---

      ## Cláusula 4 — Obrigações do Estúdio

      O **ESTÚDIO** se compromete a:

      - Disponibilizar acesso à plataforma de gestão durante toda a vigência deste contrato;
      - Fornecer suporte técnico e operacional para o uso da plataforma;
      - Comunicar com antecedência mínima de 15 (quinze) dias corridos qualquer alteração na porcentagem de comissão estabelecida na Cláusula 2;
      - Tratar os dados do(a) **COLABORADOR(A)** em conformidade com a Lei Geral de Proteção de Dados (LGPD — Lei nº 13.709/2018).

      ---

      ## Cláusula 5 — Proteção de Dados

      5.1. Os dados pessoais do(a) **COLABORADOR(A)** coletados neste contrato e durante o uso da plataforma serão tratados exclusivamente para fins de gestão operacional e cumprimento das obrigações aqui previstas.

      5.2. O(A) **COLABORADOR(A)** consente com o registro e armazenamento de sua assinatura eletrônica, endereço IP, data e hora de assinatura e identificador de dispositivo (user agent), para fins de validade e autenticidade deste instrumento.

      5.3. Os dados serão armazenados em servidores seguros e não serão compartilhados com terceiros sem consentimento expresso, salvo obrigação legal.

      ---

      ## Cláusula 6 — Vigência e Rescisão

      6.1. Este contrato entra em vigor na data de sua assinatura eletrônica e tem prazo indeterminado.

      6.2. Qualquer das partes poderá rescindi-lo mediante comunicação escrita com antecedência mínima de 30 (trinta) dias corridos.

      6.3. A rescisão imotivada pelo(a) **COLABORADOR(A)** não gera direito a qualquer indenização por parte do **ESTÚDIO**.

      ---

      ## Cláusula 7 — Disposições Gerais

      7.1. Este contrato não estabelece vínculo empregatício entre as partes, sendo o(a) **COLABORADOR(A)** prestador(a) de serviços autônomo(a).

      7.2. As partes elegem o foro da comarca do **ESTÚDIO** para dirimir quaisquer controvérsias oriundas deste contrato.

      7.3. Este instrumento é celebrado em formato eletrônico, tendo plena validade jurídica nos termos da Medida Provisória nº 2.200-2/2001 e do Marco Civil da Internet (Lei nº 12.965/2014).

      ---

      *Ao assinar digitalmente abaixo, o(a) **COLABORADOR(A)** declara ter lido, compreendido e concordado integralmente com todas as cláusulas deste contrato.*
    MARKDOWN
  end

  private

  def self.commission_percentage_extenso(value)
    int_part = value.to_i
    case int_part
    when 0 then "zero"
    when 1 then "um"
    when 2 then "dois"
    when 3 then "três"
    when 4 then "quatro"
    when 5 then "cinco"
    when 6 then "seis"
    when 7 then "sete"
    when 8 then "oito"
    when 9 then "nove"
    when 10 then "dez"
    when 11 then "onze"
    when 12 then "doze"
    when 13 then "treze"
    when 14 then "quatorze"
    when 15 then "quinze"
    when 16 then "dezesseis"
    when 17 then "dezessete"
    when 18 then "dezoito"
    when 19 then "dezenove"
    when 20 then "vinte"
    when 25 then "vinte e cinco"
    when 30 then "trinta"
    when 40 then "quarenta"
    when 50 then "cinquenta"
    else int_part.to_s
    end
  end
end
