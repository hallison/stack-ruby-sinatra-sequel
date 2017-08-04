Sequel.migration do
  up do
    create_table :users do
      primary_key :id, type: :Bignum
      varchar :username, size: 64, null: false, unique: true
      varchar :name, size: 255, null: false
      varchar :email, size: 128, null: false, unique: true
      varchar :signature, size: 64, null: false
      boolean :administrator, default: false
      boolean :moderator, default: false
      timestamp :create_date
      timestamp :update_date
      index [:username]
    end
  end

  down do
    drop_table :users
  end
end
