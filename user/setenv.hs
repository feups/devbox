{-# LANGUAGE DeriveGeneric          #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE LambdaCase             #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE OverloadedStrings      #-}
{-# LANGUAGE QuasiQuotes            #-}
{-# LANGUAGE TemplateHaskell        #-}
{-# LANGUAGE TypeSynonymInstances   #-}

-- | This script assumes it is started from the ROOT_DIR of the devbox
module Main where

import qualified Control.Foldl  as Fold
import           Control.Lens   hiding (noneOf, view)
import qualified Data.Text      as Text
import qualified Data.Text.Lazy
import           Data.Vector    (Vector)
import           Dhall          hiding (Text, input, text)
import qualified Dhall
import           Prelude        hiding (FilePath)
import           Turtle         hiding (strict)

-- !! This needs to be changed when local-configuration.nix updates its version !!
eclipseVersion = "4.6.0"

type LText = Data.Text.Lazy.Text

data AdConfig
  = AdConfig
  { adLoginId  :: LText
  , adPassword :: LText
  } deriving (Generic, Show)

makeLensesWith abbreviatedFields ''AdConfig

instance Interpret AdConfig

data BoxConfig
  = BoxConfig
  { boxUserName       :: LText
  , boxUserEmail      :: LText
  , boxUserStacks     :: Vector LText
  , boxEclipsePlugins :: Bool
  , boxGeppetto       :: Bool
  , boxMrRepoUrl      :: LText
  } deriving (Generic, Show)

makeLensesWith abbreviatedFields ''BoxConfig

instance Interpret BoxConfig

installPkKeys = sh $ do
  printf "\nStarting ssh keys synchronization\n"
  testdir "/vagrant/ssh-keys" >>= \case
    False -> die "ERROR: no ssh-keys directory found. User provisioning aborted."
    True -> do
      shells "cp user/ssh-config ${HOME}/.ssh/config" empty
      shells "rsync --chmod=644 /vagrant/ssh-keys/*.pub ${HOME}/.ssh/" empty
      pk <- find (star (noneOf ".")) "/vagrant/ssh-keys"
      shells ("rsync --chmod=600 " <> format fp pk <> " ${HOME}/.ssh/") empty
      printf ("Synchronize "%fp%" key\n") pk

installMrRepos mr_url = sh $ do
  printf "\nStarting mr updates\n"
  _home <- home
  exitcode <- testfile (_home </> ".mrconfig") >>= \case
    False -> do
      proc "vcsh" ["clone", mr_url, "mr"] empty
      .&&. shell "mr -f -d $HOME up" empty
      .||. signal_mr_clone_failure
    True -> shell "mr -d $HOME up -q" empty
  case exitcode of
    ExitFailure _ -> printf "FAILURE: Unable to install all mr repositories\n\n"
    ExitSuccess   -> printf "Done with mr repositories\n\n"
  where
    signal_mr_clone_failure = do
      printf ("Enable to clone and install mr '"%s%"'.\n") mr_url
      pure (ExitFailure 1)

installDoc = sh $ do
  inproc "curl" ["-s", "http://stash.cirb.lan/projects/CICD/repos/puppet-shared-scripts/raw/README.adoc?at=refs/heads/master"] empty
    & output "puppet.adoc"
  inproc "curl" ["-s", "http://stash.cirb.lan/projects/CICD/repos/cicd-shell/raw/README.adoc?at=refs/heads/master"] empty
    & output "cicd-shell.adoc"
  exitcode <- shell "make doc > /dev/null" empty
  case exitcode of
    ExitFailure _ -> echo "FAILURE: documentation not installed successfully."
    ExitSuccess   -> do
      _home <- home
      cp "./doc/devbox.html" (_home </> ".local/share/doc/devbox.html")
      cp "doc/devbox.pdf" (_home </> ".local/share/doc/devbox.pdf")
      printf "Install documentation\n\n"

installNixPkgsFiles = sh $ do
  _home <- home
  printf "Installing nixpkgs files\n\n"
  cp "user/config.nix" (_home </> ".nixpkgs/config.nix")
  shells "rsync -r user/pkgs ${HOME}/.nixpkgs/" empty

installEclipsePlugins with_geppetto = sh $ do
    install_plugin "org.eclipse.egit" "http://download.eclipse.org/releases/mars/" "org.eclipse.egit.feature.group"
    install_plugin "org.eclipse.m2e" "http://download.eclipse.org/releases/mars/" "org.eclipse.m2e.feature.feature.group"
    when with_geppetto $
      install_plugin "com.puppetlabs.geppetto" "http://geppetto-updates.puppetlabs.com/4.x" "com.puppetlabs.geppetto.feature.group"
  where
    install_plugin full_name repository installIU = do
      _home <- home
      let installPath = _home </> fromText (".eclipse/org.eclipse.platform_" <> eclipseVersion)
          prefix_fp = installPath </> "plugins" </> fromText full_name
      not_installed <- fold (find (prefix (text (format fp prefix_fp))) installPath) Fold.null
      when not_installed $ do
        printf ("About to download Eclipse "%s%". Hold on.\n") full_name
        exitcode <- proc "eclipse" [ "-application", "org.eclipse.equinox.p2.director"
                                   , "-repository", repository
                                   , "-installIU", installIU
                                   , "-tag", "InitialState"
                                   , "-profile", "SDKProfile"
                                   , "-profileProperties", "org.eclipse.update.install.features=true"
                                   , "-p2.os", "linux"
                                   , "-p2.ws", "gtk"
                                   , "-p2.arch", "x86"
                                   , "-roaming"
                                   , "-nosplash"
                                   ] empty
        case exitcode of
          ExitFailure _ -> printf ("FAILURE: Eclipse plugin "%s%" won't installed\n\n") full_name
          ExitSuccess -> printf ("SUCCESS: Eclipse plugin "%s%" installed\n\n") full_name

configureGit :: Text -> Text -> IO ()
configureGit user_name user_email = sh $ do
  unless (Text.null user_name) $ procs "git" [ "config", "--global", "user.name", user_name] empty
  unless (Text.null user_email) $ procs "git" [ "config", "--global", "user.email", user_email] empty
  printf "Configure git\n\n"

configureMr :: Vector LText -> IO ()
configureMr stacks = sh $ do
  printf "\nStarting mr configuration\n"
  _home <- home
  stack <- select (stacks^..traverse.strict) :: Shell Text
  unless (Text.null stack) $ do
    let mr_file = format ("puppet-"%s%".mr") stack
        link_target = format ("../available.d/"%s) mr_file
        link_name = format (fp%"/.config/mr/config.d/"%s) _home mr_file
    printf ("Activate "%s%"\n") mr_file
    procs "ln" [ "-sf", link_target, link_name] empty

installCicdShell = sh $ do
  -- we currently copy the AD id & pwd into the home of the box
  -- In later versions, such management would go in the CICD shell project
  _home <- home
  ad <- liftIO $ Dhall.input auto "/vagrant/config/ad" :: Shell AdConfig
  let
    usr_id = unsafeTextToLine $ ad^.loginId.strict
    usr_pwd = unsafeTextToLine $ ad^.password.strict
  output (_home </> ".user_id") $ pure usr_id
  output (_home </> ".user_pwd") $ pure usr_pwd

  shell "nix-env -f '<nixpkgs>' -i cicd-shell" empty >>= \case
    ExitSuccess   -> printf "Done with cicd shell\n\n"
    ExitFailure _ -> printf "WARNING: enable to install the cicd shell\n\n"

main :: IO ()
main = do
  printf "\n> Starting user configuration\n"
  box_config  <- Dhall.input auto "/vagrant/config/box" :: IO BoxConfig
  installPkKeys
  configureGit (box_config^.userName.strict) (box_config^.userEmail.strict)
  installNixPkgsFiles
  configureMr (box_config^.userStacks)
  installMrRepos (box_config^.mrRepoUrl.strict)
  when (box_config^.eclipsePlugins) $ installEclipsePlugins (box_config^.geppetto)
  installCicdShell
  installDoc
  printf "< User configuration completed\n"
