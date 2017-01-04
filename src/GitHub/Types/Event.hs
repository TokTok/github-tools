module GitHub.Types.Event where

import           Data.Text (Text)


newtype TypeName  a = TypeName  Text
newtype EventName a = EventName Text

class Event a where
    typeName  :: TypeName a
    eventName :: EventName a
