module Menu exposing (..)

import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Css
import Bulma
import Json.Decode as Decode
import Json.Encode as Encode
import Ports
import AddLabelMenu


type Msg
  = ToggleMenu
  | ToggleMenuItem MenuItem
  | ToggleAddMenu AddMenuItem
  | OpenDocument
  | AddLabelMenuMsg AddLabelMenu.Msg

type AddMenuItem
  = AddDocumentsMenuItem
  | AddLabelMenuItem
  | AddTeamMemberMenuItem

type MenuItem
  = MenuItem
    { label: String
    , icon: String
    , isOpen: Bool
    , addItem: Maybe AddMenuItem
    , subItems: List MenuItem
    }

type alias Model =
  { token : String
  , addLabelMenuModel: AddLabelMenu.Model
  , menu : Menu
  }

type alias Menu =
  { isOpen: Bool
  , documents: MenuItem
  , labels: MenuItem
  , team: MenuItem
  }

fileInputId = "fileInput"
encode : Model -> Encode.Value
encode model =
    Encode.object
        [ ("id", Encode.string fileInputId)
        , ("token", Encode.string model.token)
        ]

folderMenuItem : String -> MenuItem
folderMenuItem documentLabel =
  MenuItem { label = documentLabel, icon = "fas fa-folder", isOpen = False, subItems = [], addItem = Nothing }

teamMemberMenuItem : String -> MenuItem
teamMemberMenuItem teamMember =
    MenuItem { label = teamMember, icon = "fas fa-user", isOpen = False, subItems = [], addItem = Nothing }

labelMenuItem : String -> MenuItem
labelMenuItem label =
  MenuItem { label = label, icon = "fas fa-tag", isOpen = False, subItems = [], addItem = Nothing }

initModel : String -> String -> List String -> List String -> List String -> List String -> Model
initModel apiUrl token documentLabels spanLabels relationLabels team =
  { token = token
  , addLabelMenuModel = AddLabelMenu.initModel apiUrl token
  , menu =
      { isOpen = True
      , documents =
          MenuItem
            { label = "documents"
            , icon = "fas fa-copy"
            , isOpen = True
            , subItems = List.map folderMenuItem documentLabels
            , addItem = Just AddDocumentsMenuItem
            }
      , labels =
          MenuItem
            { label = "labels"
            , icon = "fas fa-tags"
            , isOpen = True
            , addItem = Just AddLabelMenuItem
            , subItems =
              [ MenuItem
                  { label = "document labels"
                  , icon = "fas fa-file"
                  , isOpen = False
                  , addItem = Nothing
                  , subItems = List.map labelMenuItem documentLabels
                  }
              , MenuItem
                  { label = "span labels"
                  , icon = "fas fa-highlighter"
                  , isOpen = False
                  , addItem = Nothing
                  , subItems = List.map labelMenuItem spanLabels
                  }
              , MenuItem
                  { label = "relation labels"
                  , icon = "fas fa-link"
                  , isOpen = False
                  , addItem  = Nothing
                  , subItems = List.map labelMenuItem relationLabels
                  }
              ]
            }
      , team =
          MenuItem
            { label = "team"
            , icon = "fas fa-users"
            , isOpen = True
            , addItem = Just AddTeamMemberMenuItem
            , subItems = List.map teamMemberMenuItem team
            }
      }
  }

menuToggleHoverStyle =
  Attributes.css
  [ Css.cursor Css.pointer
  , Css.hover [Css.color (Css.hex "3273dc")]
  ]

