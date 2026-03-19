require "test_helper"

class Api::ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = clients(:one)
  end

  # test "should get index" do
  #   get api_clients_url
  #   assert_response :success
  # end

  # test "should get new" do
  #   get new_api_client_url
  #   assert_response :success
  # end

  # test "should create client" do
  #   assert_difference("Client.count") do
  #     post api_clients_url, params: { client: { email: @client.email, name: @client.name, phone: @client.phone, user_id: @client.user_id } }
  #   end

  #   assert_redirected_to api_client_url(Client.last)
  # end

  # test "should show client" do
  #   get api_client_url(@client)
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get edit_api_client_url(@client)
  #   assert_response :success
  # end

  # test "should update client" do
  #   patch api_client_url(@client), params: { client: { email: @client.email, name: @client.name, phone: @client.phone, user_id: @client.user_id } }
  #   assert_redirected_to api_client_url(@client)
  # end

  # test "should destroy client" do
  #   assert_difference("Client.count", -1) do
  #     delete api_client_url(@client)
  #   end

  #   assert_redirected_to api_clients_url
  # end
end
