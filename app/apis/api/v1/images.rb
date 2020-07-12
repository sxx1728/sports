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
            binding.pry
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            image = Image.new(user: user)
            image.file = params[:file][:tempfile]
            image.save!

            present image.id
          end

        end
      end
    end
  end
