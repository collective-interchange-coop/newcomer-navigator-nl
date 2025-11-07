# frozen_string_literal: true

namespace :nn_nl do # rubocop:todo Metrics/BlockLength
  desc 'Migrate Partners List Intro from YAML to RichText Content'
  task migrate_partners_intro_to_content: :environment do
    identifier = 'partners-list-intro'

    # Hardcoded translations to preserve content after YAML removal
    translations = {
      en: %(In the "Partner Organizations" section, you'll find information about groups that help newcomers and immigrants in Newfoundland and Labrador. These organizations offer many different kinds of help, like finding jobs, going to school, making friends, and getting legal advice. By talking to these groups, newcomers can get help with settling in, finding good jobs, learning new things, and becoming part of their new communities. This group of organizations is here to help you every step of the way.), # rubocop:disable Layout/LineLength
      es: %(En la sección "Organizaciones Asociadas", encontrarás información sobre grupos que ayudan a recién llegados e inmigrantes en Terranova y Labrador. Estas organizaciones ofrecen diferentes tipos de ayuda, como encontrar empleo, acceder a educación, hacer amigos y recibir asesoramiento legal. Al contactar a estos grupos, los recién llegados pueden obtener apoyo para establecerse, encontrar buenos empleos, aprender nuevas cosas y formar parte de sus nuevas comunidades. Este conjunto de organizaciones está aquí para ayudarte en cada paso del camino.), # rubocop:disable Layout/LineLength
      fr: %(Dans la section "Organisations Partenaires", vous trouverez des informations sur les groupes qui aident les nouveaux arrivants et les immigrants à Terre-Neuve-et-Labrador. Ces organisations offrent différents types d'aide, comme trouver un emploi, accéder à l'éducation, se faire des amis et obtenir des conseils juridiques. En contactant ces groupes, les nouveaux arrivants peuvent obtenir un soutien pour s'établir, trouver de bons emplois, apprendre de nouvelles choses et faire partie de leurs nouvelles communautés. Ce groupe d'organisations est là pour vous aider à chaque étape.), # rubocop:disable Layout/LineLength
      uk: %(У розділі "Партнерські організації" ви знайдете інформацію про групи, які допомагають новоприбулим та іммігрантам у Ньюфаундленді та Лабрадорі. Ці організації пропонують різноманітну допомогу, як-от пошук роботи, навчання, знайомства та юридичні консультації. Звернувшись до цих груп, новоприбулі можуть отримати підтримку у влаштуванні, пошуку хорошої роботи, навчанні новому та інтеграції у свої нові громади. Ця група організацій готова допомогти вам на кожному етапі.) # rubocop:disable Layout/LineLength
    }

    puts "Migrating partners list intro to RichText content for locales: #{translations.keys.join(', ')}"

    # Check if content already exists
    existing = BetterTogether::Content::RichText.find_by(identifier: identifier)
    if existing
      puts "⚠️  Content with identifier '#{identifier}' already exists (ID: #{existing.id})"
      puts '   To re-migrate, first delete it or use a different identifier.'
      next
    end

    # Create the RichText content
    BetterTogether::Content::RichText.transaction do
      rich_text = BetterTogether::Content::RichText.create!(
        identifier: identifier,
        privacy: 'public'
      )

      # Add translations for each locale
      translations.each do |locale, description|
        next if description.blank?

        # Convert plain text to HTML paragraphs
        html_content = description.strip.split(/\n\n+/).map do |paragraph|
          "<p>#{paragraph.gsub("\n", ' ').strip}</p>"
        end.join("\n")

        rich_text.public_send "content_#{locale}=", html_content
        puts "✓ Added #{locale} translation (#{html_content.length} chars)"
      end

      rich_text.save!
      puts "\n✅ Successfully created RichText content with identifier '#{identifier}'"
      puts "   ID: #{rich_text.id}"
    end
  rescue StandardError => e
    puts "\n❌ Error during migration: #{e.message}"
    puts e.backtrace.first(5).join("\n")
  end

  desc 'Migrate Partner Addresses to Buildings'
  task migrate_partner_buildings: :environment do # rubocop:todo Metrics/BlockLength
    Mobility.with_locale(:en) do # rubocop:todo Metrics/BlockLength
      partners = Partner.joins(:addresses).includes(:buildings)
                        .where.not(addresses: { line1: nil })
                        .where(buildings: { address_id: nil })
      new_buildings = []

      Partner.transaction do
        partners.each do |partner|
          next if partner.buildings.any?

          partner.addresses.each do |addr|
            name = addr.geocoding_string

            building = new_buildings.find { |building| building.name == name }

            building ||= BetterTogether::Infrastructure::Building.i18n.find_by(name:)

            unless building
              building = BetterTogether::Infrastructure::Building.create(
                address_id: addr.id,
                creator_id: partner.creator_id,
                privacy: addr.privacy,
                name:
              )

              new_buildings << building
            end

            partner.building_connections.create(building: building)

            addr.contact_detail_id = nil

            addr.save

            puts "Added new building to #{partner} for address: #{addr.geocoding_string}"
          end
        end
      end
    end
  end
end
