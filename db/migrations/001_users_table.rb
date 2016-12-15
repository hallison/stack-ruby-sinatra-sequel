Sequel.migration do
  up do
    create_table :users do
      primary_key :id, type: :Bignum
      string :username, size: 64, null: false, unique: true
      string :name, null: false
      string :email, null: false
      string :signature, size: 64, null: false
      boolean :administrator, default: false
      boolean :moderator, default: false
      date :created_at, default: Date.today

      index [:username]
    end
  end

  down do
    drop_table :users
  end
end
