module Payload.Client.Client
       ( mkClient
       , mkClient_
       , mkGuardedClient
       , mkGuardedClient_
       , module Payload.Client.Options
       ) where

import Payload.Client.ClientApi (class ClientApi, mkClientApi)
import Payload.Client.Options (ModifyRequest, Options, defaultOpts)
import Payload.Spec (Spec(..))

mkClient :: forall routesSpec client
            . ClientApi routesSpec client
            => Options
            -> Spec routesSpec
            -> client
mkClient opts _ = mkGuardedClient opts spec
  where spec = Spec :: Spec { routes :: routesSpec, guards :: {} }

mkClient_ :: forall routesSpec client
            . ClientApi routesSpec client
            => Spec routesSpec
            -> client
mkClient_ = mkClient defaultOpts

mkGuardedClient :: forall routesSpec client r
            . ClientApi routesSpec client
            => Options
            -> Spec { routes :: routesSpec | r }
            -> client
mkGuardedClient = mkClientApi

mkGuardedClient_ :: forall routesSpec client r
            . ClientApi routesSpec client
            => Spec { routes :: routesSpec | r }
            -> client
mkGuardedClient_ = mkGuardedClient defaultOpts
