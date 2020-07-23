module API
    module V1
      class Images  < Grape::API
        resource :images do

          desc '上传image'
          params do
            requires :token, type: String, desc: "user token"
            requires :file, type: File, desc: "文件"
          end
          post do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            image = Image.new(user: user)
            image.file = params[:file][:tempfile]
            image.save!

            present image.id
          end

          desc '获得image'
          params do
            requires :token, type: String, desc: "user token"
            requires :id, type: Integer, desc: "文件id"
          end
          get do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            image = Image.find(params[:id]) rescue nil
            app_error('无效id') if image.nil?

            app_error('无权访问id') unless image.user == user

            present image.file.url
          end


        end
      end
    end
  end
