# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_19_100001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.integer "address_type", default: 0
    t.string "city"
    t.integer "client_id", null: false
    t.string "complement"
    t.datetime "created_at", null: false
    t.boolean "favorite", default: false
    t.string "name"
    t.string "neighborhood"
    t.string "number"
    t.string "state"
    t.string "street"
    t.datetime "updated_at", null: false
    t.string "zipcode"
    t.index ["client_id"], name: "index_addresses_on_client_id"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.integer "client_id"
    t.string "client_name"
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "end_at", null: false
    t.string "event_type", null: false
    t.bigint "order_id"
    t.string "phone"
    t.integer "reschedule_count", default: 0, null: false
    t.boolean "send_whatsapp_message", default: false, null: false
    t.datetime "sent_whatsapp_message_at"
    t.datetime "start_at", null: false
    t.string "status", default: "pending", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "whatsapp_message"
    t.index ["client_id"], name: "index_calendar_events_on_client_id"
    t.index ["company_id"], name: "index_calendar_events_on_company_id"
    t.index ["order_id"], name: "index_calendar_events_on_order_id"
    t.index ["user_id"], name: "index_calendar_events_on_user_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "campaing_type", default: 0, null: false
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.integer "indications_orders", default: 0, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["campaing_type"], name: "index_campaigns_on_campaing_type"
    t.index ["company_id"], name: "index_campaigns_on_company_id"
  end

  create_table "cart_products", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.string "value_currency", default: "brl", null: false
    t.integer "value_subcents", default: 0, null: false
    t.index ["client_id"], name: "index_cart_products_on_client_id"
    t.index ["product_id"], name: "index_cart_products_on_product_id"
  end

  create_table "clients", force: :cascade do |t|
    t.boolean "allergic_reactions", default: false
    t.date "birth_date"
    t.integer "company_id", null: false
    t.string "cpf"
    t.datetime "created_at", null: false
    t.boolean "diabetes", default: false
    t.boolean "disease_infectious_contagious", default: false
    t.string "email"
    t.string "encrypted_password"
    t.boolean "epilepsy", default: false
    t.string "gender"
    t.boolean "healing_problems", default: false
    t.boolean "hemophilia", default: false
    t.boolean "high_blood_pressure", default: false
    t.boolean "hipoglycemia", default: false
    t.boolean "hypersensitivity_to_chemicals", default: false
    t.datetime "indicated_at"
    t.integer "indicated_by_id"
    t.string "instagram_profile"
    t.boolean "keloid_proneness", default: false
    t.boolean "low_blood_pressure", default: false
    t.string "marital_status"
    t.string "name"
    t.text "observations"
    t.boolean "pacemaker", default: false
    t.string "phone"
    t.string "rg"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "vitiligo", default: false
    t.index ["company_id"], name: "index_clients_on_company_id"
    t.index ["cpf", "user_id"], name: "index_clients_on_cpf_and_user_id", unique: true
    t.index ["indicated_by_id"], name: "index_clients_on_indicated_by_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "comissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "order_id", null: false
    t.string "payer", default: "user", null: false
    t.decimal "percentage", precision: 5, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "value_cents", default: 0, null: false
    t.string "value_currency", default: "BRL"
    t.index ["order_id"], name: "index_comissions_on_order_id"
    t.index ["payer"], name: "index_comissions_on_payer"
    t.index ["user_id"], name: "index_comissions_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "cnpj"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.text "whatsapp_access_token"
    t.string "whatsapp_phone_number_id"
    t.string "whatsapp_waba_id"
    t.index ["cnpj"], name: "index_companies_on_cnpj", unique: true
    t.index ["whatsapp_phone_number_id"], name: "index_companies_on_whatsapp_phone_number_id", unique: true
  end

  create_table "company_configs", force: :cascade do |t|
    t.integer "birth_date_discount_percentage", default: 0, null: false
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.integer "product_percentage_variation", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_configs_on_company_id", unique: true
  end

  create_table "contracts", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "signed_at"
    t.string "signer_ip"
    t.string "signer_user_agent"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "version", default: 1, null: false
    t.index ["user_id"], name: "index_contracts_on_user_id"
  end

  create_table "instagram_accounts", force: :cascade do |t|
    t.boolean "company_account", default: false, null: false
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.string "ig_access_token", null: false
    t.datetime "ig_expires_at", null: false
    t.string "ig_id", null: false
    t.string "ig_profile_picture_url", null: false
    t.string "ig_username"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["company_id"], name: "index_instagram_accounts_on_company_id"
    t.index ["user_id"], name: "index_instagram_accounts_on_user_id"
  end

  create_table "instagram_comments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ig_comment_id", null: false
    t.integer "instagram_account_id", null: false
    t.integer "instagram_comment_id"
    t.integer "instagram_post_id", null: false
    t.text "text", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["instagram_account_id"], name: "index_instagram_comments_on_instagram_account_id"
    t.index ["instagram_comment_id"], name: "index_instagram_comments_on_instagram_comment_id"
    t.index ["instagram_post_id"], name: "index_instagram_comments_on_instagram_post_id"
  end

  create_table "instagram_posts", force: :cascade do |t|
    t.string "caption", null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "ig_carousel_id"
    t.integer "ig_comments_count"
    t.string "ig_container_id"
    t.integer "ig_like_count"
    t.string "ig_media_id"
    t.string "ig_media_product_type"
    t.string "ig_media_type"
    t.string "ig_media_url"
    t.string "ig_permalink"
    t.string "ig_thumbnail_url"
    t.string "ig_username"
    t.integer "ig_view_count"
    t.integer "instagram_account_id", null: false
    t.datetime "published_at"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["ig_media_id"], name: "index_instagram_posts_on_ig_media_id", unique: true
    t.index ["ig_media_product_type"], name: "index_instagram_posts_on_ig_media_product_type"
    t.index ["ig_media_type"], name: "index_instagram_posts_on_ig_media_type"
    t.index ["ig_username"], name: "index_instagram_posts_on_ig_username"
    t.index ["instagram_account_id"], name: "index_instagram_posts_on_instagram_account_id"
    t.index ["status"], name: "index_instagram_posts_on_status"
  end

  create_table "materials", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.string "notes"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["company_id"], name: "index_materials_on_company_id"
    t.index ["user_id"], name: "index_materials_on_user_id"
  end

  create_table "notes", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.datetime "due_date"
    t.string "priority", default: "low", null: false
    t.string "status", default: "open", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_notes_on_company_id"
    t.index ["completed_at"], name: "index_notes_on_completed_at"
    t.index ["due_date"], name: "index_notes_on_due_date"
    t.index ["priority"], name: "index_notes_on_priority"
    t.index ["status"], name: "index_notes_on_status"
  end

  create_table "order_payment_methods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.bigint "payment_method_id", null: false
    t.datetime "updated_at", null: false
    t.integer "value_cents", default: 0, null: false
    t.string "value_currency", default: "BRL", null: false
    t.index ["order_id", "payment_method_id"], name: "index_order_payment_methods_on_order_id_and_payment_method_id", unique: true
    t.index ["order_id"], name: "index_order_payment_methods_on_order_id"
    t.index ["payment_method_id"], name: "index_order_payment_methods_on_payment_method_id"
  end

  create_table "order_products", force: :cascade do |t|
    t.string "cost_value_currency", default: "BRL", null: false
    t.integer "cost_value_subcents", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.integer "quantity", default: 1, null: false
    t.bigint "stock_id"
    t.datetime "updated_at", null: false
    t.string "value_currency", default: "br", null: false
    t.integer "value_subcents", default: 0, null: false
    t.index ["order_id", "stock_id"], name: "index_order_products_on_order_id_and_stock_id", unique: true
    t.index ["order_id"], name: "index_order_products_on_order_id"
    t.index ["stock_id"], name: "index_order_products_on_stock_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "address_id"
    t.integer "applied_birth_date_discount_percentage", default: 0, null: false
    t.integer "client_id"
    t.integer "comissions_value_cents", default: 0, null: false
    t.string "comissions_value_currency", default: "BRL", null: false
    t.integer "company_id"
    t.string "cost_value_currency", default: "BRL"
    t.integer "cost_value_subcents", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "created_by", default: 0
    t.integer "external_id"
    t.string "idempotency_key"
    t.boolean "local_pickup", default: false
    t.datetime "paid_at"
    t.string "product_values_currency", default: "BRL"
    t.integer "product_values_subcents", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "taxes_values_currency", default: "BRL"
    t.integer "taxes_values_subcents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.boolean "values_divided", default: false, null: false
    t.datetime "whatsapp_notified_at"
    t.index ["address_id"], name: "index_orders_on_address_id"
    t.index ["client_id"], name: "index_orders_on_client_id"
    t.index ["company_id"], name: "index_orders_on_company_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.integer "external_type", default: 0, null: false
    t.string "name", null: false
    t.float "taxes", default: 0.0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["company_id"], name: "index_payment_methods_on_company_id"
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "cardholder_name"
    t.datetime "created_at", null: false
    t.bigint "external_id"
    t.integer "installment_amount_cents", default: 0, null: false
    t.string "installment_amount_currency", default: "BRL", null: false
    t.string "installments"
    t.string "last_four_digits"
    t.integer "net_received_value_cents", default: 0, null: false
    t.string "net_received_value_currency", default: "BRL", null: false
    t.bigint "order_id"
    t.integer "owner", default: 0
    t.bigint "payment_method_id"
    t.string "payment_type"
    t.integer "status", default: 0, null: false
    t.integer "taxes_value_cents", default: 0, null: false
    t.string "taxes_value_currency", default: "BRL", null: false
    t.integer "total_paid_amount_cents", default: 0, null: false
    t.string "total_paid_amount_currency", default: "BRL", null: false
    t.datetime "updated_at", null: false
    t.integer "value_cents", default: 0, null: false
    t.string "value_currency", default: "BRL", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["payment_method_id"], name: "index_payments_on_payment_method_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_permissions_on_role_id"
  end

  create_table "product_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "product_id", null: false
    t.integer "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "tag_id"], name: "index_product_tags_on_product_id_and_tag_id", unique: true
    t.index ["product_id"], name: "index_product_tags_on_product_id"
    t.index ["tag_id"], name: "index_product_tags_on_tag_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "carousel", default: false, null: false
    t.integer "company_id", null: false
    t.string "cost_value_currency", default: "br"
    t.integer "cost_value_subcents", default: 0
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured", default: false, null: false
    t.integer "material_id"
    t.string "name", null: false
    t.boolean "new", default: false, null: false
    t.string "product_type"
    t.boolean "require_responsible", default: false, null: false
    t.string "sku", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "value_currency", default: "brl", null: false
    t.bigint "value_subcents", default: 0, null: false
    t.index ["company_id", "sku"], name: "index_products_on_company_id_and_sku", unique: true
    t.index ["company_id"], name: "index_products_on_company_id"
    t.index ["cost_value_currency"], name: "index_products_on_cost_value_currency"
    t.index ["cost_value_subcents"], name: "index_products_on_cost_value_subcents"
    t.index ["material_id", "sku"], name: "index_products_on_material_id_and_sku", unique: true
    t.index ["material_id"], name: "index_products_on_material_id"
    t.index ["name"], name: "index_products_on_name_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "raffle_clients", force: :cascade do |t|
    t.integer "client_id"
    t.datetime "created_at", null: false
    t.bigint "instagram_comment_id"
    t.integer "position", default: 0, null: false
    t.bigint "raffle_id", null: false
    t.integer "raffle_type", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_raffle_clients_on_client_id"
    t.index ["instagram_comment_id"], name: "index_raffle_clients_on_instagram_comment_id"
    t.index ["raffle_id", "client_id"], name: "index_raffle_clients_on_raffle_id_and_client_id"
    t.index ["raffle_id"], name: "index_raffle_clients_on_raffle_id"
  end

  create_table "raffles", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.jsonb "filters", default: {}, null: false
    t.bigint "instagram_post_id"
    t.string "name", null: false
    t.integer "primary_count", default: 1, null: false
    t.integer "secondary_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_raffles_on_company_id"
    t.index ["instagram_post_id"], name: "index_raffles_on_instagram_post_id"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "company_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.string "prompt", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_reports_on_company_id"
  end

  create_table "responsibles", force: :cascade do |t|
    t.date "birth_date", null: false
    t.integer "client_id", null: false
    t.string "cpf", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "gender", null: false
    t.string "name", null: false
    t.string "phone", null: false
    t.string "rg"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_responsibles_on_client_id"
  end

  create_table "roles", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_roles_on_company_id"
  end

  create_table "sale_messages", force: :cascade do |t|
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.datetime "scheduled_at"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_sale_messages_on_client_id"
    t.index ["order_id"], name: "index_sale_messages_on_order_id"
  end

  create_table "shipping_estimations", force: :cascade do |t|
    t.string "company", default: "", null: false
    t.integer "cost_cents", default: 0, null: false
    t.string "cost_currency", default: "BRL", null: false
    t.datetime "created_at", null: false
    t.string "estimated_delivery", null: false
    t.integer "final_cost_cents", default: 0, null: false
    t.string "final_cost_currency", default: "BRL", null: false
    t.bigint "order_id", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_shipping_estimations_on_order_id"
  end

  create_table "shippings", force: :cascade do |t|
    t.string "company", null: false
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.datetime "estimated_at", null: false
    t.string "estimated_delivery", null: false
    t.bigint "order_id", null: false
    t.integer "original_value_cents", default: 0, null: false
    t.string "original_value_currency", default: "BRL", null: false
    t.integer "profitable_value_cents", default: 0, null: false
    t.string "profitable_value_currency", default: "BRL", null: false
    t.integer "status", default: 0, null: false
    t.string "tracking_number"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_shippings_on_order_id"
    t.index ["tracking_number"], name: "index_shippings_on_tracking_number", unique: true
  end

  create_table "stock_movements", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.string "movement_type", default: "in", null: false
    t.string "notes"
    t.integer "order_id"
    t.integer "quantity", null: false
    t.bigint "stock_id"
    t.datetime "updated_at", null: false
    t.string "value_currency", default: "br", null: false
    t.integer "value_subcents", null: false
    t.index ["company_id"], name: "index_stock_movements_on_company_id"
    t.index ["order_id"], name: "index_stock_movements_on_order_id"
    t.index ["stock_id"], name: "index_stock_movements_on_stock_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_stocks_on_product_id"
  end

  create_table "tags", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "notes"
    t.integer "tag_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["company_id"], name: "index_tags_on_company_id"
    t.index ["tag_id"], name: "index_tags_on_tag_id"
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "user_clients", force: :cascade do |t|
    t.string "authentication_type", default: "email", null: false
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["authentication_type"], name: "index_user_clients_on_authentication_type"
    t.index ["client_id"], name: "index_user_clients_on_client_id"
    t.index ["email"], name: "index_user_clients_on_email", unique: true
  end

  create_table "user_comissions", force: :cascade do |t|
    t.integer "comission_value_cents", default: 0, null: false
    t.string "comission_value_currency", default: "BRL", null: false
    t.datetime "created_at", null: false
    t.integer "holding_shipment_value_cents", default: 0, null: false
    t.string "holding_shipment_value_currency", default: "BRL", null: false
    t.bigint "order_id", null: false
    t.bigint "payment_method_id"
    t.integer "received_value_cents", default: 0, null: false
    t.string "received_value_currency", default: "BRL", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["order_id"], name: "index_user_comissions_on_order_id"
    t.index ["payment_method_id"], name: "index_user_comissions_on_payment_method_id"
    t.index ["user_id"], name: "index_user_comissions_on_user_id"
  end

  create_table "user_invite_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false, null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.bigint "user_invite_id", null: false
    t.index ["user_invite_id"], name: "index_user_invite_tokens_on_user_invite_id"
  end

  create_table "user_invites", force: :cascade do |t|
    t.decimal "commission_percentage", precision: 5, scale: 2, default: "0.0", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "phone"
    t.bigint "role_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_user_invites_on_company_id"
    t.index ["role_id"], name: "index_user_invites_on_role_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "color"
    t.decimal "commission_percentage", precision: 5, scale: 2, default: "0.0", null: false
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.string "google_uid"
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "refresh_token"
    t.datetime "refresh_token_expires_at"
    t.datetime "refresh_token_issued_at"
    t.bigint "role_id"
    t.string "text_color"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
    t.index ["refresh_token", "refresh_token_expires_at"], name: "index_users_on_refresh_token_and_refresh_token_expires_at"
    t.index ["refresh_token"], name: "index_users_on_refresh_token", unique: true
    t.index ["refresh_token_expires_at"], name: "index_users_on_refresh_token_expires_at"
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "webhook_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "error_message"
    t.string "event_type", null: false
    t.string "idempotency_key"
    t.jsonb "payload", null: false
    t.integer "provider", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_webhook_events_on_event_type"
    t.index ["idempotency_key"], name: "index_webhook_events_on_idempotency_key", unique: true
    t.index ["provider"], name: "index_webhook_events_on_provider"
    t.index ["status"], name: "index_webhook_events_on_status"
  end

  create_table "whatsapp_messages", force: :cascade do |t|
    t.text "body"
    t.bigint "company_id", null: false
    t.string "contact_name"
    t.datetime "created_at", null: false
    t.integer "direction", default: 0, null: false
    t.string "from_number"
    t.string "message_id"
    t.integer "message_type", default: 0, null: false
    t.string "phone_number_id"
    t.datetime "sent_at"
    t.integer "status", default: 0, null: false
    t.string "template_name"
    t.string "to_number"
    t.datetime "updated_at", null: false
    t.index ["company_id", "created_at"], name: "index_whatsapp_messages_on_company_id_and_created_at"
    t.index ["company_id"], name: "index_whatsapp_messages_on_company_id"
    t.index ["direction"], name: "index_whatsapp_messages_on_direction"
    t.index ["message_id"], name: "index_whatsapp_messages_on_message_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "clients"
  add_foreign_key "calendar_events", "clients"
  add_foreign_key "calendar_events", "companies"
  add_foreign_key "calendar_events", "orders"
  add_foreign_key "calendar_events", "users"
  add_foreign_key "campaigns", "companies"
  add_foreign_key "cart_products", "clients"
  add_foreign_key "cart_products", "products"
  add_foreign_key "clients", "clients", column: "indicated_by_id"
  add_foreign_key "clients", "companies"
  add_foreign_key "clients", "users"
  add_foreign_key "comissions", "orders"
  add_foreign_key "comissions", "users"
  add_foreign_key "company_configs", "companies"
  add_foreign_key "contracts", "users"
  add_foreign_key "instagram_accounts", "companies"
  add_foreign_key "instagram_accounts", "users"
  add_foreign_key "instagram_comments", "instagram_accounts"
  add_foreign_key "instagram_comments", "instagram_comments"
  add_foreign_key "instagram_comments", "instagram_posts"
  add_foreign_key "instagram_posts", "instagram_accounts"
  add_foreign_key "materials", "companies"
  add_foreign_key "materials", "users"
  add_foreign_key "notes", "companies"
  add_foreign_key "order_payment_methods", "orders"
  add_foreign_key "order_payment_methods", "payment_methods"
  add_foreign_key "order_products", "orders"
  add_foreign_key "order_products", "stocks"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "clients"
  add_foreign_key "orders", "companies"
  add_foreign_key "orders", "users"
  add_foreign_key "payment_methods", "companies"
  add_foreign_key "payment_methods", "users"
  add_foreign_key "payments", "orders"
  add_foreign_key "payments", "payment_methods"
  add_foreign_key "permissions", "roles"
  add_foreign_key "product_tags", "products"
  add_foreign_key "product_tags", "tags"
  add_foreign_key "products", "companies"
  add_foreign_key "products", "materials"
  add_foreign_key "products", "users"
  add_foreign_key "raffle_clients", "clients"
  add_foreign_key "raffle_clients", "instagram_comments"
  add_foreign_key "raffle_clients", "raffles"
  add_foreign_key "raffles", "companies"
  add_foreign_key "raffles", "instagram_posts"
  add_foreign_key "reports", "companies"
  add_foreign_key "responsibles", "clients"
  add_foreign_key "roles", "companies"
  add_foreign_key "sale_messages", "clients"
  add_foreign_key "sale_messages", "orders"
  add_foreign_key "shipping_estimations", "orders"
  add_foreign_key "shippings", "orders"
  add_foreign_key "stock_movements", "companies"
  add_foreign_key "stock_movements", "orders"
  add_foreign_key "stock_movements", "stocks"
  add_foreign_key "stocks", "products"
  add_foreign_key "tags", "companies"
  add_foreign_key "tags", "tags"
  add_foreign_key "tags", "users"
  add_foreign_key "user_clients", "clients"
  add_foreign_key "user_comissions", "orders"
  add_foreign_key "user_comissions", "payment_methods"
  add_foreign_key "user_comissions", "users"
  add_foreign_key "user_invite_tokens", "user_invites"
  add_foreign_key "user_invites", "companies"
  add_foreign_key "user_invites", "roles"
  add_foreign_key "users", "companies"
  add_foreign_key "users", "roles"
  add_foreign_key "whatsapp_messages", "companies"
end
