module AddTeamMemberMenuView exposing (modal, update)

import AddTeamMemberMenu
import AppModel
import AppMsg
import AttributeBuilder
import Bulma
import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events


modal model =
    let
        title =
            "Add Team Member"

        body =
            Html.div
                []
                [ Bulma.labelledField
                    "username"
                    [ Bulma.textInput
                        [ Attributes.placeholder "username"
                        , Events.onInput (AppMsg.AddTeamMemberMenuMsg << AppMsg.SetUsername)
                        ]
                    ]
                , Bulma.labelledField
                    "email"
                    [ Bulma.textInput
                        [ Attributes.placeholder "email"
                        , Events.onInput (AppMsg.AddTeamMemberMenuMsg << AppMsg.SetEmail)
                        ]
                    ]
                ]

        footer =
            [ Bulma.button
                ([ Bulma.isSuccessClass, Events.onClick (AppMsg.AddTeamMemberMenuMsg AppMsg.SaveTeamMember) ]
                    |> AttributeBuilder.addIf
                        (model.email == "" || model.username == "")
                        [ Attributes.disabled True ]
                    |> AttributeBuilder.addIf
                        (model.state == AddTeamMemberMenu.Pending)
                        [ Bulma.isLoadingClass ]
                )
                "invite"
            , Html.span
                ([ Bulma.helpClass
                 , Bulma.isDangerClass
                 ]
                    |> AttributeBuilder.addIf (not <| model.state == AddTeamMemberMenu.Error) [ Bulma.isInvisibleClass ]
                )
                [ Html.text "Something went wrong, try again later." ]
            ]
    in
    Bulma.modal model.isOpen title (AppMsg.AddTeamMemberMenuMsg AppMsg.ToggleAddTeamMemberMenu) body footer


update : AppMsg.AddTeamMemberMenuMsg -> AppModel.Model -> ( AppModel.Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        AppMsg.ToggleAddTeamMemberMenu ->
            ( model.addTeamMemberMenu |> AddTeamMemberMenu.toggle |> AppModel.asAddTeamMemberMenu model, Cmd.none )

        AppMsg.SetEmail email ->
            ( model.addTeamMemberMenu |> AddTeamMemberMenu.setEmail email |> AppModel.asAddTeamMemberMenu model, Cmd.none )

        AppMsg.SaveTeamMember ->
            Debug.todo "save team member"

        AppMsg.SetUsername username ->
            ( model.addTeamMemberMenu |> AddTeamMemberMenu.setUsername username |> AppModel.asAddTeamMemberMenu model, Cmd.none )
