require 'rails_helper'

describe Admin::UsersController, 'rough port of the old functional test', type: :controller do
  render_views

  describe ' when you are admin' do
    before(:each) do
      create(:blog)
      @admin = create(:user, profile: User::ADMIN)
      sign_in @admin
    end

    it 'test_index' do
      get :index
      assert_template 'index'
      expect(assigns(:users)).not_to be_nil
    end

    it 'test_new' do
      get :new
      assert_template 'new'

      post :create, user: { login: 'errand', email: 'corey@test.com',
                            password: 'testpass',
                            password_confirmation: 'testpass',
                            profile: User::CONTRIBUTOR,
                            nickname: 'fooo', firstname: 'bar' }
      expect(response).to redirect_to(action: 'index')
    end

    describe '#EDIT action' do
      describe 'with POST request' do
        it 'should redirect to index' do
          post :update, id: @admin.id, user: { login: 'errand',
                                               email: 'corey@test.com', password: 'testpass',
                                               password_confirmation: 'testpass' }
          expect(response).to redirect_to(action: 'index')
        end
      end
    end
  end

  describe 'when you are not admin' do
    before :each do
      create(:blog)
      user = create(:user)
      sign_in user
    end

    it "don't see the list of user" do
      get :index
      expect(response).to redirect_to(controller: '/admin/dashboard', action: 'index')
    end

    describe 'EDIT Action' do
      describe 'try update another user' do
        before do
          @administrator = create(:user, :as_admin)
          post :edit,
               id: @administrator.id,
               profile: User::CONTRIBUTOR
        end

        it 'should redirect to login' do
          expect(response).to redirect_to(controller: '/admin/dashboard', action: 'index')
        end

        it 'should not change user profile' do
          u = @administrator.reload
          expect(u.profile).to eq User::ADMIN
        end
      end
    end
  end
end
