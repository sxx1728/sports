# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
Renter::User.create(phone: '13900000001', password_md5:'123456', nick_name: '1')
Renter::User.create(phone: '13900000002', password_md5:'123456', nick_name: '2')
Renter::User.create(phone: '13900000003', password_md5:'123456', nick_name: '3')
Renter::User.create(phone: '13900000004', password_md5:'123456', nick_name: '4')
Renter::User.create(phone: '13900000005', password_md5:'123456', nick_name: '5')

Owner::User.create(phone: '13900000006', password_md5:'123456', nick_name: '6')
Owner::User.create(phone: '13900000007', password_md5:'123456', nick_name: '7')
Owner::User.create(phone: '13900000008', password_md5:'123456', nick_name: '8')
Owner::User.create(phone: '13900000009', password_md5:'123456', nick_name: '9')
Owner::User.create(phone: '13900000010', password_md5:'123456', nick_name: '10')

Arbitrator::User.create(phone: '13900000011', password_md5:'123456', nick_name: '11')
Arbitrator::User.create(phone: '13900000012', password_md5:'123456', nick_name: '12')
Arbitrator::User.create(phone: '13900000013', password_md5:'123456', nick_name: '13')
Arbitrator::User.create(phone: '13900000014', password_md5:'123456', nick_name: '14')
Arbitrator::User.create(phone: '13900000015', password_md5:'123456', nick_name: '15')

