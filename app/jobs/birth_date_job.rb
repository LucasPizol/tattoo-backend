class BirthDateJob < ApplicationJob
  include RandomTimeable

  sidekiq_options queue: :low

  def perform
    company = Company.find(Company::MAIN_COMPANY_ID)
    user = company.users.find(User::ACCOUNT_OWNER_ID)

    clients = company.clients.birthday_month(Time.current.month)

    clients.includes(company: :company_config).find_each.with_index do |client, index|
      discount_percentage = client.company.company_config&.birth_date_discount_percentage || 0

      message = discount_percentage.zero? ?
        messages_without_discounts(client.first_name) :
        messages_with_discounts(client.first_name, discount_percentage)

      Whatsapp::SendMessageJob.perform_in(
        random_minutes(index),
        company.id,
        client.phone,
        Whatsapp::Templates::Birthday.build(discount_percentage)
      )
    end
  end

  def messages_without_discounts(name)
    [
      "🎉 Oi, #{name}! Esse mês é especial porque é o MÊS do seu aniversário! O Estúdio Glamour quer celebrar com você! Que esse novo ciclo traga muita luz, estilo e conquistas. Você merece tudo de mais lindo! ✨💎",
      "🥳 #{name}, esse é o seu mês de aniversário! A gente adora te ver brilhando por aqui. Que esse novo ano seja cheio de momentos incríveis e muito estilo! 🌟",
      "🎂 Oi, #{name}! Estamos no seu mês de aniversário e o Estúdio Glamour quer te desejar tudo de melhor! Que venha um ano repleto de realizações e boas vibes. 💖✨",
      "🎈 E aí, #{name}! Esse mês é de comemoração porque é o seu aniversário! Que venha muita atitude, brilho e tudo que você merece. 🔥",
      "🌹 Oi, #{name}! Passando pra celebrar o seu mês de aniversário! Que esse novo ciclo seja tão incrível quanto você! 💎✨",
      "✨ #{name}, esse mês é de festa porque é o seu aniversário! O Estúdio Glamour te deseja um mês maravilhoso e um ano novo cheio de brilho e autoexpressão! 🎊",
      "💫 Oi, #{name}! Esse é o seu mês especial! Que esse novo ano traga ainda mais coragem pra ser quem você é. A gente torce por você! 🦋"
    ].sample
  end

  def messages_with_discounts(name, discount_percentage)
    [
      "🎉 Oi, #{name}! Esse mês é especial porque é o MÊS do seu aniversário! O Estúdio Glamour quer celebrar com você! Que esse novo ciclo traga muita luz, estilo e conquistas. E pra deixar o mês ainda mais especial, você ganhou #{discount_percentage}% OFF em toda nossa coleção! ✨💎",
      "🥳 #{name}, esse é o seu mês de aniversário! A gente adora te ver brilhando por aqui. Pra comemorar, preparamos um presente: #{discount_percentage}% de desconto na sua próxima compra! 🌟",
      "🎂 Oi, #{name}! Estamos no seu mês de aniversário e o Estúdio Glamour quer te dar um presente: #{discount_percentage}% OFF pra você renovar o estilo! 💖✨",
      "🎈 E aí, #{name}! Esse mês é de comemoração porque é o seu aniversário! O Estúdio Glamour tá junto nessa e te presenteia com #{discount_percentage}% de desconto exclusivo. Aproveita! 🔥",
      "🌹 Oi, #{name}! Passando pra celebrar o seu mês de aniversário e te dar um mimo: #{discount_percentage}% OFF em qualquer piercing. Porque você merece brilhar ainda mais! 💎✨",
      "✨ #{name}, esse mês é de festa porque é o seu aniversário! O Estúdio Glamour te deseja um mês incrível e te presenteia com #{discount_percentage}% de desconto pra você arrasar no estilo! 🎊"
    ].sample
  end
end