addDocumentMenuItem =
  Html.div []
    [ Html.input
      [ Attributes.id fileInputId
      , Attributes.type_ "file"
      , Attributes.css [Css.display Css.none]
      , Events.on "change" (Decode.succeed (ToggleAddMenu AddDocumentsMenuItem))
      ]
      []
    , Html.label [Attributes.for fileInputId]
      [ Html.li []
        {- This should really be an <a> tag in order for bulma styling to appear
           Correctly. I couldn't get the label to trigger the file input
           when wrapping the <a> tag However, so instead I'm using a span and
           replicating the styles applied by Bulma here :( -}
        [ Html.span
          [ Bulma.hasTextLinkClass
          , Attributes.css
            [ Css.padding2 (Css.em 0.5) (Css.em 0.75)
            , Css.display Css.block
            , Css.cursor Css.pointer
            , Css.hover [Css.backgroundColor (Css.hex "F5F5F5")]
            ]
          ]
          [ Html.span [ Bulma.iconClass ]
            [ Html.i [ Attributes.class "fas fa-plus" ] [] ]
          , Html.text "add"
          ]
        ]
      ]
    ]

addMenuItem addMenuItemType =
  Html.li []
    [ Html.a
      [ Attributes.href ""
      , Bulma.hasTextLinkClass
      , Events.onClick (ToggleAddMenu addMenuItemType)
      ]
      [ Html.span [ Bulma.iconClass ]
        [ Html.i [ Attributes.class "fas fa-plus" ] [] ]
      , Html.text "add"
      ]
    ]

addSubItems addItem subItems =
  let subMenuHtml = List.map menuItemHtml subItems in
  case addItem of
    Just AddDocumentsMenuItem ->
      [ Html.ul []
      ([addDocumentMenuItem] ++ subMenuHtml) ]
    Just addMenuItemType ->
      [ Html.ul []
      ([addMenuItem addMenuItemType] ++ subMenuHtml) ]
    Nothing ->
      [ Html.ul [] subMenuHtml ]

menuItemHtml : MenuItem -> Html.Html Msg
menuItemHtml menuItem =
  case menuItem of
    MenuItem {label, icon, isOpen, addItem, subItems} ->
        Html.li []
          ([ Html.a
            ([ Attributes.href ""
             ] ++ case (subItems, addItem) of
               ([], Nothing) -> []
               _ -> [Events.onClick (ToggleMenuItem menuItem)])
            [ Html.span [ Bulma.iconClass ]
              [ Html.i [ Attributes.class icon ] [] ]
            , Html.text label
            ]
          ] ++ if isOpen
            then addSubItems addItem subItems
            else [])

openMenu : Model -> Html.Html Msg
openMenu model =
  Html.div [ Bulma.columnsClass ]
    [ Html.div [ Bulma.columnClass ]
      [ Html.aside [ Bulma.menuClass ]
         [ Html.ul [ Bulma.menuListClass ]
          [ menuItemHtml model.menu.documents
          , menuItemHtml model.menu.labels
          , menuItemHtml model.menu.team
          ]
        ]
      ]
      , Html.div [ Bulma.columnClass, Bulma.isNarrowClass ]
        [ Html.span [ Bulma.iconClass, Events.onClick ToggleMenu, Bulma.isPulledRightClass, menuToggleHoverStyle ]
          [ Html.i [ Attributes.class "fas fa-angle-double-left"] [] ]
        ]
    ]


closedMenu =
  Html.aside [ Bulma.menuClass ]
    [ Html.span
      [ Bulma.iconClass
      , Events.onClick ToggleMenu
      , menuToggleHoverStyle
      ]
      [ Html.i [ Attributes.class "fas fa-angle-double-right"] [] ]
    ]

setMenu menuModel model =
  { model | menu = menuModel }

setToken token model =
  let newAddLabelMenuModel = model.addLabelMenuModel |> AddLabelMenu.setToken token
  in { model | token = token, addLabelMenuModel = newAddLabelMenuModel }


toggleMenuItem : MenuItem -> MenuItem -> MenuItem
toggleMenuItem targetMenuItem menuItem =
  case (targetMenuItem, menuItem) of
    (MenuItem target, MenuItem old) ->
      if target == old then
        MenuItem { old | isOpen = not old.isOpen, subItems = List.map (toggleMenuItem targetMenuItem) old.subItems}
      else
        MenuItem { old | subItems = List.map (toggleMenuItem targetMenuItem) old.subItems}


toggleMenu menuModel menuItem =
  let ( toggledDocuments, toggledLabels, toggledTeam ) = (toggleMenuItem menuItem menuModel.documents, toggleMenuItem menuItem menuModel.labels, toggleMenuItem menuItem menuModel.team)
  in { menuModel | documents = toggledDocuments, labels = toggledLabels, team = toggledTeam }

toggleAddLabelModal model =
  { model | showLabelModal = not model.showLabelModal }

update msg model =
  case msg of
    ToggleAddMenu AddDocumentsMenuItem -> (model, Ports.upload (encode model))
    ToggleAddMenu AddLabelMenuItem ->
      let newAddLabelMenuModel = AddLabelMenu.toggleIsOpen model.addLabelMenuModel
      in ({model | addLabelMenuModel = newAddLabelMenuModel}, Cmd.none)
    ToggleMenu ->
      let newMenu = model.menu |> \m -> { m | isOpen = not m.isOpen }
      in ( {model | menu = newMenu }, Cmd.none )
    ToggleMenuItem menuItem -> (model |> setMenu (toggleMenu model.menu menuItem), Cmd.none)
    AddLabelMenuMsg addLabelMsg ->
      let (newAddLabelMenuModel, cmd) = AddLabelMenu.update model.addLabelMenuModel addLabelMsg
      in ( {model | addLabelMenuModel = newAddLabelMenuModel }, Cmd.map (\m -> AddLabelMenuMsg m) cmd)
    _ -> (model, Cmd.none)



menu : Model -> Html.Html Msg
menu model =
  Html.div
    [ Bulma.columnClass
    , if model.menu.isOpen then Bulma.is4 else Bulma.isNarrowClass
    , Bulma.boxClass
    , Attributes.css [ Css.paddingLeft (Css.pct 2), Css.paddingTop (Css.pct 2) ]
    , Attributes.class "is-margin-less"
    , Attributes.css [ Css.minHeight (Css.calc (Css.vh 100) Css.minus (Css.em 2.5))]
    ]
    [ Html.map (\m -> AddLabelMenuMsg m) (AddLabelMenu.modal model.addLabelMenuModel)
    , if model.menu.isOpen then openMenu model else closedMenu
    ]
