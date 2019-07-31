https://stackoverflow.com/a/20040347/3574379
https://github.com/purescript/purescript/issues/1580#issuecomment-502421092

# 1

```
newtype User = User { username :: String }
newtype Key a = Key Int
data Entity a = Entity
  { entityKey   :: Key a
  , entityValue :: a
  }
class HasKey a k | a -> k where
  key :: a -> Key k
instance HasKey (Key a) a where
  key = identity
instance HasKey (Entity a) a where
  key = entityKey

-- generalization of `getFriends :: Key User -> [Entity User]`
-- was usually called as `getFriends (entityKey (user :: Entity User))`
getFriends :: HasKey a User => a -> [Entity User]
getFriends entityOrKey = let userkey = key entityOrKey in askDbForFriends userkey
  where
    askDbForFriends = undefined
```

# 2

```
newtype User = User { username :: String }
newtype Key = Key { getK :: Int }
data Entity a = Entity
  { entityKey   :: Key
  , entityValue :: a
  }
class HasKey a k | a -> k where
  key :: a -> Key
instance HasKey Key Key where
  key = identity
instance HasKey (Entity a) a where
  key = entityKey
```

# 3

```
newtype User = User { username :: String }
newtype Key a = Key Int
data Entity a = Entity
  { entityKey   :: Key a
  , entityValue :: a
  }
class HasKey a where
  type GetKeyType a
  key :: a -> Key (GetKeyType a)
instance HasKey (Key a) where
  type GetKeyType (Key a) = a
  key = identity
instance HasKey (Entity a) where
  type GetKeyType (Entity a) = a
  key = entityKey

-- generalization of `getFriends :: Key User -> [Entity User]`
-- was usually called as `getFriends (entityKey (user :: Entity User))`
getFriends :: HasKey a => a -> [Entity User]
getFriends entityOrKey = let userkey = key entityOrKey in askDbForFriends userkey
  where
    askDbForFriends = undefined
```
