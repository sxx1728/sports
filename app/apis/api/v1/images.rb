module API
    module V1
      class Images  < Grape::API
        resource :images do

          desc '上传image'
          params do
            requires :token, type: String, desc: "user token"
            requires :image_file, type: File, desc: "user token"
          end
          post do
            present 1
          end

        end
      end
    end
  end
